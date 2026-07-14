import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:drift/drift.dart';

import 'package:fashion_pos_enterprise/core/auth/sync_tenant_context.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/database/app_database.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/network/network_monitor.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/sync/conflict_resolver.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/sync/entity_sync_processor.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/sync/remote_sync_record.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/sync/sync_events.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/sync/sync_pull_applier.dart';
import 'package:fashion_pos_enterprise/core/logging/app_logger.dart';
import 'package:uuid/uuid.dart';

/// Production synchronization coordinator with queue, retry, delta pull, and conflicts.
class SyncCoordinator {
  SyncCoordinator({
    required AppDatabase database,
    required NetworkMonitor networkMonitor,
    required ConflictResolver conflictResolver,
    SyncPullApplier? pullApplier,
    List<EntitySyncProcessor> processors = const [],
    this.batchSize = 50,
    this.maxRetries = 10,
    this.autoSyncInterval = const Duration(minutes: 5),
    Uuid? uuid,
  })  : _db = database,
        _network = networkMonitor,
        _conflictResolver = conflictResolver,
        _pullApplier = pullApplier ?? SyncPullApplier(database),
        _processors = {for (final p in processors) p.entityType: p},
        _uuid = uuid ?? const Uuid();

  final AppDatabase _db;
  final NetworkMonitor _network;
  final ConflictResolver _conflictResolver;
  final SyncPullApplier _pullApplier;
  final Map<String, EntitySyncProcessor> _processors;
  final Uuid _uuid;
  final int batchSize;
  final int maxRetries;
  final Duration autoSyncInterval;

  final _eventController = StreamController<SyncEvent>.broadcast();
  final _progressController = StreamController<SyncProgress>.broadcast();

  Timer? _autoSyncTimer;
  StreamSubscription<NetworkState>? _networkSub;
  bool _paused = false;
  bool _running = false;
  bool _cancelRequested = false;
  SyncEngineState _state = SyncEngineState.idle;

  Stream<SyncEvent> get events => _eventController.stream;
  Stream<SyncProgress> get progress => _progressController.stream;
  SyncEngineState get state => _state;

  void registerProcessor(EntitySyncProcessor processor) {
    _processors[processor.entityType] = processor;
  }

  Future<void> initialize() async {
    await _db.syncQueueDao.resetStuckProcessing();
    _networkSub = _network.stateStream.listen((networkState) {
      if (networkState.isOnline && networkState.quality != NetworkQuality.captivePortal) {
        _eventController.add(const NetworkRecovered());
        if (!_paused) unawaited(sync(trigger: SyncTrigger.networkRecovery));
      }
    });
    _autoSyncTimer = Timer.periodic(autoSyncInterval, (_) {
      if (!_paused) unawaited(sync(trigger: SyncTrigger.scheduled));
    });
    AppLogger.info('SyncCoordinator initialized with ${_processors.length} processors');
  }

  Future<void> dispose() async {
    await _networkSub?.cancel();
    _autoSyncTimer?.cancel();
    await _eventController.close();
    await _progressController.close();
  }

  void pause() {
    _paused = true;
    _setState(SyncEngineState.paused);
    _eventController.add(const SyncPaused());
  }

  void resume() {
    _paused = false;
    _eventController.add(const SyncResumed());
    unawaited(sync(trigger: SyncTrigger.manual));
  }

  void cancel() {
    _cancelRequested = true;
    _eventController.add(const SyncCancelled());
  }

