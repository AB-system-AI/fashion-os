import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fashion_pos_enterprise/core/audit/audit_providers.dart';
import 'package:fashion_pos_enterprise/core/business/di/business_providers.dart';
import 'package:fashion_pos_enterprise/core/di/enterprise_providers.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/features/admin/data/datasources/admin_remote_datasource.dart';
import 'package:fashion_pos_enterprise/features/admin/data/repositories/admin_repository_impl.dart';
import 'package:fashion_pos_enterprise/features/admin/data/sync/admin_sync_processor.dart';
import 'package:fashion_pos_enterprise/features/admin/domain/entities/licensing.dart';
import 'package:fashion_pos_enterprise/features/admin/domain/entities/organization.dart';
import 'package:fashion_pos_enterprise/features/admin/domain/entities/settings.dart';
import 'package:fashion_pos_enterprise/features/admin/domain/entities/users_roles.dart';
import 'package:fashion_pos_enterprise/features/admin/domain/repositories/admin_repositories.dart';
import 'package:fashion_pos_enterprise/features/admin/domain/services/admin_services.dart';
import 'package:fashion_pos_enterprise/features/system/presentation/providers/system_providers.dart' as system_providers;

final adminRemoteDataSourceProvider = Provider<AdminRemoteDataSource>((ref) => AdminRemoteDataSource());

AdminSyncProcessor _processor(Ref ref, String entityType, String table) => AdminSyncProcessor(
      remote: ref.watch(adminRemoteDataSourceProvider),
      entityTypeName: entityType,
      remoteTable: table,
    );

