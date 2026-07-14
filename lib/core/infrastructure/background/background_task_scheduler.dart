import 'dart:async';

import 'package:fashion_pos_enterprise/core/infrastructure/database/database_backup_manager.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/database/database_initializer.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/sync/media_sync_integration.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/sync/sync_coordinator.dart';
import 'package:fashion_pos_enterprise/core/logging/app_logger.dart';

/// Background task identifiers.
enum BackgroundTask {
  sync,
  backup,
  cleanup,
  upload,
}

/// Schedules infrastructure background operations.
class BackgroundTaskScheduler {
  BackgroundTaskScheduler({
    required SyncCoordinator syncCoordinator,
    required DatabaseBackupManager backupManager,
    MediaSyncIntegration? mediaSync,
    String? defaultTenantId,
    this.syncInterval = const Duration(minutes: 15),
    this.backupInterval = const Duration(hours: 6),
    this.cleanupInterval = const Duration(hours: 24),
    this.uploadInterval = const Duration(minutes: 5),
  })  : _sync = syncCoordinator,
        _backup = backupManager,
        _mediaSync = mediaSync,
        _defaultTenantId = defaultTenantId;

  final SyncCoordinator _sync;
  final DatabaseBackupManager _backup;
  final MediaSyncIntegration? _mediaSync;
  final String? _defaultTenantId;
  final Duration syncInterval;
  final Duration backupInterval;
  final Duration cleanupInterval;
  final Duration uploadInterval;

  final Map<BackgroundTask, Timer> _timers = {};

  void start() {
    _timers[BackgroundTask.sync] = Timer.periodic(syncInterval, (_) {
      unawaited(_sync.sync(trigger: SyncTrigger.background));
    });
    _timers[BackgroundTask.backup] = Timer.periodic(backupInterval, (_) {
      unawaited(_backup.createBackup(label: 'auto'));
    });
    _timers[BackgroundTask.cleanup] = Timer.periodic(cleanupInterval, (_) {
      unawaited(_cleanup());
    });
    if (_mediaSync != null && _defaultTenantId != null) {
      _timers[BackgroundTask.upload] = Timer.periodic(uploadInterval, (_) {
        unawaited(_mediaSync!.syncPendingUploads(_defaultTenantId!));
      });
    }
    AppLogger.info('BackgroundTaskScheduler started');
  }

  Future<void> _cleanup() async {
    final db = DatabaseInitializer.database;
    await db.syncLogDao.pruneOlderThan(const Duration(days: 30));
    await db.featureFlagDao.clearExpired();
  }

  void stop() {
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
  }
}
