import 'package:fashion_pos_enterprise/core/infrastructure/database/app_database.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/pagination/paginated_result.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/repository/base_local_repository.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/repository/repository_query.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/sync/sync_queue_writer.dart';
import 'package:fashion_pos_enterprise/features/system/domain/entities/audit.dart';
import 'package:fashion_pos_enterprise/features/system/domain/entities/feature_flag.dart';
import 'package:fashion_pos_enterprise/features/system/domain/entities/licensing.dart';
import 'package:fashion_pos_enterprise/features/system/domain/entities/monitoring.dart';
import 'package:fashion_pos_enterprise/features/system/domain/entities/release.dart';
import 'package:fashion_pos_enterprise/features/system/domain/entities/roles_permissions.dart';
import 'package:fashion_pos_enterprise/features/system/domain/entities/security.dart';
import 'package:fashion_pos_enterprise/features/system/domain/entities/settings.dart';
import 'package:fashion_pos_enterprise/features/system/domain/enums/system_enums.dart';
import 'package:fashion_pos_enterprise/features/system/domain/repositories/system_repositories.dart';
import 'package:fashion_pos_enterprise/features/system/domain/value_objects/system_value_objects.dart';

typedef SystemEntityMapper<T> = T Function(Map<String, dynamic> json, LocalRecord record);

class SystemRepositoryImpl<T extends SyncableEntity> extends BaseLocalRepository<T> {
  SystemRepositoryImpl({
    required AppDatabase database,
    required SyncQueueWriter syncQueue,
    required String entityType,
    required this.fromPayload,
    required this.toSearchFields,
  })  : _database = database,
        _syncQueue = syncQueue,
        super(database: database, entityType: entityType, syncQueue: syncQueue);

  final AppDatabase _database;
  final SyncQueueWriter _syncQueue;
  final SystemEntityMapper<T> fromPayload;
  final ({String? name, String? sku, String? barcode, String? storeId}) Function(T entity) toSearchFields;

  @override
  T mapFromLocalRecord(LocalRecord record) => fromPayload(record.payload, record);

  @override
  LocalRecord mapToLocalRecord(T entity) {
    final search = toSearchFields(entity);
    return LocalRecord(
      id: entity.id,
      tenantId: entity.tenantId,
      entityType: entity.entityType,
      storeId: search.storeId,
      payload: entity.toPayload(),
      version: entity.version,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      deletedAt: entity.deletedAt,
      syncStatus: entity.syncStatus,
      isDirty: entity.isDirty,
      searchName: search.name,
      searchSku: search.sku,
      searchBarcode: search.barcode,
    );
  }

  SystemRepositoryImpl<R> child<R extends SyncableEntity>({
    required String entityType,
    required SystemEntityMapper<R> fromPayload,
    required ({String? name, String? sku, String? barcode, String? storeId}) Function(R) toSearch,
  }) =>
      SystemRepositoryImpl<R>(
        database: _database,
        syncQueue: _syncQueue,
        entityType: entityType,
        fromPayload: fromPayload,
        toSearchFields: toSearch,
      );
}

class FeatureFlagLocalRepository extends SystemRepositoryImpl<FeatureFlag> implements FeatureFlagRepository {
  FeatureFlagLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: FeatureFlag.entityTypeName,
          fromPayload: FeatureFlag.fromPayload,
          toSearchFields: (e) => (name: e.key, sku: null, barcode: null, storeId: null),
        );

  @override
  Future<FeatureFlag?> getByKey(String tenantId, String key) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    for (final f in page.items) {
      if (f.key == key) return f;
    }
    return null;
  }

  @override
  Future<List<FeatureFlag>> listEnabled(String tenantId) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    return page.items.where((f) => f.enabled).toList();
  }
}

class SystemAuditLocalRepository extends SystemRepositoryImpl<SystemAuditEntry> implements SystemAuditRepository {
  SystemAuditLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: SystemAuditEntry.entityTypeName,
          fromPayload: SystemAuditEntry.fromPayload,
          toSearchFields: (e) => (name: e.entityType, sku: e.entityId, barcode: e.action, storeId: e.storeId),
        );

  @override
  Future<PaginatedResult<SystemAuditEntry>> search(String tenantId, AuditExplorerFilter filter) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, page: filter.page, pageSize: filter.pageSize));
    var items = page.items;
    if (filter.entityType != null) items = items.where((e) => e.entityType == filter.entityType).toList();
    if (filter.entityId != null) items = items.where((e) => e.entityId == filter.entityId).toList();
    if (filter.employeeId != null) items = items.where((e) => e.employeeId == filter.employeeId).toList();
    if (filter.action != null) items = items.where((e) => e.action == filter.action).toList();
    if (filter.from != null) items = items.where((e) => !e.createdAt.isBefore(filter.from!)).toList();
    if (filter.to != null) items = items.where((e) => !e.createdAt.isAfter(filter.to!)).toList();
    return PaginatedResult(items: items, totalCount: items.length, page: filter.page, pageSize: filter.pageSize);
  }
}

