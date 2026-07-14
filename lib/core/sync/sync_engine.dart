import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/database/app_database.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/database/database_initializer.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/sync/sync_coordinator.dart';
import 'package:fashion_pos_enterprise/core/logging/app_logger.dart';
import 'package:fashion_pos_enterprise/core/services/connectivity_service.dart';
import 'package:fashion_pos_enterprise/core/sync/sync_status.dart';
import 'package:uuid/uuid.dart';

/// Legacy sync engine facade — delegates queue writes to Drift.
/// Prefer [SyncCoordinator] for new code.
class SyncEngine {
  SyncEngine({
    required ConnectivityService connectivity,
    required Future<bool> Function(Map<String, dynamic> item) processor,
    SyncCoordinator? coordinator,
  })  : _connectivity = connectivity,
        _processor = processor,
        _coordinator = coordinator;

  final ConnectivityService _connectivity;
  final Future<bool> Function(Map<String, dynamic> item) _processor;
  final SyncCoordinator? _coordinator;
  final _uuid = const Uuid();
  final _statusController = StreamController<SyncStatus>.broadcast();

  StreamSubscription<bool>? _connectivitySub;
  Timer? _periodicTimer;
  bool _isProcessing = false;

  Stream<SyncStatus> get statusStream => _statusController.stream;

  Future<void> initialize() async {
    await DatabaseInitializer.initialize();
    _connectivitySub = _connectivity.onConnectivityChanged.listen((online) {
      if (online) unawaited(processQueue());
    });
    _periodicTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => unawaited(processQueue()),
    );
    AppLogger.info('SyncEngine initialized');
  }

  Future<void> dispose() async {
    await _connectivitySub?.cancel();
    _periodicTimer?.cancel();
    await _statusController.close();
  }

  Future<String> enqueue({
    required String entityType,
    required String entityId,
    required String operation,
    required Map<String, dynamic> payload,
    String tenantId = '',
  }) async {
    final db = DatabaseInitializer.database;
    final id = _uuid.v4();
    final now = DateTime.now().toUtc();
    await db.syncQueueDao.enqueue(
      SyncQueueItemsCompanion.insert(
        id: id,
        tenantId: tenantId,
        entityType: entityType,
        entityId: entityId,
        operation: operation,
        payload: jsonEncode(payload),
        createdAt: now,
        updatedAt: now,
        scheduledAt: Value(now),
      ),
    );
    if (await _connectivity.isConnected) unawaited(processQueue());
    return id;
  }

  Future<void> processQueue() async {
    if (_coordinator != null) {
      await _coordinator!.sync(trigger: SyncTrigger.automatic);
      return;
    }
    if (_isProcessing) return;
    if (!await _connectivity.isConnected) {
      _setStatus(SyncStatus.offline);
      return;
    }

    _isProcessing = true;
    _setStatus(SyncStatus.syncing);
    try {
      final db = DatabaseInitializer.database;
      final items = await db.syncQueueDao.getPending(limit: 50);
      for (final item in items) {
        final success = await _processor({
          'id': item.id,
          'entity_type': item.entityType,
          'entity_id': item.entityId,
          'operation': item.operation,
          'payload': jsonDecode(item.payload),
        });
        if (success) {
          await db.syncQueueDao.markCompleted(item.id);
        } else {
          await db.syncQueueDao.markFailed(item.id, 'Processor returned false', item.retryCount + 1);
        }
      }
      _setStatus(SyncStatus.synced);
    } catch (e, st) {
      AppLogger.error('SyncEngine processQueue failed', e, st);
      _setStatus(SyncStatus.failed);
    } finally {
      _isProcessing = false;
    }
  }

  Future<int> pendingCount() async {
    return DatabaseInitializer.database.syncQueueDao.countPending();
  }

  void _setStatus(SyncStatus status) => _statusController.add(status);
}