  Future<SyncProgress> sync({SyncTrigger trigger = SyncTrigger.manual}) async {
    if (_running) return _currentProgress(trigger);
    if (_paused) return _currentProgress(trigger, state: SyncEngineState.paused);

    final network = await _network.currentState;
    if (!network.isOnline) {
      _setState(SyncEngineState.offline);
      return _currentProgress(trigger, state: SyncEngineState.offline);
    }

    _running = true;
    _cancelRequested = false;
    _setState(SyncEngineState.syncing);
    _eventController.add(SyncStarted(trigger));

    var processed = 0;
    var failed = 0;

    try {
      final pending = await _db.syncQueueDao.getPending(limit: batchSize, maxRetries: maxRetries);
      _emitProgress(SyncProgress(state: SyncEngineState.syncing, trigger: trigger, total: pending.length));

      for (final item in pending) {
        if (_cancelRequested) break;

        await _db.syncQueueDao.markProcessing(item.id);
        final processor = _processors[item.entityType];
        if (processor == null) {
          await _db.syncQueueDao.markFailed(item.id, 'No processor registered', item.retryCount + 1);
          failed++;
          continue;
        }

        try {
          final result = await processor.push(_queueItemMap(item));
          if (result.success) {
            await _db.syncQueueDao.markCompleted(item.id);
            processed++;
          } else if (result.conflict != null) {
            final strategy = item.conflictStrategy != null
                ? ConflictResolutionStrategy.fromValue(item.conflictStrategy!)
                : null;
            final resolution = _conflictResolver.resolve(result.conflict!, overrideStrategy: strategy);
            if (!resolution.requiresManualReview) {
              await _pullApplier.applyResolvedPayload(
                tenantId: item.tenantId,
                entityType: item.entityType,
                entityId: item.entityId,
                payload: resolution.resolvedPayload,
                version: result.conflict!.serverVersion,
                strategy: resolution.strategy,
              );
              await _db.syncQueueDao.markCompleted(item.id);
              processed++;
            } else {
              await _db.syncQueueDao.markFailed(
                item.id,
                'Manual conflict resolution required',
                item.retryCount + 1,
              );
              failed++;
            }
          } else {
            await _db.syncQueueDao.markFailed(
              item.id,
              result.errorMessage ?? 'Unknown sync error',
              item.retryCount + 1,
            );
            failed++;
          }
        } catch (e, st) {
          AppLogger.error('Sync item failed: ${item.id}', e, st);
          await _db.syncQueueDao.markFailed(item.id, e.toString(), item.retryCount + 1);
          failed++;
        }

        _emitProgress(
          SyncProgress(
            state: SyncEngineState.syncing,
            trigger: trigger,
            total: pending.length,
            processed: processed,
            failed: failed,
            currentEntityType: item.entityType,
          ),
        );
      }

      await _pullDeltas();
      _setState(SyncEngineState.idle);
      _eventController.add(SyncCompleted(processed: processed, failed: failed));
      return _currentProgress(trigger, processed: processed, failed: failed);
    } catch (e, st) {
      AppLogger.error('SyncCoordinator failed', e, st);
      _setState(SyncEngineState.failed);
      _eventController.add(SyncFailed(e));
      rethrow;
    } finally {
      _running = false;
      _cancelRequested = false;
    }
  }

  Future<void> _pullDeltas() async {
    final tenantId = SyncTenantContext.tenantId;
    if (tenantId == null || tenantId.isEmpty) {
      AppLogger.warning('Skipping pull delta — no tenant context');
      return;
    }

    final deviceId = SyncTenantContext.deviceId;
    final checkpoints = await _db.syncCheckpointDao.getAllForDevice(deviceId);

    for (final processor in _processors.values) {
      final checkpoint =
          checkpoints.where((c) => c.entityType == processor.entityType).firstOrNull;
      final since = checkpoint?.lastSyncedAt ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
      final sinceVersion = checkpoint?.lastVersion ?? 0;

      final pullResult = await processor.pullDelta(
        tenantId: tenantId,
        deviceId: deviceId,
        since: since,
        sinceVersion: sinceVersion,
      );

      if (pullResult.records.isEmpty) continue;

      final applied = await _pullApplier.applyAll(tenantId: tenantId, records: pullResult.records);

      final maxUpdated = pullResult.maxUpdatedAt ??
          pullResult.records.map((r) => r.updatedAt).reduce((a, b) => a.isAfter(b) ? a : b);
      final maxVersion = pullResult.maxVersion > sinceVersion
          ? pullResult.maxVersion
          : pullResult.records.map((r) => r.version).fold(sinceVersion, (a, b) => a > b ? a : b);

      final now = DateTime.now().toUtc();
      await _db.syncCheckpointDao.upsertCheckpoint(
        SyncCheckpointsCompanion.insert(
          id: checkpoint?.id ?? _uuid.v4(),
          tenantId: tenantId,
          deviceId: deviceId,
          entityType: processor.entityType,
          lastVersion: Value(maxVersion),
          lastSyncedAt: maxUpdated,
          createdAt: checkpoint?.createdAt ?? now,
          updatedAt: now,
        ),
      );

      await log(
        'info',
        'Pull delta applied for ${processor.entityType}',
        metadata: {'applied': applied, 'fetched': pullResult.records.length},
      );
    }
  }

  Future<void> log(String level, String message, {Map<String, dynamic>? metadata}) {
    return _db.syncLogDao.append(
      SyncLogsCompanion.insert(
        id: _uuid.v4(),
        level: level,
        message: message,
        metadata: Value(jsonEncode(metadata ?? {})),
        createdAt: DateTime.now().toUtc(),
      ),
    );
  }

  Map<String, dynamic> _queueItemMap(SyncQueueItem item) => {
        'id': item.id,
        'tenant_id': item.tenantId,
        'entity_type': item.entityType,
        'entity_id': item.entityId,
        'operation': item.operation,
        'payload': jsonDecode(item.payload),
        'client_version': item.clientVersion,
        'retry_count': item.retryCount,
        'conflict_strategy': item.conflictStrategy,
      };

  void _setState(SyncEngineState state) => _state = state;

  void _emitProgress(SyncProgress progress) {
    _progressController.add(progress);
    _eventController.add(SyncProgressUpdated(progress));
  }

  SyncProgress _currentProgress(
    SyncTrigger trigger, {
    SyncEngineState? state,
    int processed = 0,
    int failed = 0,
  }) {
    return SyncProgress(
      state: state ?? _state,
      trigger: trigger,
      processed: processed,
      failed: failed,
    );
  }
}
