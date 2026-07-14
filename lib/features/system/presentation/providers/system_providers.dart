import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fashion_pos_enterprise/core/audit/audit_providers.dart';
import 'package:fashion_pos_enterprise/core/di/enterprise_providers.dart';
import 'package:fashion_pos_enterprise/core/di/providers.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/di/infrastructure_providers.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/features/system/data/datasources/system_remote_datasource.dart';
import 'package:fashion_pos_enterprise/features/system/data/repositories/system_repository_impl.dart';
import 'package:fashion_pos_enterprise/features/system/data/sync/system_sync_processor.dart';
import 'package:fashion_pos_enterprise/features/system/domain/entities/audit.dart';
import 'package:fashion_pos_enterprise/features/system/domain/entities/feature_flag.dart';
import 'package:fashion_pos_enterprise/features/system/domain/entities/licensing.dart';
import 'package:fashion_pos_enterprise/features/system/domain/entities/monitoring.dart';
import 'package:fashion_pos_enterprise/features/system/domain/entities/release.dart';
import 'package:fashion_pos_enterprise/features/system/domain/entities/roles_permissions.dart';
import 'package:fashion_pos_enterprise/features/system/domain/entities/security.dart';
import 'package:fashion_pos_enterprise/features/system/domain/entities/settings.dart';
import 'package:fashion_pos_enterprise/features/system/domain/repositories/system_repositories.dart';
import 'package:fashion_pos_enterprise/features/system/domain/services/system_services.dart';

final systemRemoteDataSourceProvider = Provider<SystemRemoteDataSource>((ref) => SystemRemoteDataSource());

