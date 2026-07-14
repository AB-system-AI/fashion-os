import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fashion_pos_enterprise/core/enterprise/app_version_checker.dart';
import 'package:fashion_pos_enterprise/core/enterprise/license_validator.dart';
import 'package:fashion_pos_enterprise/core/enterprise/remote_config_service.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/analytics/analytics_provider.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/background/background_task_scheduler.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/cache/disk_cache.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/cache/memory_cache.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/crash/crash_reporting_provider.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/database/app_database.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/database/database_backup_manager.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/database/database_initializer.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/feature_flags/feature_flag_service.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/license/license_engine.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/logging/central_logger.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/di/media_providers.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/network/network_monitor.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/network/retry_executor.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/remote_config/remote_config_manager.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/storage/storage_service.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/sync/conflict_resolver.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/sync/sync_coordinator.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/sync/sync_queue_writer.dart';

/// Encrypted Drift database instance.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  return DatabaseInitializer.database;
});

final databaseBackupManagerProvider = Provider<DatabaseBackupManager>((ref) {
  return DatabaseInitializer.backupManager;
});

final networkMonitorProvider = Provider<NetworkMonitor>((ref) {
  final monitor = NetworkMonitor();
  ref.onDispose(monitor.dispose);
  return monitor;
});

final retryExecutorProvider = Provider<RetryExecutor>((ref) {
  return RetryExecutor(networkMonitor: ref.watch(networkMonitorProvider));
});

final syncQueueWriterProvider = Provider<SyncQueueWriter>((ref) {
  return SyncQueueWriter(ref.watch(appDatabaseProvider));
});

final conflictResolverProvider = Provider<ConflictResolver>((ref) {
  return ConflictResolver();
});

final syncCoordinatorProvider = Provider<SyncCoordinator>((ref) {
  final coordinator = SyncCoordinator(
    database: ref.watch(appDatabaseProvider),
    networkMonitor: ref.watch(networkMonitorProvider),
    conflictResolver: ref.watch(conflictResolverProvider),
  );
  ref.onDispose(coordinator.dispose);
  return coordinator;
});

final featureFlagServiceProvider = Provider<FeatureFlagService>((ref) {
  return FeatureFlagService(
    database: ref.watch(appDatabaseProvider),
    remoteConfig: ref.watch(remoteConfigServiceProvider),
    networkMonitor: ref.watch(networkMonitorProvider),
  );
});

final licenseEngineProvider = Provider<LicenseEngine>((ref) {
  return LicenseEngine(
    validator: ref.watch(licenseValidatorProvider),
    remoteConfig: ref.watch(remoteConfigServiceProvider),
    networkMonitor: ref.watch(networkMonitorProvider),
  );
});

final remoteConfigManagerProvider = Provider<RemoteConfigManager>((ref) {
  return RemoteConfigManager(
    remoteConfig: ref.watch(remoteConfigServiceProvider),
    versionChecker: ref.watch(appVersionCheckerProvider),
  );
});

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService(adapters: const []);
});

final memoryCacheProvider = Provider<MemoryCache<String, Object>>((ref) {
  return MemoryCache<String, Object>();
});

final diskCacheProvider = Provider<DiskCache>((ref) {
  return DiskCache(database: ref.watch(appDatabaseProvider));
});

final analyticsHubProvider = Provider<AnalyticsHub>((ref) {
  final hub = AnalyticsHub([NoOpAnalyticsProvider()]);
  ref.onDispose(hub.dispose);
  return hub;
});

final crashReportingHubProvider = Provider<CrashReportingHub>((ref) {
  final hub = CrashReportingHub([NoOpCrashReportingProvider()]);
  ref.onDispose(hub.dispose);
  return hub;
});

final centralLoggerProvider = Provider<CentralLogger>((ref) {
  final logger = CentralLogger([
    ConsoleLogSink(),
    FileLogSink(),
    RemoteLogSink(ref.watch(appDatabaseProvider))..start(),
  ]);
  ref.onDispose(logger.dispose);
  return logger;
});

final backgroundTaskSchedulerProvider = Provider<BackgroundTaskScheduler>((ref) {
  final scheduler = BackgroundTaskScheduler(
    syncCoordinator: ref.watch(syncCoordinatorProvider),
    backupManager: ref.watch(databaseBackupManagerProvider),
  );
  ref.onDispose(scheduler.stop);
  return scheduler;
});

/// Initializes all infrastructure services — call once during bootstrap.
final infrastructureInitializerProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    await DatabaseInitializer.initialize();
    await ref.read(mediaInitializerProvider)();
    final network = ref.read(networkMonitorProvider);
    await network.initialize();
    final sync = ref.read(syncCoordinatorProvider);
    await sync.initialize();
    ref.read(backgroundTaskSchedulerProvider).start();
    await ref.read(analyticsHubProvider).initialize();
    await ref.read(crashReportingHubProvider).initialize();
    await ref.read(featureFlagServiceProvider).refresh();
  };
});
