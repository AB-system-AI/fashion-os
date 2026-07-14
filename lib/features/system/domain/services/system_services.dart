import 'package:uuid/uuid.dart';

import 'package:fashion_pos_enterprise/core/audit/audit_service.dart';
import 'package:fashion_pos_enterprise/core/config/app_config.dart';
import 'package:fashion_pos_enterprise/core/errors/failure.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/database/app_database.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/feature_flags/feature_flag_service.dart' as core_flags;
import 'package:fashion_pos_enterprise/core/infrastructure/license/license_engine.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/network/network_monitor.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/pagination/paginated_result.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/repository/repository_query.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/sync/sync_coordinator.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_engine.dart';
import 'package:fashion_pos_enterprise/core/result/result.dart';
import 'package:fashion_pos_enterprise/features/auth/domain/entities/auth_user.dart';
import 'package:fashion_pos_enterprise/features/system/domain/entities/audit.dart';
import 'package:fashion_pos_enterprise/features/system/domain/entities/feature_flag.dart';
import 'package:fashion_pos_enterprise/features/system/domain/entities/monitoring.dart';
import 'package:fashion_pos_enterprise/features/system/domain/entities/release.dart';
import 'package:fashion_pos_enterprise/features/system/domain/entities/roles_permissions.dart';
import 'package:fashion_pos_enterprise/features/system/domain/entities/security.dart';
import 'package:fashion_pos_enterprise/features/system/domain/entities/settings.dart';
import 'package:fashion_pos_enterprise/features/system/domain/enums/system_enums.dart';
import 'package:fashion_pos_enterprise/features/system/domain/repositories/system_repositories.dart';
import 'package:fashion_pos_enterprise/features/system/domain/value_objects/system_value_objects.dart';

class SystemDashboardService {
  SystemDashboardService({
    required AppDatabase database,
    required SyncCoordinator syncCoordinator,
    required SystemHealthRepository health,
    required ErrorLogRepository errors,
    required MaintenanceModeRepository maintenance,
    required StorageMonitorRepository storage,
    required SecuritySessionRepository sessions,
    required PermissionEngine permissions,
  })  : _db = database,
        _sync = syncCoordinator,
        _health = health,
        _errors = errors,
        _maintenance = maintenance,
        _storage = storage,
        _sessions = sessions,
        _permissions = permissions;

  final AppDatabase _db;
  final SyncCoordinator _sync;
  final SystemHealthRepository _health;
  final ErrorLogRepository _errors;
  final MaintenanceModeRepository _maintenance;
  final StorageMonitorRepository _storage;
  final SecuritySessionRepository _sessions;
  final PermissionEngine _permissions;

  Future<Result<SystemDashboardMetrics>> load(AuthUser user) async {
    try {
      _permissions.require(user, SystemPermissions.view);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final tenantId = user.tenantId!;
    final pending = await _db.syncQueueDao.countPending();
    final unresolved = await _errors.listUnresolved(tenantId);
    final latestHealth = await _health.getLatest(tenantId);
    final maintenance = await _maintenance.getCurrent(tenantId);
    final storageSnap = await _storage.getLatest(tenantId);
    final activeSessions = await _sessions.listActive(tenantId);
    return Success(SystemDashboardMetrics(
      pendingSyncItems: pending,
      openErrors: unresolved.length,
      healthStatus: latestHealth?.status.value ?? 'unknown',
      maintenanceActive: maintenance?.active ?? false,
      storageUsedMb: storageSnap?.totalMb ?? 0,
      activeSessions: activeSessions.length,
    ));
  }
}

class FeatureFlagService {
  FeatureFlagService({
    required FeatureFlagRepository repository,
    required core_flags.FeatureFlagService coreFlags,
    required PermissionEngine permissions,
    Uuid? uuid,
  })  : _repo = repository,
        _coreFlags = coreFlags,
        _permissions = permissions,
        _uuid = uuid ?? const Uuid();

  final FeatureFlagRepository _repo;
  final core_flags.FeatureFlagService _coreFlags;
  final PermissionEngine _permissions;
  final Uuid _uuid;

