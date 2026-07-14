import 'package:uuid/uuid.dart';

import 'package:fashion_pos_enterprise/core/audit/audit_action.dart';
import 'package:fashion_pos_enterprise/core/audit/audit_service.dart';
import 'package:fashion_pos_enterprise/core/business/engines/admin/administration_engine.dart';
import 'package:fashion_pos_enterprise/core/errors/failure.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/database/app_database.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/pagination/paginated_result.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/repository/repository_query.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/sync/sync_coordinator.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_engine.dart';
import 'package:fashion_pos_enterprise/core/result/result.dart';
import 'package:fashion_pos_enterprise/features/admin/domain/entities/licensing.dart';
import 'package:fashion_pos_enterprise/features/admin/domain/entities/organization.dart';
import 'package:fashion_pos_enterprise/features/admin/domain/entities/settings.dart';
import 'package:fashion_pos_enterprise/features/admin/domain/entities/users_roles.dart';
import 'package:fashion_pos_enterprise/features/admin/domain/enums/admin_enums.dart';
import 'package:fashion_pos_enterprise/features/admin/domain/repositories/admin_repositories.dart';
import 'package:fashion_pos_enterprise/features/admin/domain/value_objects/admin_value_objects.dart';
import 'package:fashion_pos_enterprise/features/auth/domain/entities/auth_user.dart';
import 'package:fashion_pos_enterprise/features/system/domain/repositories/system_repositories.dart' as system_repos;
import 'package:fashion_pos_enterprise/features/system/domain/services/system_services.dart';

class OrganizationService {
  OrganizationService({
    required CompanyRepository companies,
    required BranchRepository branches,
    required StoreRepository stores,
    required DepartmentRepository departments,
    required TeamRepository teams,
    required AdministrationEngine engine,
    required AuditService audit,
    required PermissionEngine permissions,
    Uuid? uuid,
  })  : _companies = companies,
        _branches = branches,
        _stores = stores,
        _departments = departments,
        _teams = teams,
        _engine = engine,
        _audit = audit,
        _permissions = permissions,
        _uuid = uuid ?? const Uuid();

  final CompanyRepository _companies;
  final BranchRepository _branches;
  final StoreRepository _stores;
  final DepartmentRepository _departments;
  final TeamRepository _teams;
  final AdministrationEngine _engine;
  final AuditService _audit;
  final PermissionEngine _permissions;
  final Uuid _uuid;

