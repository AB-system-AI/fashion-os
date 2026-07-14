import 'package:fashion_pos_enterprise/core/infrastructure/database/app_database.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/repository/base_local_repository.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/repository/repository_query.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/sync/sync_queue_writer.dart';
import 'package:fashion_pos_enterprise/features/admin/domain/entities/licensing.dart';
import 'package:fashion_pos_enterprise/features/admin/domain/entities/organization.dart';
import 'package:fashion_pos_enterprise/features/admin/domain/entities/settings.dart';
import 'package:fashion_pos_enterprise/features/admin/domain/entities/users_roles.dart';
import 'package:fashion_pos_enterprise/features/admin/domain/enums/admin_enums.dart';
import 'package:fashion_pos_enterprise/features/admin/domain/repositories/admin_repositories.dart';

typedef AdminEntityMapper<T> = T Function(Map<String, dynamic> json, LocalRecord record);

class AdminRepositoryImpl<T extends SyncableEntity> extends BaseLocalRepository<T> {
  AdminRepositoryImpl({
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
  final AdminEntityMapper<T> fromPayload;
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
}

class CompanyLocalRepository extends AdminRepositoryImpl<Company> implements CompanyRepository {
  CompanyLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: Company.entityTypeName,
          fromPayload: Company.fromPayload,
          toSearchFields: (e) => (name: e.name, sku: e.code, barcode: null, storeId: null),
        );

  @override
  Future<List<Company>> listActive(String tenantId) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    return page.items.where((c) => c.status == OrgUnitStatus.active).toList();
  }
}

class BranchLocalRepository extends AdminRepositoryImpl<Branch> implements BranchRepository {
  BranchLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: Branch.entityTypeName,
          fromPayload: Branch.fromPayload,
          toSearchFields: (e) => (name: e.name, sku: e.code, barcode: null, storeId: null),
        );

  @override
  Future<List<Branch>> listByCompany(String tenantId, String companyId) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    return page.items.where((b) => b.companyId == companyId).toList();
  }
}

class StoreLocalRepository extends AdminRepositoryImpl<Store> implements StoreRepository {
  StoreLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: Store.entityTypeName,
          fromPayload: Store.fromPayload,
          toSearchFields: (e) => (name: e.name, sku: e.code, barcode: null, storeId: e.id),
        );

  @override
  Future<List<Store>> listByBranch(String tenantId, String branchId) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    return page.items.where((s) => s.branchId == branchId).toList();
  }
}

class WarehouseAdminLocalRepository extends AdminRepositoryImpl<WarehouseAdmin> implements WarehouseAdminRepository {
  WarehouseAdminLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: WarehouseAdmin.entityTypeName,
          fromPayload: WarehouseAdmin.fromPayload,
          toSearchFields: (e) => (name: e.name, sku: e.code, barcode: null, storeId: e.storeId),
        );

  @override
  Future<List<WarehouseAdmin>> listActive(String tenantId) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    return page.items.where((w) => w.status == OrgUnitStatus.active).toList();
  }
}

class DepartmentLocalRepository extends AdminRepositoryImpl<Department> implements DepartmentRepository {
  DepartmentLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: Department.entityTypeName,
          fromPayload: Department.fromPayload,
          toSearchFields: (e) => (name: e.name, sku: null, barcode: null, storeId: null),
        );

  @override
  Future<List<Department>> listActive(String tenantId) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    return page.items.where((d) => d.status == OrgUnitStatus.active).toList();
  }
}

class TeamLocalRepository extends AdminRepositoryImpl<Team> implements TeamRepository {
  TeamLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: Team.entityTypeName,
          fromPayload: Team.fromPayload,
          toSearchFields: (e) => (name: e.name, sku: null, barcode: null, storeId: null),
        );

  @override
  Future<List<Team>> listByDepartment(String tenantId, String departmentId) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    return page.items.where((t) => t.departmentId == departmentId).toList();
  }
}

class BusinessUnitLocalRepository extends AdminRepositoryImpl<BusinessUnit> implements BusinessUnitRepository {
  BusinessUnitLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: BusinessUnit.entityTypeName,
          fromPayload: BusinessUnit.fromPayload,
          toSearchFields: (e) => (name: e.name, sku: e.code, barcode: null, storeId: null),
        );

  @override
  Future<List<BusinessUnit>> listActive(String tenantId) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    return page.items.where((b) => b.status == OrgUnitStatus.active).toList();
  }
}

class CostCenterAdminLocalRepository extends AdminRepositoryImpl<CostCenterAdmin> implements CostCenterAdminRepository {
  CostCenterAdminLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: CostCenterAdmin.entityTypeName,
          fromPayload: CostCenterAdmin.fromPayload,
          toSearchFields: (e) => (name: e.name, sku: e.code, barcode: null, storeId: null),
        );

  @override
  Future<List<CostCenterAdmin>> listActive(String tenantId) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    return page.items.where((c) => c.status == OrgUnitStatus.active).toList();
  }
}

class AdminUserLocalRepository extends AdminRepositoryImpl<AdminUser> implements AdminUserRepository {
  AdminUserLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: AdminUser.entityTypeName,
          fromPayload: AdminUser.fromPayload,
          toSearchFields: (e) => (name: e.displayName, sku: e.email, barcode: null, storeId: null),
        );

  @override
  Future<List<AdminUser>> listByStatus(String tenantId, AdminUserStatus status) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    return page.items.where((u) => u.status == status).toList();
  }
}