  Future<Result<List<FeatureFlag>>> list(AuthUser user) async {
    try {
      _permissions.require(user, FeatureFlagPermissions.manage);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final page = await _repo.getPage(RepositoryQuery(tenantId: user.tenantId!, pageSize: 500));
    return Success(page.items);
  }

  Future<Result<FeatureFlag>> upsert(AuthUser user, {required String key, required bool enabled, String? description}) async {
    try {
      _permissions.require(user, FeatureFlagPermissions.manage);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final tenantId = user.tenantId!;
    final existing = await _repo.getByKey(tenantId, key);
    final now = DateTime.now().toUtc();
    if (existing != null) {
      final updated = await _repo.update(existing.copyWith(enabled: enabled, description: description, updatedAt: now, isDirty: true, syncStatus: LocalSyncStatus.pending));
      return Success(updated);
    }
    final created = await _repo.create(FeatureFlag(
      id: _uuid.v4(),
      tenantId: tenantId,
      key: key,
      enabled: enabled,
      description: description,
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    ));
    return Success(created);
  }

  Future<void> refreshRemote() => _coreFlags.refresh(force: true);
}

class AuditExplorerService {
  AuditExplorerService({
    required AuditService audit,
    required SystemAuditRepository repository,
    required PermissionEngine permissions,
  })  : _audit = audit,
        _repo = repository,
        _permissions = permissions;

  final AuditService _audit;
  final SystemAuditRepository _repo;
  final PermissionEngine _permissions;

  Future<Result<PaginatedResult<SystemAuditEntry>>> search(AuthUser user, AuditExplorerFilter filter) async {
    try {
      _permissions.require(user, AuditExplorerPermissions.explore);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final local = await _repo.search(user.tenantId!, filter);
    if (local.items.isNotEmpty) return Success(local);
    final pending = await _audit.pendingSync(limit: filter.pageSize);
    final entries = pending.map(SystemAuditEntry.fromAuditEntry).toList();
    return Success(PaginatedResult(items: entries, totalCount: entries.length, page: filter.page, pageSize: filter.pageSize));
  }

  Future<Result<List<SystemAuditEntry>>> entityTimeline(AuthUser user, {required String entityType, required String entityId}) async {
    try {
      _permissions.require(user, AuditExplorerPermissions.explore);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final rows = await _audit.getEntityTimeline(entityType: entityType, entityId: entityId);
    return Success(rows.map(SystemAuditEntry.fromAuditEntry).toList());
  }
}

class TenantAdminService {
  TenantAdminService({
    required RoleDefinitionRepository roles,
    required PermissionAssignmentRepository assignments,
    required SystemConfigurationRepository config,
    required PermissionEngine permissions,
    Uuid? uuid,
  })  : _roles = roles,
        _assignments = assignments,
        _config = config,
        _permissions = permissions,
        _uuid = uuid ?? const Uuid();

  final RoleDefinitionRepository _roles;
  final PermissionAssignmentRepository _assignments;
  final SystemConfigurationRepository _config;
  final PermissionEngine _permissions;
  final Uuid _uuid;

  Future<Result<List<RoleDefinition>>> listRoles(AuthUser user) async {
    try {
      _permissions.require(user, SystemPermissions.manage);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final page = await _roles.getPage(RepositoryQuery(tenantId: user.tenantId!, pageSize: 500));
    return Success(page.items);
  }

  Future<Result<RoleDefinition>> saveRole(AuthUser user, {required String code, required String name, List<String> permissions = const []}) async {
    try {
      _permissions.require(user, SystemPermissions.manage);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final tenantId = user.tenantId!;
    final existing = await _roles.getByCode(tenantId, code);
    final now = DateTime.now().toUtc();
    if (existing != null) {
      final updated = await _roles.update(RoleDefinition(
        id: existing.id,
        tenantId: tenantId,
        code: code,
        name: name,
        permissions: permissions,
        description: existing.description,
        isSystem: existing.isSystem,
        version: existing.version + 1,
        createdAt: existing.createdAt,
        updatedAt: now,
        syncStatus: LocalSyncStatus.pending,
        isDirty: true,
      ));
      return Success(updated);
    }
    final created = await _roles.create(RoleDefinition(
      id: _uuid.v4(),
      tenantId: tenantId,
      code: code,
      name: name,
      permissions: permissions,
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    ));
    return Success(created);
  }

  Future<Result<List<PermissionAssignment>>> listAssignments(AuthUser user, String subjectType, String subjectId) async {
    try {
      _permissions.require(user, SystemPermissions.manage);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final items = await _assignments.listBySubject(user.tenantId!, subjectType, subjectId);
    return Success(items);
  }

  Future<Result<SystemConfiguration?>> getConfiguration(AuthUser user) async {
    try {
      _permissions.require(user, SystemPermissions.manage);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    return Success(await _config.getForTenant(user.tenantId!));
  }
}

class HealthMonitorService {
  HealthMonitorService({
    required SystemHealthRepository repository,
    required PermissionEngine permissions,
    Uuid? uuid,
  })  : _repo = repository,
        _permissions = permissions,
        _uuid = uuid ?? const Uuid();

  final SystemHealthRepository _repo;
  final PermissionEngine _permissions;
  final Uuid _uuid;

  Future<Result<SystemHealthSnapshot?>> latest(AuthUser user) async {
    try {
      _permissions.require(user, SystemPermissions.view);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    return Success(await _repo.getLatest(user.tenantId!));
  }

  Future<Result<SystemHealthSnapshot>> capture(AuthUser user, {HealthStatus status = HealthStatus.healthy}) async {
    try {
      _permissions.require(user, SystemPermissions.manage);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final now = DateTime.now().toUtc();
    final snap = await _repo.create(SystemHealthSnapshot(
      id: _uuid.v4(),
      tenantId: user.tenantId!,
      capturedAt: now,
      status: status,
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    ));
    return Success(snap);
  }
}

class PerformanceMonitorService {
  PerformanceMonitorService({
    required BackgroundJobRepository jobs,
    required PermissionEngine permissions,
  })  : _jobs = jobs,
        _permissions = permissions;

  final BackgroundJobRepository _jobs;
  final PermissionEngine _permissions;

  Future<Result<List<BackgroundJobStatus>>> listJobs(AuthUser user) async {
    try {
      _permissions.require(user, SystemPermissions.view);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final page = await _jobs.getPage(RepositoryQuery(tenantId: user.tenantId!, pageSize: 200));
    return Success(page.items);
  }
}

class ErrorLogService {
  ErrorLogService({
    required ErrorLogRepository repository,
    required PermissionEngine permissions,
    Uuid? uuid,
  })  : _repo = repository,
        _permissions = permissions,
        _uuid = uuid ?? const Uuid();

  final ErrorLogRepository _repo;
  final PermissionEngine _permissions;
  final Uuid _uuid;

  Future<Result<List<ErrorLogEntry>>> listUnresolved(AuthUser user) async {
    try {
      _permissions.require(user, SystemPermissions.view);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    return Success(await _repo.listUnresolved(user.tenantId!));
  }

  Future<Result<ErrorLogEntry>> record(AuthUser user, {required String message, ErrorSeverity severity = ErrorSeverity.error, String? source}) async {
    try {
      _permissions.require(user, SystemPermissions.manage);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final now = DateTime.now().toUtc();
    final entry = await _repo.create(ErrorLogEntry(
      id: _uuid.v4(),
      tenantId: user.tenantId!,
      message: message,
      severity: severity,
      source: source,
      occurredAt: now,
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    ));
    return Success(entry);
  }
}

class SyncMonitorService {
  SyncMonitorService({
    required SyncMonitorRepository repository,
    required AppDatabase database,
    required SyncCoordinator syncCoordinator,
    required PermissionEngine permissions,
    Uuid? uuid,
  })  : _repo = repository,
        _db = database,
        _sync = syncCoordinator,
        _permissions = permissions,
        _uuid = uuid ?? const Uuid();

  final SyncMonitorRepository _repo;
  final AppDatabase _db;
  final SyncCoordinator _sync;
  final PermissionEngine _permissions;
  final Uuid _uuid;

  Future<Result<SyncMonitorSnapshot>> capture(AuthUser user) async {
    try {
      _permissions.require(user, SystemPermissions.view);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final now = DateTime.now().toUtc();
    final pending = await _db.syncQueueDao.countPending();
    final snap = await _repo.create(SyncMonitorSnapshot(
      id: _uuid.v4(),
      tenantId: user.tenantId!,
      capturedAt: now,
      pendingCount: pending,
      engineState: _sync.state.name,
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    ));
    return Success(snap);
  }

  Future<Result<SyncMonitorSnapshot?>> latest(AuthUser user) async {
    try {
      _permissions.require(user, SystemPermissions.view);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    return Success(await _repo.getLatest(user.tenantId!));
  }
}

class StorageMonitorService {
  StorageMonitorService({
    required StorageMonitorRepository repository,
    required AppDatabase database,
    required PermissionEngine permissions,
    Uuid? uuid,
  })  : _repo = repository,
        _db = database,
        _permissions = permissions,
        _uuid = uuid ?? const Uuid();

  final StorageMonitorRepository _repo;
  final AppDatabase _db;
  final PermissionEngine _permissions;
  final Uuid _uuid;

  Future<Result<StorageUsageSnapshot>> capture(AuthUser user) async {
    try {
      _permissions.require(user, SystemPermissions.view);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final now = DateTime.now().toUtc();
    final snap = await _repo.create(StorageUsageSnapshot(
      id: _uuid.v4(),
      tenantId: user.tenantId!,
      capturedAt: now,
      databaseMb: 0,
      totalMb: 0,
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    ));
    return Success(snap);
  }
}

class QueueMonitorService {
  QueueMonitorService({
    required AppDatabase database,
    required BackgroundJobRepository jobs,
    required PermissionEngine permissions,
  })  : _db = database,
        _jobs = jobs,
        _permissions = permissions;

  final AppDatabase _db;
  final BackgroundJobRepository _jobs;
  final PermissionEngine _permissions;

  Future<Result<({int pending, List<BackgroundJobStatus> jobs})>> status(AuthUser user) async {
    try {
      _permissions.require(user, SystemPermissions.view);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final pending = await _db.syncQueueDao.countPending();
    final page = await _jobs.getPage(RepositoryQuery(tenantId: user.tenantId!, pageSize: 100));
    return Success((pending: pending, jobs: page.items));
  }
}

class LicenseService {
  LicenseService({
    required LicenseRecordRepository licenses,
    required SubscriptionRecordRepository subscriptions,
    required LicenseEngine licenseEngine,
    required PermissionEngine permissions,
    Uuid? uuid,
  })  : _licenses = licenses,
        _subscriptions = subscriptions,
        _licenseEngine = licenseEngine,
        _permissions = permissions,
        _uuid = uuid ?? const Uuid();

  final LicenseRecordRepository _licenses;
  final SubscriptionRecordRepository _subscriptions;
  final LicenseEngine _licenseEngine;
  final PermissionEngine _permissions;
  final Uuid _uuid;

  Future<Result<LicenseRecord?>> activeLicense(AuthUser user) async {
    try {
      _permissions.require(user, SystemPermissions.view);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    return Success(await _licenses.getActive(user.tenantId!));
  }

  Future<Result<SubscriptionRecord?>> currentSubscription(AuthUser user) async {
    try {
      _permissions.require(user, SystemPermissions.view);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    return Success(await _subscriptions.getCurrent(user.tenantId!));
  }

  Future<Result<void>> refreshEvaluation(AuthUser user) async {
    try {
      _permissions.require(user, SystemPermissions.manage);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    await _licenseEngine.evaluate(tenantId: user.tenantId, subscriptionStatus: null);
    return const Success(null);
  }
}

class MaintenanceService {
  MaintenanceService({
    required MaintenanceModeRepository repository,
    required PermissionEngine permissions,
    Uuid? uuid,
  })  : _repo = repository,
        _permissions = permissions,
        _uuid = uuid ?? const Uuid();

  final MaintenanceModeRepository _repo;
  final PermissionEngine _permissions;
  final Uuid _uuid;

  Future<Result<MaintenanceMode?>> current(AuthUser user) async {
    try {
      _permissions.require(user, SystemMaintenancePermissions.manage);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    return Success(await _repo.getCurrent(user.tenantId!));
  }

  Future<Result<MaintenanceMode>> setActive(AuthUser user, {required bool active, String? message}) async {
    try {
      _permissions.require(user, SystemMaintenancePermissions.manage);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final tenantId = user.tenantId!;
    final existing = await _repo.getCurrent(tenantId);
    final now = DateTime.now().toUtc();
    if (existing != null) {
      final updated = await _repo.update(existing.copyWith(active: active, message: message, updatedAt: now, isDirty: true, syncStatus: LocalSyncStatus.pending));
      return Success(updated);
    }
    final created = await _repo.create(MaintenanceMode(
      id: _uuid.v4(),
      tenantId: tenantId,
      active: active,
      message: message,
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    ));
    return Success(created);
  }
}

class SecurityCenterService {
  SecurityCenterService({
    required SecuritySessionRepository sessions,
    required DeviceRegistrationRepository devices,
    required LoginHistoryRepository loginHistory,
    required PermissionEngine permissions,
    Uuid? uuid,
  })  : _sessions = sessions,
        _devices = devices,
        _loginHistory = loginHistory,
        _permissions = permissions,
        _uuid = uuid ?? const Uuid();

  final SecuritySessionRepository _sessions;
  final DeviceRegistrationRepository _devices;
  final LoginHistoryRepository _loginHistory;
  final PermissionEngine _permissions;
  final Uuid _uuid;

  Future<Result<List<SecuritySession>>> activeSessions(AuthUser user) async {
    try {
      _permissions.require(user, SecurityPermissions.manage);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    return Success(await _sessions.listActive(user.tenantId!));
  }

  Future<Result<List<DeviceRegistration>>> trustedDevices(AuthUser user) async {
    try {
      _permissions.require(user, SecurityPermissions.manage);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    return Success(await _devices.listTrusted(user.tenantId!));
  }

  Future<Result<List<LoginHistoryEntry>>> recentLogins(AuthUser user) async {
    try {
      _permissions.require(user, SecurityPermissions.manage);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    return Success(await _loginHistory.listRecent(user.tenantId!));
  }
}

class DiagnosticsService {
  DiagnosticsService({
    required AppDatabase database,
    required SyncCoordinator syncCoordinator,
    required NetworkMonitor networkMonitor,
    required AppConfig config,
    required PermissionEngine permissions,
  })  : _db = database,
        _sync = syncCoordinator,
        _network = networkMonitor,
        _config = config,
        _permissions = permissions;

  final AppDatabase _db;
  final SyncCoordinator _sync;
  final NetworkMonitor _network;
  final AppConfig _config;
  final PermissionEngine _permissions;

  Future<Result<DiagnosticsReport>> run(AuthUser user) async {
    try {
      _permissions.require(user, SystemPermissions.manage);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final pending = await _db.syncQueueDao.countPending();
    final network = await _network.currentState;
    return Success(DiagnosticsReport(
      generatedAt: DateTime.now().toUtc(),
      appVersion: _config.appName,
      flavor: _config.flavor.displayName,
      databaseOk: true,
      syncState: _sync.state.name,
      pendingQueue: pending,
      networkOnline: network.isOnline,
      details: {'processors': _sync.state.name},
    ));
  }
}

class EnvironmentSettingsService {
  EnvironmentSettingsService({
    required EnvironmentSettingRepository repository,
    required PermissionEngine permissions,
    Uuid? uuid,
  })  : _repo = repository,
        _permissions = permissions,
        _uuid = uuid ?? const Uuid();

  final EnvironmentSettingRepository _repo;
  final PermissionEngine _permissions;
  final Uuid _uuid;

  Future<Result<List<EnvironmentSetting>>> list(AuthUser user) async {
    try {
      _permissions.require(user, SystemPermissions.manage);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final page = await _repo.getPage(RepositoryQuery(tenantId: user.tenantId!, pageSize: 500));
    return Success(page.items);
  }
}

class ReleaseNotesService {
  ReleaseNotesService({
    required ReleaseNoteRepository repository,
    required PermissionEngine permissions,
  })  : _repo = repository,
        _permissions = permissions;

  final ReleaseNoteRepository _repo;
  final PermissionEngine _permissions;

  Future<Result<List<ReleaseNote>>> list(AuthUser user) async {
    try {
      _permissions.require(user, SystemPermissions.view);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    return Success(await _repo.listPublished(user.tenantId!));
  }
}