final featureFlagRepositoryProvider = Provider<FeatureFlagRepository>((ref) {
  return FeatureFlagLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final systemAuditRepositoryProvider = Provider<SystemAuditRepository>((ref) {
  return SystemAuditLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final roleDefinitionRepositoryProvider = Provider<RoleDefinitionRepository>((ref) {
  return RoleDefinitionLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final permissionAssignmentRepositoryProvider = Provider<PermissionAssignmentRepository>((ref) {
  return PermissionAssignmentLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final systemHealthRepositoryProvider = Provider<SystemHealthRepository>((ref) {
  return SystemHealthLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final errorLogRepositoryProvider = Provider<ErrorLogRepository>((ref) {
  return ErrorLogLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final backgroundJobRepositoryProvider = Provider<BackgroundJobRepository>((ref) {
  return BackgroundJobLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final syncMonitorRepositoryProvider = Provider<SyncMonitorRepository>((ref) {
  return SyncMonitorLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final storageMonitorRepositoryProvider = Provider<StorageMonitorRepository>((ref) {
  return StorageMonitorLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final licenseRecordRepositoryProvider = Provider<LicenseRecordRepository>((ref) {
  return LicenseRecordLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final subscriptionRecordRepositoryProvider = Provider<SubscriptionRecordRepository>((ref) {
  return SubscriptionRecordLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final environmentSettingRepositoryProvider = Provider<EnvironmentSettingRepository>((ref) {
  return EnvironmentSettingLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final securitySessionRepositoryProvider = Provider<SecuritySessionRepository>((ref) {
  return SecuritySessionLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final deviceRegistrationRepositoryProvider = Provider<DeviceRegistrationRepository>((ref) {
  return DeviceRegistrationLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final loginHistoryRepositoryProvider = Provider<LoginHistoryRepository>((ref) {
  return LoginHistoryLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final maintenanceModeRepositoryProvider = Provider<MaintenanceModeRepository>((ref) {
  return MaintenanceModeLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final systemConfigurationRepositoryProvider = Provider<SystemConfigurationRepository>((ref) {
  return SystemConfigurationLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final releaseNoteRepositoryProvider = Provider<ReleaseNoteRepository>((ref) {
  return ReleaseNoteLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final migrationHistoryRepositoryProvider = Provider<MigrationHistoryRepository>((ref) {
  return MigrationHistoryLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final systemDashboardServiceProvider = Provider<SystemDashboardService>((ref) => SystemDashboardService(
      database: ref.watch(appDatabaseProvider),
      syncCoordinator: ref.watch(syncCoordinatorProvider),
      health: ref.watch(systemHealthRepositoryProvider),
      errors: ref.watch(errorLogRepositoryProvider),
      maintenance: ref.watch(maintenanceModeRepositoryProvider),
      storage: ref.watch(storageMonitorRepositoryProvider),
      sessions: ref.watch(securitySessionRepositoryProvider),
      permissions: ref.watch(permissionEngineProvider),
    ));

final systemFeatureFlagServiceProvider = Provider<FeatureFlagService>((ref) => FeatureFlagService(
      repository: ref.watch(featureFlagRepositoryProvider),
      coreFlags: ref.watch(featureFlagServiceProvider),
      permissions: ref.watch(permissionEngineProvider),
    ));

final auditExplorerServiceProvider = Provider<AuditExplorerService>((ref) => AuditExplorerService(
      audit: ref.watch(auditServiceProvider),
      repository: ref.watch(systemAuditRepositoryProvider),
      permissions: ref.watch(permissionEngineProvider),
    ));

final tenantAdminServiceProvider = Provider<TenantAdminService>((ref) => TenantAdminService(
      roles: ref.watch(roleDefinitionRepositoryProvider),
      assignments: ref.watch(permissionAssignmentRepositoryProvider),
      config: ref.watch(systemConfigurationRepositoryProvider),
      permissions: ref.watch(permissionEngineProvider),
    ));

final healthMonitorServiceProvider = Provider<HealthMonitorService>((ref) => HealthMonitorService(
      repository: ref.watch(systemHealthRepositoryProvider),
      permissions: ref.watch(permissionEngineProvider),
    ));

final performanceMonitorServiceProvider = Provider<PerformanceMonitorService>((ref) => PerformanceMonitorService(
      jobs: ref.watch(backgroundJobRepositoryProvider),
      permissions: ref.watch(permissionEngineProvider),
    ));

final errorLogServiceProvider = Provider<ErrorLogService>((ref) => ErrorLogService(
      repository: ref.watch(errorLogRepositoryProvider),
      permissions: ref.watch(permissionEngineProvider),
    ));

final syncMonitorServiceProvider = Provider<SyncMonitorService>((ref) => SyncMonitorService(
      repository: ref.watch(syncMonitorRepositoryProvider),
      database: ref.watch(appDatabaseProvider),
      syncCoordinator: ref.watch(syncCoordinatorProvider),
      permissions: ref.watch(permissionEngineProvider),
    ));

final storageMonitorServiceProvider = Provider<StorageMonitorService>((ref) => StorageMonitorService(
      repository: ref.watch(storageMonitorRepositoryProvider),
      database: ref.watch(appDatabaseProvider),
      permissions: ref.watch(permissionEngineProvider),
    ));

final queueMonitorServiceProvider = Provider<QueueMonitorService>((ref) => QueueMonitorService(
      database: ref.watch(appDatabaseProvider),
      jobs: ref.watch(backgroundJobRepositoryProvider),
      permissions: ref.watch(permissionEngineProvider),
    ));

final systemLicenseServiceProvider = Provider<LicenseService>((ref) => LicenseService(
      licenses: ref.watch(licenseRecordRepositoryProvider),
      subscriptions: ref.watch(subscriptionRecordRepositoryProvider),
      licenseEngine: ref.watch(licenseEngineProvider),
      permissions: ref.watch(permissionEngineProvider),
    ));

final maintenanceServiceProvider = Provider<MaintenanceService>((ref) => MaintenanceService(
      repository: ref.watch(maintenanceModeRepositoryProvider),
      permissions: ref.watch(permissionEngineProvider),
    ));

final securityCenterServiceProvider = Provider<SecurityCenterService>((ref) => SecurityCenterService(
      sessions: ref.watch(securitySessionRepositoryProvider),
      devices: ref.watch(deviceRegistrationRepositoryProvider),
      loginHistory: ref.watch(loginHistoryRepositoryProvider),
      permissions: ref.watch(permissionEngineProvider),
    ));

final diagnosticsServiceProvider = Provider<DiagnosticsService>((ref) => DiagnosticsService(
      database: ref.watch(appDatabaseProvider),
      syncCoordinator: ref.watch(syncCoordinatorProvider),
      networkMonitor: ref.watch(networkMonitorProvider),
      config: ref.watch(appConfigProvider),
      permissions: ref.watch(permissionEngineProvider),
    ));

final environmentSettingsServiceProvider = Provider<EnvironmentSettingsService>((ref) => EnvironmentSettingsService(
      repository: ref.watch(environmentSettingRepositoryProvider),
      permissions: ref.watch(permissionEngineProvider),
    ));

final releaseNotesServiceProvider = Provider<ReleaseNotesService>((ref) => ReleaseNotesService(
      repository: ref.watch(releaseNoteRepositoryProvider),
      permissions: ref.watch(permissionEngineProvider),
    ));

SystemSyncProcessor _processor(Ref ref, String entityType, String table) => SystemSyncProcessor(
      remote: ref.watch(systemRemoteDataSourceProvider),
      entityTypeName: entityType,
      remoteTable: table,
    );

final featureFlagSyncProcessorProvider = Provider<FeatureFlagSyncProcessor>((ref) => _processor(ref, FeatureFlag.entityTypeName, 'feature_flags'));
final systemAuditSyncProcessorProvider = Provider<SystemAuditSyncProcessor>((ref) => _processor(ref, SystemAuditEntry.entityTypeName, 'system_audit_entries'));
final roleDefinitionSyncProcessorProvider = Provider<RoleDefinitionSyncProcessor>((ref) => _processor(ref, RoleDefinition.entityTypeName, 'role_definitions'));
final permissionAssignmentSyncProcessorProvider = Provider<PermissionAssignmentSyncProcessor>((ref) => _processor(ref, PermissionAssignment.entityTypeName, 'permission_assignments'));
final systemHealthSyncProcessorProvider = Provider<SystemHealthSyncProcessor>((ref) => _processor(ref, SystemHealthSnapshot.entityTypeName, 'system_health_snapshots'));
final errorLogSyncProcessorProvider = Provider<ErrorLogSyncProcessor>((ref) => _processor(ref, ErrorLogEntry.entityTypeName, 'error_log_entries'));
final backgroundJobSyncProcessorProvider = Provider<BackgroundJobSyncProcessor>((ref) => _processor(ref, BackgroundJobStatus.entityTypeName, 'background_job_status'));
final syncMonitorSyncProcessorProvider = Provider<SyncMonitorSyncProcessor>((ref) => _processor(ref, SyncMonitorSnapshot.entityTypeName, 'sync_monitor_snapshots'));
final storageMonitorSyncProcessorProvider = Provider<StorageMonitorSyncProcessor>((ref) => _processor(ref, StorageUsageSnapshot.entityTypeName, 'storage_usage_snapshots'));
final licenseRecordSyncProcessorProvider = Provider<LicenseRecordSyncProcessor>((ref) => _processor(ref, LicenseRecord.entityTypeName, 'license_records'));
final subscriptionRecordSyncProcessorProvider = Provider<SubscriptionRecordSyncProcessor>((ref) => _processor(ref, SubscriptionRecord.entityTypeName, 'subscription_records'));
final environmentSettingSyncProcessorProvider = Provider<EnvironmentSettingSyncProcessor>((ref) => _processor(ref, EnvironmentSetting.entityTypeName, 'environment_settings'));
final securitySessionSyncProcessorProvider = Provider<SecuritySessionSyncProcessor>((ref) => _processor(ref, SecuritySession.entityTypeName, 'security_sessions'));
final deviceRegistrationSyncProcessorProvider = Provider<DeviceRegistrationSyncProcessor>((ref) => _processor(ref, DeviceRegistration.entityTypeName, 'device_registrations'));
final loginHistorySyncProcessorProvider = Provider<LoginHistorySyncProcessor>((ref) => _processor(ref, LoginHistoryEntry.entityTypeName, 'login_history_entries'));
final maintenanceModeSyncProcessorProvider = Provider<MaintenanceModeSyncProcessor>((ref) => _processor(ref, MaintenanceMode.entityTypeName, 'maintenance_modes'));
final systemConfigurationSyncProcessorProvider = Provider<SystemConfigurationSyncProcessor>((ref) => _processor(ref, SystemConfiguration.entityTypeName, 'system_configurations'));
final releaseNoteSyncProcessorProvider = Provider<ReleaseNoteSyncProcessor>((ref) => _processor(ref, ReleaseNote.entityTypeName, 'release_notes'));
final migrationHistorySyncProcessorProvider = Provider<MigrationHistorySyncProcessor>((ref) => _processor(ref, MigrationHistoryEntry.entityTypeName, 'migration_history_entries'));