class RoleTemplateLocalRepository extends AdminRepositoryImpl<RoleTemplate> implements RoleTemplateRepository {
  RoleTemplateLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: RoleTemplate.entityTypeName,
          fromPayload: RoleTemplate.fromPayload,
          toSearchFields: (e) => (name: e.name, sku: null, barcode: null, storeId: null),
        );

  @override
  Future<List<RoleTemplate>> listActive(String tenantId) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    return page.items;
  }
}

class UserGroupLocalRepository extends AdminRepositoryImpl<UserGroup> implements UserGroupRepository {
  UserGroupLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: UserGroup.entityTypeName,
          fromPayload: UserGroup.fromPayload,
          toSearchFields: (e) => (name: e.name, sku: null, barcode: null, storeId: null),
        );

  @override
  Future<List<UserGroup>> listActive(String tenantId) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    return page.items;
  }
}

class PermissionAssignmentUILocalRepository extends AdminRepositoryImpl<PermissionAssignmentUI>
    implements PermissionAssignmentUIRepository {
  PermissionAssignmentUILocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: PermissionAssignmentUI.entityTypeName,
          fromPayload: PermissionAssignmentUI.fromPayload,
          toSearchFields: (e) => (name: e.subjectId, sku: e.subjectType, barcode: null, storeId: null),
        );

  @override
  Future<List<PermissionAssignmentUI>> listBySubject(String tenantId, String subjectId) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    return page.items.where((p) => p.subjectId == subjectId).toList();
  }
}

class TenantSettingsLocalRepository extends AdminRepositoryImpl<TenantSettings> implements TenantSettingsRepository {
  TenantSettingsLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: TenantSettings.entityTypeName,
          fromPayload: TenantSettings.fromPayload,
          toSearchFields: (e) => (name: e.scope.value, sku: null, barcode: null, storeId: null),
        );

  @override
  Future<TenantSettings?> getByScope(String tenantId, SettingsScope scope) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 50));
    for (final item in page.items) {
      if (item.scope == scope) return item;
    }
    return null;
  }
}

class TenantBrandingLocalRepository extends AdminRepositoryImpl<TenantBranding> implements TenantBrandingRepository {
  TenantBrandingLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: TenantBranding.entityTypeName,
          fromPayload: TenantBranding.fromPayload,
          toSearchFields: (e) => (name: e.companyName, sku: null, barcode: null, storeId: null),
        );

  @override
  Future<TenantBranding?> getCurrent(String tenantId) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 1));
    return page.items.isEmpty ? null : page.items.first;
  }
}

class EnterpriseSettingsLocalRepository extends AdminRepositoryImpl<EnterpriseSettings>
    implements EnterpriseSettingsRepository {
  EnterpriseSettingsLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: EnterpriseSettings.entityTypeName,
          fromPayload: EnterpriseSettings.fromPayload,
          toSearchFields: (e) => (name: 'enterprise', sku: null, barcode: null, storeId: null),
        );

  @override
  Future<EnterpriseSettings?> getConfig(String tenantId) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 1));
    return page.items.isEmpty ? null : page.items.first;
  }
}

class LicenseRecordLocalRepository extends AdminRepositoryImpl<LicenseRecord> implements LicenseRecordRepository {
  LicenseRecordLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: LicenseRecord.entityTypeName,
          fromPayload: LicenseRecord.fromPayload,
          toSearchFields: (e) => (name: e.planId, sku: e.status.value, barcode: null, storeId: null),
        );

  @override
  Future<LicenseRecord?> getCurrent(String tenantId) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 1));
    return page.items.isEmpty ? null : page.items.first;
  }
}

class SubscriptionPlanLocalRepository extends AdminRepositoryImpl<SubscriptionPlan> implements SubscriptionPlanRepository {
  SubscriptionPlanLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: SubscriptionPlan.entityTypeName,
          fromPayload: SubscriptionPlan.fromPayload,
          toSearchFields: (e) => (name: e.name, sku: e.tier.value, barcode: null, storeId: null),
        );

  @override
  Future<SubscriptionPlan?> getById(String id, {required String tenantId}) => super.getById(id, tenantId: tenantId);
}

class UsageSnapshotLocalRepository extends AdminRepositoryImpl<UsageSnapshot> implements UsageSnapshotRepository {
  UsageSnapshotLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: UsageSnapshot.entityTypeName,
          fromPayload: UsageSnapshot.fromPayload,
          toSearchFields: (e) => (name: e.capturedAt.toIso8601String(), sku: null, barcode: null, storeId: null),
        );

  @override
  Future<UsageSnapshot?> getLatest(String tenantId) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 1));
    return page.items.isEmpty ? null : page.items.first;
  }
}

class StorageUsageLocalRepository extends AdminRepositoryImpl<StorageUsage> implements StorageUsageRepository {
  StorageUsageLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: StorageUsage.entityTypeName,
          fromPayload: StorageUsage.fromPayload,
          toSearchFields: (e) => (name: e.bucket, sku: null, barcode: null, storeId: null),
        );

  @override
  Future<StorageUsage?> getLatest(String tenantId) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 1));
    return page.items.isEmpty ? null : page.items.first;
  }
}

class ApiUsageLocalRepository extends AdminRepositoryImpl<ApiUsage> implements ApiUsageRepository {
  ApiUsageLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: ApiUsage.entityTypeName,
          fromPayload: ApiUsage.fromPayload,
          toSearchFields: (e) => (name: e.endpoint, sku: null, barcode: null, storeId: null),
        );

  @override
  Future<List<ApiUsage>> listByPeriod(String tenantId, DateTime since) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    return page.items.where((a) => a.periodStart.isAfter(since)).toList();
  }
}