class RoleDefinitionLocalRepository extends SystemRepositoryImpl<RoleDefinition> implements RoleDefinitionRepository {
  RoleDefinitionLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: RoleDefinition.entityTypeName,
          fromPayload: RoleDefinition.fromPayload,
          toSearchFields: (e) => (name: e.name, sku: e.code, barcode: null, storeId: null),
        );

  @override
  Future<RoleDefinition?> getByCode(String tenantId, String code) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    for (final r in page.items) {
      if (r.code == code) return r;
    }
    return null;
  }
}

class PermissionAssignmentLocalRepository extends SystemRepositoryImpl<PermissionAssignment>
    implements PermissionAssignmentRepository {
  PermissionAssignmentLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: PermissionAssignment.entityTypeName,
          fromPayload: PermissionAssignment.fromPayload,
          toSearchFields: (e) => (name: e.permissionCode, sku: e.subjectId, barcode: e.subjectType, storeId: null),
        );

  @override
  Future<List<PermissionAssignment>> listBySubject(String tenantId, String subjectType, String subjectId) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    return page.items.where((p) => p.subjectType == subjectType && p.subjectId == subjectId).toList();
  }
}

class SystemHealthLocalRepository extends SystemRepositoryImpl<SystemHealthSnapshot> implements SystemHealthRepository {
  SystemHealthLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: SystemHealthSnapshot.entityTypeName,
          fromPayload: SystemHealthSnapshot.fromPayload,
          toSearchFields: (e) => (name: e.status.value, sku: null, barcode: null, storeId: null),
        );

  @override
  Future<SystemHealthSnapshot?> getLatest(String tenantId) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 1, sortDescending: true));
    return page.items.isEmpty ? null : page.items.first;
  }
}

class ErrorLogLocalRepository extends SystemRepositoryImpl<ErrorLogEntry> implements ErrorLogRepository {
  ErrorLogLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: ErrorLogEntry.entityTypeName,
          fromPayload: ErrorLogEntry.fromPayload,
          toSearchFields: (e) => (name: e.message, sku: e.severity.value, barcode: e.source, storeId: null),
        );

  @override
  Future<List<ErrorLogEntry>> listUnresolved(String tenantId, {int limit = 100}) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: limit));
    return page.items.where((e) => !e.resolved).toList();
  }
}

class BackgroundJobLocalRepository extends SystemRepositoryImpl<BackgroundJobStatus> implements BackgroundJobRepository {
  BackgroundJobLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: BackgroundJobStatus.entityTypeName,
          fromPayload: BackgroundJobStatus.fromPayload,
          toSearchFields: (e) => (name: e.jobName, sku: e.status.value, barcode: null, storeId: null),
        );

  @override
  Future<List<BackgroundJobStatus>> listByStatus(String tenantId, String status) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    return page.items.where((j) => j.status.value == status).toList();
  }
}

class SyncMonitorLocalRepository extends SystemRepositoryImpl<SyncMonitorSnapshot> implements SyncMonitorRepository {
  SyncMonitorLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: SyncMonitorSnapshot.entityTypeName,
          fromPayload: SyncMonitorSnapshot.fromPayload,
          toSearchFields: (e) => (name: e.engineState, sku: null, barcode: null, storeId: null),
        );

  @override
  Future<SyncMonitorSnapshot?> getLatest(String tenantId) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 1, sortDescending: true));
    return page.items.isEmpty ? null : page.items.first;
  }
}

class StorageMonitorLocalRepository extends SystemRepositoryImpl<StorageUsageSnapshot> implements StorageMonitorRepository {
  StorageMonitorLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: StorageUsageSnapshot.entityTypeName,
          fromPayload: StorageUsageSnapshot.fromPayload,
          toSearchFields: (e) => (name: 'storage', sku: null, barcode: null, storeId: null),
        );

  @override
  Future<StorageUsageSnapshot?> getLatest(String tenantId) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 1, sortDescending: true));
    return page.items.isEmpty ? null : page.items.first;
  }
}

class LicenseRecordLocalRepository extends SystemRepositoryImpl<LicenseRecord> implements LicenseRecordRepository {
  LicenseRecordLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: LicenseRecord.entityTypeName,
          fromPayload: LicenseRecord.fromPayload,
          toSearchFields: (e) => (name: e.licenseKey, sku: e.planCode, barcode: e.status.value, storeId: null),
        );

  @override
  Future<LicenseRecord?> getActive(String tenantId) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 50));
    for (final l in page.items) {
      if (l.status == LicenseStatus.valid || l.status == LicenseStatus.gracePeriod) return l;
    }
    return page.items.isEmpty ? null : page.items.first;
  }
}