final companyRepositoryProvider = Provider<CompanyRepository>((ref) {
  return CompanyLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final branchRepositoryProvider = Provider<BranchRepository>((ref) {
  return BranchLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final storeRepositoryProvider = Provider<StoreRepository>((ref) {
  return StoreLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final warehouseAdminRepositoryProvider = Provider<WarehouseAdminRepository>((ref) {
  return WarehouseAdminLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final departmentRepositoryProvider = Provider<DepartmentRepository>((ref) {
  return DepartmentLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final teamRepositoryProvider = Provider<TeamRepository>((ref) {
  return TeamLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final businessUnitRepositoryProvider = Provider<BusinessUnitRepository>((ref) {
  return BusinessUnitLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final costCenterAdminRepositoryProvider = Provider<CostCenterAdminRepository>((ref) {
  return CostCenterAdminLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final adminUserRepositoryProvider = Provider<AdminUserRepository>((ref) {
  return AdminUserLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final roleTemplateRepositoryProvider = Provider<RoleTemplateRepository>((ref) {
  return RoleTemplateLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final userGroupRepositoryProvider = Provider<UserGroupRepository>((ref) {
  return UserGroupLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final permissionAssignmentUIRepositoryProvider = Provider<PermissionAssignmentUIRepository>((ref) {
  return PermissionAssignmentUILocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final tenantSettingsRepositoryProvider = Provider<TenantSettingsRepository>((ref) {
  return TenantSettingsLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final tenantBrandingRepositoryProvider = Provider<TenantBrandingRepository>((ref) {
  return TenantBrandingLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final enterpriseSettingsRepositoryProvider = Provider<EnterpriseSettingsRepository>((ref) {
  return EnterpriseSettingsLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final adminLicenseRecordRepositoryProvider = Provider<LicenseRecordRepository>((ref) {
  return LicenseRecordLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final subscriptionPlanRepositoryProvider = Provider<SubscriptionPlanRepository>((ref) {
  return SubscriptionPlanLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final usageSnapshotRepositoryProvider = Provider<UsageSnapshotRepository>((ref) {
  return UsageSnapshotLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final storageUsageRepositoryProvider = Provider<StorageUsageRepository>((ref) {
  return StorageUsageLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final apiUsageRepositoryProvider = Provider<ApiUsageRepository>((ref) {
  return ApiUsageLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final organizationServiceProvider = Provider<OrganizationService>((ref) => OrganizationService(
      companies: ref.watch(companyRepositoryProvider),
      branches: ref.watch(branchRepositoryProvider),
      stores: ref.watch(storeRepositoryProvider),
      departments: ref.watch(departmentRepositoryProvider),
      teams: ref.watch(teamRepositoryProvider),
      engine: ref.watch(administrationEngineProvider),
      audit: ref.watch(auditServiceProvider),
      permissions: ref.watch(permissionEngineProvider),
    ));

final userAdminServiceProvider = Provider<UserAdminService>((ref) => UserAdminService(
      users: ref.watch(adminUserRepositoryProvider),
      engine: ref.watch(administrationEngineProvider),
      audit: ref.watch(auditServiceProvider),
      permissions: ref.watch(permissionEngineProvider),
    ));

final roleAdminServiceProvider = Provider<RoleAdminService>((ref) => RoleAdminService(
      roles: ref.watch(roleTemplateRepositoryProvider),
      assignments: ref.watch(permissionAssignmentUIRepositoryProvider),
      engine: ref.watch(administrationEngineProvider),
      audit: ref.watch(auditServiceProvider),
      permissions: ref.watch(permissionEngineProvider),
    ));

final tenantSettingsServiceProvider = Provider<TenantSettingsService>((ref) => TenantSettingsService(
      settings: ref.watch(tenantSettingsRepositoryProvider),
      enterprise: ref.watch(enterpriseSettingsRepositoryProvider),
      engine: ref.watch(administrationEngineProvider),
      permissions: ref.watch(permissionEngineProvider),
    ));

final brandingServiceProvider = Provider<BrandingService>((ref) => BrandingService(
      branding: ref.watch(tenantBrandingRepositoryProvider),
      permissions: ref.watch(permissionEngineProvider),
    ));

final licenseAdminServiceProvider = Provider<LicenseAdminService>((ref) => LicenseAdminService(
      licenses: ref.watch(adminLicenseRecordRepositoryProvider),
      plans: ref.watch(subscriptionPlanRepositoryProvider),
      engine: ref.watch(administrationEngineProvider),
      permissions: ref.watch(permissionEngineProvider),
    ));

final usageDashboardServiceProvider = Provider<UsageDashboardService>((ref) => UsageDashboardService(
      snapshots: ref.watch(usageSnapshotRepositoryProvider),
      storage: ref.watch(storageUsageRepositoryProvider),
      apiUsage: ref.watch(apiUsageRepositoryProvider),
      users: ref.watch(adminUserRepositoryProvider),
      plans: ref.watch(subscriptionPlanRepositoryProvider),
      licenses: ref.watch(adminLicenseRecordRepositoryProvider),
      engine: ref.watch(administrationEngineProvider),
      permissions: ref.watch(permissionEngineProvider),
    ));

final adminDiagnosticsServiceProvider = Provider<AdminDiagnosticsService>((ref) => AdminDiagnosticsService(
      database: ref.watch(appDatabaseProvider),
      syncCoordinator: ref.watch(syncCoordinatorProvider),
      health: ref.watch(system_providers.systemHealthRepositoryProvider),
      errors: ref.watch(system_providers.errorLogRepositoryProvider),
      maintenance: ref.watch(system_providers.maintenanceModeRepositoryProvider),
      storage: ref.watch(system_providers.storageMonitorRepositoryProvider),
      auditExplorer: ref.watch(system_providers.auditExplorerServiceProvider),
      systemDiagnostics: ref.watch(system_providers.diagnosticsServiceProvider),
      engine: ref.watch(administrationEngineProvider),
      permissions: ref.watch(permissionEngineProvider),
    ));

final companySyncProcessorProvider = Provider<CompanySyncProcessor>(
  (ref) => _processor(ref, Company.entityTypeName, 'admin_companies'),
);
final branchSyncProcessorProvider = Provider<BranchSyncProcessor>(
  (ref) => _processor(ref, Branch.entityTypeName, 'admin_branches'),
);
final storeSyncProcessorProvider = Provider<StoreSyncProcessor>(
  (ref) => _processor(ref, Store.entityTypeName, 'admin_stores'),
);
final warehouseAdminSyncProcessorProvider = Provider<WarehouseAdminSyncProcessor>(
  (ref) => _processor(ref, WarehouseAdmin.entityTypeName, 'admin_warehouses'),
);
final departmentSyncProcessorProvider = Provider<DepartmentSyncProcessor>(
  (ref) => _processor(ref, Department.entityTypeName, 'admin_departments'),
);
final teamSyncProcessorProvider = Provider<TeamSyncProcessor>(
  (ref) => _processor(ref, Team.entityTypeName, 'admin_teams'),
);
final businessUnitSyncProcessorProvider = Provider<BusinessUnitSyncProcessor>(
  (ref) => _processor(ref, BusinessUnit.entityTypeName, 'admin_business_units'),
);
final costCenterAdminSyncProcessorProvider = Provider<CostCenterAdminSyncProcessor>(
  (ref) => _processor(ref, CostCenterAdmin.entityTypeName, 'admin_cost_centers'),
);
final adminUserSyncProcessorProvider = Provider<AdminUserSyncProcessor>(
  (ref) => _processor(ref, AdminUser.entityTypeName, 'admin_users'),
);
final roleTemplateSyncProcessorProvider = Provider<RoleTemplateSyncProcessor>(
  (ref) => _processor(ref, RoleTemplate.entityTypeName, 'admin_role_templates'),
);
final userGroupSyncProcessorProvider = Provider<UserGroupSyncProcessor>(
  (ref) => _processor(ref, UserGroup.entityTypeName, 'admin_user_groups'),
);
final permissionAssignmentUISyncProcessorProvider = Provider<PermissionAssignmentUISyncProcessor>(
  (ref) => _processor(ref, PermissionAssignmentUI.entityTypeName, 'admin_permission_assignments'),
);
final tenantSettingsSyncProcessorProvider = Provider<TenantSettingsSyncProcessor>(
  (ref) => _processor(ref, TenantSettings.entityTypeName, 'admin_tenant_settings'),
);
final tenantBrandingSyncProcessorProvider = Provider<TenantBrandingSyncProcessor>(
  (ref) => _processor(ref, TenantBranding.entityTypeName, 'admin_tenant_branding'),
);
final enterpriseSettingsSyncProcessorProvider = Provider<EnterpriseSettingsSyncProcessor>(
  (ref) => _processor(ref, EnterpriseSettings.entityTypeName, 'admin_enterprise_config'),
);
final licenseRecordSyncProcessorProvider = Provider<LicenseRecordSyncProcessor>(
  (ref) => _processor(ref, LicenseRecord.entityTypeName, 'admin_license_records'),
);
final subscriptionPlanSyncProcessorProvider = Provider<SubscriptionPlanSyncProcessor>(
  (ref) => _processor(ref, SubscriptionPlan.entityTypeName, 'admin_subscription_plans'),
);
final usageSnapshotSyncProcessorProvider = Provider<UsageSnapshotSyncProcessor>(
  (ref) => _processor(ref, UsageSnapshot.entityTypeName, 'admin_usage_metrics'),
);
final storageUsageSyncProcessorProvider = Provider<StorageUsageSyncProcessor>(
  (ref) => _processor(ref, StorageUsage.entityTypeName, 'admin_storage_usage'),
);
final apiUsageSyncProcessorProvider = Provider<ApiUsageSyncProcessor>(
  (ref) => _processor(ref, ApiUsage.entityTypeName, 'admin_api_usage'),
);