  Future<Result<AdminDashboardMetrics>> dashboard({required AuthUser user}) async {
    try {
      _permissions.require(user, EnterpriseAdminPermissions.view);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final tenantId = user.tenantId!;
    final companies = await _companies.listActive(tenantId);
    final users = await _departments.listActive(tenantId);
    return Success(AdminDashboardMetrics(
      companies: companies.length,
      activeUsers: users.length,
      pendingInvites: 0,
      healthScore: 100,
      licenseDaysRemaining: 30,
    ));
  }

  Future<Result<Company>> createCompany({required AuthUser user, required OrganizationInput input}) async {
    try {
      _permissions.require(user, OrganizationPermissions.manage);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final validation = _engine.validateOrganization(input);
    if (!validation.isValid) {
      return Error(ValidationFailure(message: validation.errors.join(', '), code: 'validation_failed'));
    }
    final tenantId = user.tenantId!;
    final now = DateTime.now().toUtc();
    final company = await _companies.create(Company(
      id: _uuid.v4(),
      tenantId: tenantId,
      name: input.name,
      code: input.code,
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    ));
    await _audit.log(
      action: AuditAction.create,
      entityType: Company.entityTypeName,
      tenantId: tenantId,
      employeeId: user.employeeId,
      entityId: company.id,
    );
    return Success(company);
  }

  Future<PaginatedResult<Company>> listCompanies(String tenantId) =>
      _companies.getPage(RepositoryQuery(tenantId: tenantId, pageSize: 200));

  Future<List<Branch>> listBranches(String tenantId, String companyId) => _branches.listByCompany(tenantId, companyId);

  Future<List<Store>> listStores(String tenantId, String branchId) => _stores.listByBranch(tenantId, branchId);

  Future<List<Department>> listDepartments(String tenantId) => _departments.listActive(tenantId);

  Future<List<Team>> listTeams(String tenantId, String departmentId) => _teams.listByDepartment(tenantId, departmentId);
}

class UserAdminService {
  UserAdminService({
    required AdminUserRepository users,
    required AdministrationEngine engine,
    required AuditService audit,
    required PermissionEngine permissions,
    Uuid? uuid,
  })  : _users = users,
        _engine = engine,
        _audit = audit,
        _permissions = permissions,
        _uuid = uuid ?? const Uuid();

  final AdminUserRepository _users;
  final AdministrationEngine _engine;
  final AuditService _audit;
  final PermissionEngine _permissions;
  final Uuid _uuid;

  Future<Result<List<AdminUser>>> list(AuthUser user) async {
    try {
      _permissions.require(user, UserAdminPermissions.admin);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final page = await _users.getPage(RepositoryQuery(tenantId: user.tenantId!, pageSize: 500));
    return Success(page.items);
  }

  Future<Result<AdminUser>> invite({
    required AuthUser user,
    required String email,
    required String displayName,
  }) async {
    try {
      _permissions.require(user, UserAdminPermissions.admin);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final tenantId = user.tenantId!;
    final validation = _engine.validateTenant(TenantValidationInput(
      tenantId: tenantId,
      currentUsers: 0,
      maxUsers: 1000,
      usedStorageMb: 0,
      maxStorageMb: 10000,
    ));
    if (!validation.isValid) {
      return Error(ValidationFailure(message: validation.errors.join(', '), code: 'tenant_limit'));
    }
    final now = DateTime.now().toUtc();
    final adminUser = await _users.create(AdminUser(
      id: _uuid.v4(),
      tenantId: tenantId,
      email: email,
      displayName: displayName,
      status: AdminUserStatus.invited,
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    ));
    await _audit.log(
      action: AuditAction.create,
      entityType: AdminUser.entityTypeName,
      tenantId: tenantId,
      employeeId: user.employeeId,
      entityId: adminUser.id,
    );
    return Success(adminUser);
  }
}

class RoleAdminService {
  RoleAdminService({
    required RoleTemplateRepository roles,
    required PermissionAssignmentUIRepository assignments,
    required AdministrationEngine engine,
    required AuditService audit,
    required PermissionEngine permissions,
    Uuid? uuid,
  })  : _roles = roles,
        _assignments = assignments,
        _engine = engine,
        _audit = audit,
        _permissions = permissions,
        _uuid = uuid ?? const Uuid();

  final RoleTemplateRepository _roles;
  final PermissionAssignmentUIRepository _assignments;
  final AdministrationEngine _engine;
  final AuditService _audit;
  final PermissionEngine _permissions;
  final Uuid _uuid;

  Future<Result<List<RoleTemplate>>> list(AuthUser user) async {
    try {
      _permissions.require(user, RoleAdminPermissions.admin);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    return Success(await _roles.listActive(user.tenantId!));
  }

  Future<Result<RoleTemplate>> create({
    required AuthUser user,
    required String name,
    required List<String> permissionCodes,
  }) async {
    try {
      _permissions.require(user, RoleAdminPermissions.admin);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final validation = _engine.validateRoleAssignment(RoleAssignmentInput(
      roleId: name,
      permissionCodes: permissionCodes,
    ));
    if (!validation.isValid) {
      return Error(ValidationFailure(message: validation.errors.join(', '), code: 'validation_failed'));
    }
    final tenantId = user.tenantId!;
    final now = DateTime.now().toUtc();
    final role = await _roles.create(RoleTemplate(
      id: _uuid.v4(),
      tenantId: tenantId,
      name: name,
      permissionCodes: permissionCodes,
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    ));
    return Success(role);
  }

  Future<Result<List<PermissionAssignmentUI>>> listAssignments(AuthUser user, String subjectId) async {
    try {
      _permissions.require(user, RoleAdminPermissions.admin);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    return Success(await _assignments.listBySubject(user.tenantId!, subjectId));
  }
}

class TenantSettingsService {
  TenantSettingsService({
    required TenantSettingsRepository settings,
    required EnterpriseSettingsRepository enterprise,
    required AdministrationEngine engine,
    required PermissionEngine permissions,
    Uuid? uuid,
  })  : _settings = settings,
        _enterprise = enterprise,
        _engine = engine,
        _permissions = permissions,
        _uuid = uuid ?? const Uuid();

  final TenantSettingsRepository _settings;
  final EnterpriseSettingsRepository _enterprise;
  final AdministrationEngine _engine;
  final PermissionEngine _permissions;
  final Uuid _uuid;

  Future<Result<TenantSettings>> get(AuthUser user) async {
    try {
      _permissions.require(user, TenantSettingsPermissions.settings);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final existing = await _settings.getByScope(user.tenantId!, SettingsScope.tenant);
    if (existing != null) return Success(existing);
    final now = DateTime.now().toUtc();
    final created = await _settings.create(TenantSettings(
      id: _uuid.v4(),
      tenantId: user.tenantId!,
      values: const {},
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    ));
    return Success(created);
  }

  Future<Result<TenantSettings>> update(AuthUser user, SettingsUpdateInput input) async {
    try {
      _permissions.require(user, TenantSettingsPermissions.settings);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final validation = _engine.validateConfig(input.values, requiredKeys: const []);
    if (!validation.isValid) {
      return Error(ValidationFailure(message: validation.errors.join(', '), code: 'validation_failed'));
    }
    final current = await get(user);
    if (current.isFailure) return current;
    final settings = current.dataOrNull!;
    final updated = await _settings.update(settings.copyWith(
      values: {...settings.values, ...input.values},
      updatedAt: DateTime.now().toUtc(),
      isDirty: true,
      syncStatus: LocalSyncStatus.pending,
    ));
    return Success(updated);
  }

  LocalizationSettings localization(TenantSettings settings) =>
      LocalizationSettings.fromMap(Map<String, dynamic>.from(settings.values['localization'] as Map? ?? {}));

  CurrencySettings currency(TenantSettings settings) =>
      CurrencySettings.fromMap(Map<String, dynamic>.from(settings.values['currency'] as Map? ?? {}));

  FiscalSettings fiscal(TenantSettings settings) =>
      FiscalSettings.fromMap(Map<String, dynamic>.from(settings.values['fiscal'] as Map? ?? {}));

  NumberingSettings numbering(TenantSettings settings) =>
      NumberingSettings.fromMap(Map<String, dynamic>.from(settings.values['numbering'] as Map? ?? {}));
}

extension TenantSettingsCopy on TenantSettings {
  TenantSettings copyWith({
    Map<String, dynamic>? values,
    DateTime? updatedAt,
    LocalSyncStatus? syncStatus,
    bool? isDirty,
  }) =>
      TenantSettings(
        id: id,
        tenantId: tenantId,
        scope: scope,
        values: values ?? this.values,
        version: version,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt,
        syncStatus: syncStatus ?? this.syncStatus,
        isDirty: isDirty ?? this.isDirty,
      );
}

class BrandingService {
  BrandingService({
    required TenantBrandingRepository branding,
    required PermissionEngine permissions,
    Uuid? uuid,
  })  : _branding = branding,
        _permissions = permissions,
        _uuid = uuid ?? const Uuid();

  final TenantBrandingRepository _branding;
  final PermissionEngine _permissions;
  final Uuid _uuid;

  Future<Result<TenantBranding>> get(AuthUser user) async {
    try {
      _permissions.require(user, TenantSettingsPermissions.settings);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final existing = await _branding.getCurrent(user.tenantId!);
    if (existing != null) return Success(existing);
    final now = DateTime.now().toUtc();
    final created = await _branding.create(TenantBranding(
      id: _uuid.v4(),
      tenantId: user.tenantId!,
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    ));
    return Success(created);
  }

  Future<Result<TenantBranding>> update(AuthUser user, BrandingInput input) async {
    try {
      _permissions.require(user, TenantSettingsPermissions.settings);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final current = await get(user);
    if (current.isFailure) return current;
    final b = current.dataOrNull!;
    final updated = await _branding.update(TenantBranding(
      id: b.id,
      tenantId: b.tenantId,
      logoUrl: input.logoUrl ?? b.logoUrl,
      primaryColor: input.primaryColor ?? b.primaryColor,
      accentColor: input.accentColor ?? b.accentColor,
      companyName: input.companyName ?? b.companyName,
      version: b.version,
      createdAt: b.createdAt,
      updatedAt: DateTime.now().toUtc(),
      deletedAt: b.deletedAt,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    ));
    return Success(updated);
  }
}

class LicenseAdminService {
  LicenseAdminService({
    required LicenseRecordRepository licenses,
    required SubscriptionPlanRepository plans,
    required AdministrationEngine engine,
    required PermissionEngine permissions,
  })  : _licenses = licenses,
        _plans = plans,
        _engine = engine,
        _permissions = permissions;

  final LicenseRecordRepository _licenses;
  final SubscriptionPlanRepository _plans;
  final AdministrationEngine _engine;
  final PermissionEngine _permissions;

  Future<Result<LicenseRecord?>> current(AuthUser user) async {
    try {
      _permissions.require(user, EnterpriseAdminPermissions.manage);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    return Success(await _licenses.getCurrent(user.tenantId!));
  }

  Future<Result<LicenseValidation>> validate(AuthUser user) async {
    try {
      _permissions.require(user, EnterpriseAdminPermissions.view);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final license = await _licenses.getCurrent(user.tenantId!);
    if (license == null) {
      return const Success(LicenseValidation(isValid: false, daysRemaining: 0, reason: 'No license'));
    }
    return Success(_engine.validateLicense(status: license.status, expiresAt: license.expiresAt));
  }
}

class UsageDashboardService {
  UsageDashboardService({
    required UsageSnapshotRepository snapshots,
    required StorageUsageRepository storage,
    required ApiUsageRepository apiUsage,
    required AdminUserRepository users,
    required SubscriptionPlanRepository plans,
    required LicenseRecordRepository licenses,
    required AdministrationEngine engine,
    required PermissionEngine permissions,
  })  : _snapshots = snapshots,
        _storage = storage,
        _apiUsage = apiUsage,
        _users = users,
        _plans = plans,
        _licenses = licenses,
        _engine = engine,
        _permissions = permissions;

  final UsageSnapshotRepository _snapshots;
  final StorageUsageRepository _storage;
  final ApiUsageRepository _apiUsage;
  final AdminUserRepository _users;
  final SubscriptionPlanRepository _plans;
  final LicenseRecordRepository _licenses;
  final AdministrationEngine _engine;
  final PermissionEngine _permissions;

  Future<Result<UsageSummary>> summary(AuthUser user) async {
    try {
      _permissions.require(user, EnterpriseAdminPermissions.view);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final tenantId = user.tenantId!;
    final snapshot = await _snapshots.getLatest(tenantId);
    final storage = await _storage.getLatest(tenantId);
    final license = await _licenses.getCurrent(tenantId);
    SubscriptionPlan? plan;
    if (license != null) {
      plan = await _plans.getById(license.planId, tenantId: tenantId);
    }
    final activeUsers = snapshot?.activeUsers ?? 0;
    final storageUsed = storage?.usedMb ?? snapshot?.storageUsedMb ?? 0;
    final apiCalls = snapshot?.apiCalls ?? 0;
    return Success(_engine.calculateUsage(
      activeUsers: activeUsers,
      licensedUsers: plan?.maxUsers ?? license?.seats ?? 10,
      storageUsedMb: storageUsed,
      storageLimitMb: (plan?.maxStorageMb ?? 1024).toDouble(),
      apiCallsToday: apiCalls,
      apiLimitDaily: plan?.maxApiCallsDaily ?? 10000,
    ));
  }

  Future<Result<List<ApiUsage>>> apiBreakdown(AuthUser user) async {
    try {
      _permissions.require(user, EnterpriseAdminPermissions.view);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final since = DateTime.now().toUtc().subtract(const Duration(days: 7));
    return Success(await _apiUsage.listByPeriod(user.tenantId!, since));
  }

  Future<Result<StorageUsage?>> storage(AuthUser user) async {
    try {
      _permissions.require(user, EnterpriseAdminPermissions.view);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    return Success(await _storage.getLatest(user.tenantId!));
  }
}

class AdminDiagnosticsService {
  AdminDiagnosticsService({
    required AppDatabase database,
    required SyncCoordinator syncCoordinator,
    required system_repos.SystemHealthRepository health,
    required system_repos.ErrorLogRepository errors,
    required system_repos.MaintenanceModeRepository maintenance,
    required system_repos.StorageMonitorRepository storage,
    required AuditExplorerService auditExplorer,
    required DiagnosticsService systemDiagnostics,
    required AdministrationEngine engine,
    required PermissionEngine permissions,
  })  : _db = database,
        _sync = syncCoordinator,
        _health = health,
        _errors = errors,
        _maintenance = maintenance,
        _storage = storage,
        _auditExplorer = auditExplorer,
        _systemDiagnostics = systemDiagnostics,
        _engine = engine,
        _permissions = permissions;

  final AppDatabase _db;
  final SyncCoordinator _sync;
  final system_repos.SystemHealthRepository _health;
  final system_repos.ErrorLogRepository _errors;
  final system_repos.MaintenanceModeRepository _maintenance;
  final system_repos.StorageMonitorRepository _storage;
  final AuditExplorerService _auditExplorer;
  final DiagnosticsService _systemDiagnostics;
  final AdministrationEngine _engine;
  final PermissionEngine _permissions;

  AuditExplorerService get auditExplorer => _auditExplorer;

  DiagnosticsService get systemDiagnostics => _systemDiagnostics;

  Future<Result<HealthAssessment>> health(AuthUser user) async {
    try {
      _permissions.require(user, EnterpriseAdminPermissions.view);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final tenantId = user.tenantId!;
    final pending = await _db.syncQueueDao.countPending();
    final unresolved = await _errors.listUnresolved(tenantId);
    final maintenance = await _maintenance.getCurrent(tenantId);
    final storageSnap = await _storage.getLatest(tenantId);
    final utilization = _engine.calculateStorageQuotaPercent(
      usedMb: storageSnap?.totalMb ?? 0,
      limitMb: 10240,
    );
    return Success(_engine.assessHealth(
      openErrors: unresolved.length,
      pendingSyncItems: pending,
      storageUtilizationPercent: utilization,
      maintenanceActive: maintenance?.active ?? false,
    ));
  }
}