class SubscriptionRecordLocalRepository extends SystemRepositoryImpl<SubscriptionRecord>
    implements SubscriptionRecordRepository {
  SubscriptionRecordLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: SubscriptionRecord.entityTypeName,
          fromPayload: SubscriptionRecord.fromPayload,
          toSearchFields: (e) => (name: e.planCode, sku: e.status.value, barcode: e.externalId, storeId: null),
        );

  @override
  Future<SubscriptionRecord?> getCurrent(String tenantId) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 10, sortDescending: true));
    return page.items.isEmpty ? null : page.items.first;
  }
}

class EnvironmentSettingLocalRepository extends SystemRepositoryImpl<EnvironmentSetting>
    implements EnvironmentSettingRepository {
  EnvironmentSettingLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: EnvironmentSetting.entityTypeName,
          fromPayload: EnvironmentSetting.fromPayload,
          toSearchFields: (e) => (name: e.key, sku: e.environment.value, barcode: null, storeId: null),
        );

  @override
  Future<EnvironmentSetting?> getByKey(String tenantId, String key) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    for (final s in page.items) {
      if (s.key == key) return s;
    }
    return null;
  }

  @override
  Future<List<EnvironmentSetting>> listByEnvironment(String tenantId, String environment) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    return page.items.where((s) => s.environment.value == environment).toList();
  }
}

class SecuritySessionLocalRepository extends SystemRepositoryImpl<SecuritySession> implements SecuritySessionRepository {
  SecuritySessionLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: SecuritySession.entityTypeName,
          fromPayload: SecuritySession.fromPayload,
          toSearchFields: (e) => (name: e.userId, sku: e.deviceId, barcode: e.status.value, storeId: null),
        );

  @override
  Future<List<SecuritySession>> listActive(String tenantId) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    return page.items.where((s) => s.status == SessionStatus.active).toList();
  }
}

class DeviceRegistrationLocalRepository extends SystemRepositoryImpl<DeviceRegistration>
    implements DeviceRegistrationRepository {
  DeviceRegistrationLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: DeviceRegistration.entityTypeName,
          fromPayload: DeviceRegistration.fromPayload,
          toSearchFields: (e) => (name: e.deviceName, sku: e.platform, barcode: e.trustLevel.value, storeId: null),
        );

  @override
  Future<List<DeviceRegistration>> listTrusted(String tenantId) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    return page.items.where((d) => d.trustLevel == DeviceTrustLevel.trusted).toList();
  }
}

class LoginHistoryLocalRepository extends SystemRepositoryImpl<LoginHistoryEntry> implements LoginHistoryRepository {
  LoginHistoryLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: LoginHistoryEntry.entityTypeName,
          fromPayload: LoginHistoryEntry.fromPayload,
          toSearchFields: (e) => (name: e.userId, sku: e.deviceId, barcode: e.ipAddress, storeId: null),
        );

  @override
  Future<List<LoginHistoryEntry>> listRecent(String tenantId, {int limit = 50}) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: limit, sortDescending: true));
    return page.items;
  }
}

class MaintenanceModeLocalRepository extends SystemRepositoryImpl<MaintenanceMode> implements MaintenanceModeRepository {
  MaintenanceModeLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: MaintenanceMode.entityTypeName,
          fromPayload: MaintenanceMode.fromPayload,
          toSearchFields: (e) => (name: e.scope.value, sku: null, barcode: null, storeId: null),
        );

  @override
  Future<MaintenanceMode?> getCurrent(String tenantId) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 10, sortDescending: true));
    return page.items.isEmpty ? null : page.items.first;
  }
}

class SystemConfigurationLocalRepository extends SystemRepositoryImpl<SystemConfiguration>
    implements SystemConfigurationRepository {
  SystemConfigurationLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: SystemConfiguration.entityTypeName,
          fromPayload: SystemConfiguration.fromPayload,
          toSearchFields: (e) => (name: 'config', sku: null, barcode: null, storeId: null),
        );

  @override
  Future<SystemConfiguration?> getForTenant(String tenantId) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 1));
    return page.items.isEmpty ? null : page.items.first;
  }
}

class ReleaseNoteLocalRepository extends SystemRepositoryImpl<ReleaseNote> implements ReleaseNoteRepository {
  ReleaseNoteLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: ReleaseNote.entityTypeName,
          fromPayload: ReleaseNote.fromPayload,
          toSearchFields: (e) => (name: e.title, sku: e.appVersion, barcode: null, storeId: null),
        );

  @override
  Future<List<ReleaseNote>> listPublished(String tenantId, {int limit = 20}) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: limit, sortDescending: true));
    return page.items.where((n) => n.isPublished).toList();
  }
}

class MigrationHistoryLocalRepository extends SystemRepositoryImpl<MigrationHistoryEntry>
    implements MigrationHistoryRepository {
  MigrationHistoryLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: MigrationHistoryEntry.entityTypeName,
          fromPayload: MigrationHistoryEntry.fromPayload,
          toSearchFields: (e) => (name: e.migrationName, sku: e.status.value, barcode: null, storeId: null),
        );

  @override
  Future<List<MigrationHistoryEntry>> listRecent(String tenantId, {int limit = 50}) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: limit, sortDescending: true));
    return page.items;
  }
}
