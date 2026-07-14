import 'package:fashion_pos_enterprise/core/infrastructure/repository/base_local_repository.dart';
import 'package:fashion_pos_enterprise/features/admin/domain/entities/licensing.dart';
import 'package:fashion_pos_enterprise/features/admin/domain/entities/organization.dart';
import 'package:fashion_pos_enterprise/features/admin/domain/entities/settings.dart';
import 'package:fashion_pos_enterprise/features/admin/domain/entities/users_roles.dart';
import 'package:fashion_pos_enterprise/features/admin/domain/enums/admin_enums.dart';

abstract class CompanyRepository implements BaseLocalRepository<Company> {
  Future<List<Company>> listActive(String tenantId);
}

abstract class BranchRepository implements BaseLocalRepository<Branch> {
  Future<List<Branch>> listByCompany(String tenantId, String companyId);
}

abstract class StoreRepository implements BaseLocalRepository<Store> {
  Future<List<Store>> listByBranch(String tenantId, String branchId);
}

abstract class WarehouseAdminRepository implements BaseLocalRepository<WarehouseAdmin> {
  Future<List<WarehouseAdmin>> listActive(String tenantId);
}

abstract class DepartmentRepository implements BaseLocalRepository<Department> {
  Future<List<Department>> listActive(String tenantId);
}

abstract class TeamRepository implements BaseLocalRepository<Team> {
  Future<List<Team>> listByDepartment(String tenantId, String departmentId);
}

abstract class BusinessUnitRepository implements BaseLocalRepository<BusinessUnit> {
  Future<List<BusinessUnit>> listActive(String tenantId);
}

abstract class CostCenterAdminRepository implements BaseLocalRepository<CostCenterAdmin> {
  Future<List<CostCenterAdmin>> listActive(String tenantId);
}

abstract class AdminUserRepository implements BaseLocalRepository<AdminUser> {
  Future<List<AdminUser>> listByStatus(String tenantId, AdminUserStatus status);
}

abstract class RoleTemplateRepository implements BaseLocalRepository<RoleTemplate> {
  Future<List<RoleTemplate>> listActive(String tenantId);
}

abstract class UserGroupRepository implements BaseLocalRepository<UserGroup> {
  Future<List<UserGroup>> listActive(String tenantId);
}

abstract class PermissionAssignmentUIRepository implements BaseLocalRepository<PermissionAssignmentUI> {
  Future<List<PermissionAssignmentUI>> listBySubject(String tenantId, String subjectId);
}

abstract class TenantSettingsRepository implements BaseLocalRepository<TenantSettings> {
  Future<TenantSettings?> getByScope(String tenantId, SettingsScope scope);
}

abstract class TenantBrandingRepository implements BaseLocalRepository<TenantBranding> {
  Future<TenantBranding?> getCurrent(String tenantId);
}

abstract class EnterpriseSettingsRepository implements BaseLocalRepository<EnterpriseSettings> {
  Future<EnterpriseSettings?> getConfig(String tenantId);
}

abstract class LicenseRecordRepository implements BaseLocalRepository<LicenseRecord> {
  Future<LicenseRecord?> getCurrent(String tenantId);
}

abstract class SubscriptionPlanRepository implements BaseLocalRepository<SubscriptionPlan> {
  Future<SubscriptionPlan?> getById(String id, {required String tenantId});
}

abstract class UsageSnapshotRepository implements BaseLocalRepository<UsageSnapshot> {
  Future<UsageSnapshot?> getLatest(String tenantId);
}

abstract class StorageUsageRepository implements BaseLocalRepository<StorageUsage> {
  Future<StorageUsage?> getLatest(String tenantId);
}

abstract class ApiUsageRepository implements BaseLocalRepository<ApiUsage> {
  Future<List<ApiUsage>> listByPeriod(String tenantId, DateTime since);
}
