import 'package:fashion_pos_enterprise/core/infrastructure/pagination/paginated_result.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/repository/base_local_repository.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/repository/repository_query.dart';
import 'package:fashion_pos_enterprise/features/system/domain/entities/audit.dart';
import 'package:fashion_pos_enterprise/features/system/domain/entities/feature_flag.dart';
import 'package:fashion_pos_enterprise/features/system/domain/entities/licensing.dart';
import 'package:fashion_pos_enterprise/features/system/domain/entities/monitoring.dart';
import 'package:fashion_pos_enterprise/features/system/domain/entities/release.dart';
import 'package:fashion_pos_enterprise/features/system/domain/entities/roles_permissions.dart';
import 'package:fashion_pos_enterprise/features/system/domain/entities/security.dart';
import 'package:fashion_pos_enterprise/features/system/domain/entities/settings.dart';
import 'package:fashion_pos_enterprise/features/system/domain/value_objects/system_value_objects.dart';

abstract class FeatureFlagRepository implements BaseLocalRepository<FeatureFlag> {
  Future<FeatureFlag?> getByKey(String tenantId, String key);
  Future<List<FeatureFlag>> listEnabled(String tenantId);
}

abstract class SystemAuditRepository implements BaseLocalRepository<SystemAuditEntry> {
  Future<PaginatedResult<SystemAuditEntry>> search(String tenantId, AuditExplorerFilter filter);
}

abstract class RoleDefinitionRepository implements BaseLocalRepository<RoleDefinition> {
  Future<RoleDefinition?> getByCode(String tenantId, String code);
}

abstract class PermissionAssignmentRepository implements BaseLocalRepository<PermissionAssignment> {
  Future<List<PermissionAssignment>> listBySubject(String tenantId, String subjectType, String subjectId);
}

abstract class SystemHealthRepository implements BaseLocalRepository<SystemHealthSnapshot> {
  Future<SystemHealthSnapshot?> getLatest(String tenantId);
}

abstract class ErrorLogRepository implements BaseLocalRepository<ErrorLogEntry> {
  Future<List<ErrorLogEntry>> listUnresolved(String tenantId, {int limit = 100});
}

abstract class BackgroundJobRepository implements BaseLocalRepository<BackgroundJobStatus> {
  Future<List<BackgroundJobStatus>> listByStatus(String tenantId, String status);
}

abstract class SyncMonitorRepository implements BaseLocalRepository<SyncMonitorSnapshot> {
  Future<SyncMonitorSnapshot?> getLatest(String tenantId);
}

abstract class StorageMonitorRepository implements BaseLocalRepository<StorageUsageSnapshot> {
  Future<StorageUsageSnapshot?> getLatest(String tenantId);
}

abstract class LicenseRecordRepository implements BaseLocalRepository<LicenseRecord> {
  Future<LicenseRecord?> getActive(String tenantId);
}

abstract class SubscriptionRecordRepository implements BaseLocalRepository<SubscriptionRecord> {
  Future<SubscriptionRecord?> getCurrent(String tenantId);
}

abstract class EnvironmentSettingRepository implements BaseLocalRepository<EnvironmentSetting> {
  Future<EnvironmentSetting?> getByKey(String tenantId, String key);
  Future<List<EnvironmentSetting>> listByEnvironment(String tenantId, String environment);
}

abstract class SecuritySessionRepository implements BaseLocalRepository<SecuritySession> {
  Future<List<SecuritySession>> listActive(String tenantId);
}

abstract class DeviceRegistrationRepository implements BaseLocalRepository<DeviceRegistration> {
  Future<List<DeviceRegistration>> listTrusted(String tenantId);
}

abstract class LoginHistoryRepository implements BaseLocalRepository<LoginHistoryEntry> {
  Future<List<LoginHistoryEntry>> listRecent(String tenantId, {int limit = 50});
}

abstract class MaintenanceModeRepository implements BaseLocalRepository<MaintenanceMode> {
  Future<MaintenanceMode?> getCurrent(String tenantId);
}

abstract class SystemConfigurationRepository implements BaseLocalRepository<SystemConfiguration> {
  Future<SystemConfiguration?> getForTenant(String tenantId);
}

abstract class ReleaseNoteRepository implements BaseLocalRepository<ReleaseNote> {
  Future<List<ReleaseNote>> listPublished(String tenantId, {int limit = 20});
}

abstract class MigrationHistoryRepository implements BaseLocalRepository<MigrationHistoryEntry> {
  Future<List<MigrationHistoryEntry>> listRecent(String tenantId, {int limit = 50});
}
