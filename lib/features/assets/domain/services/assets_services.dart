import 'package:uuid/uuid.dart';

import 'package:fashion_pos_enterprise/core/audit/audit_action.dart';
import 'package:fashion_pos_enterprise/core/audit/audit_service.dart';
import 'package:fashion_pos_enterprise/core/business/engines/assets/assets_engine.dart';
import 'package:fashion_pos_enterprise/core/errors/failure.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/pagination/paginated_result.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/repository/repository_query.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_engine.dart';
import 'package:fashion_pos_enterprise/core/result/result.dart';
import 'package:fashion_pos_enterprise/features/auth/domain/entities/auth_user.dart';
import 'package:fashion_pos_enterprise/features/assets/domain/entities/asset.dart';
import 'package:fashion_pos_enterprise/features/assets/domain/entities/depreciation.dart';
import 'package:fashion_pos_enterprise/features/assets/domain/entities/disposal.dart';
import 'package:fashion_pos_enterprise/features/assets/domain/entities/maintenance.dart';
import 'package:fashion_pos_enterprise/features/assets/domain/entities/transfer.dart';
import 'package:fashion_pos_enterprise/features/assets/domain/enums/assets_enums.dart';
import 'package:fashion_pos_enterprise/features/assets/domain/repositories/assets_repositories.dart';
import 'package:fashion_pos_enterprise/features/assets/domain/value_objects/assets_value_objects.dart';

class AssetService {
  AssetService({
    required AssetRepository assets,
    required AssetCategoryRepository categories,
    required AssetLocationRepository locations,
    required AssetSettingsRepository settings,
    required AssetsEngine engine,
    required AuditService audit,
    required PermissionEngine permissions,
    Uuid? uuid,
  })  : _assets = assets,
        _categories = categories,
        _locations = locations,
        _settings = settings,
        _engine = engine,
        _audit = audit,
        _permissions = permissions,
        _uuid = uuid ?? const Uuid();

  final AssetRepository _assets;
  final AssetCategoryRepository _categories;
  final AssetLocationRepository _locations;
  final AssetSettingsRepository _settings;
  final AssetsEngine _engine;
  final AuditService _audit;
  final PermissionEngine _permissions;
  final Uuid _uuid;

  Future<Result<UtilizationKpis>> dashboard({required AuthUser user}) async {
    try {
      _permissions.require(user, AssetsPermissions.view);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final tenantId = user.tenantId!;
    final page = await _assets.getPage(RepositoryQuery(tenantId: tenantId, pageSize: 1000));
    return Success(_engine.calculateUtilizationKpis(assets: page.items));
  }

  Future<PaginatedResult<Asset>> list(String tenantId) =>
      _assets.getPage(RepositoryQuery(tenantId: tenantId, pageSize: 200));

  Future<Result<Asset>> create({required AuthUser user, required AssetInput input}) async {
    try {
      _permissions.require(user, AssetsPermissions.manage);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final tenantId = user.tenantId!;
    final now = DateTime.now().toUtc();
    final asset = await _assets.create(Asset(
      id: _uuid.v4(),
      tenantId: tenantId,
      name: input.name,
      assetTag: input.assetTag,
      serialNumber: input.serialNumber,
      description: input.description,
      categoryId: input.categoryId,
      locationId: input.locationId,
      acquisitionCost: input.acquisitionCost,
      bookValue: input.acquisitionCost,
      acquisitionDate: input.acquisitionDate ?? now,
      usefulLifeMonths: input.usefulLifeMonths,
      salvageValue: input.salvageValue,
      depreciationMethod: input.depreciationMethod,
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    ));
    await _audit.log(action: AuditAction.create, entityType: Asset.entityTypeName, tenantId: tenantId, employeeId: user.employeeId, entityId: asset.id);
    return Success(asset);
  }

  Future<Result<Asset>> getById({required AuthUser user, required String id}) async {
    try {
      _permissions.require(user, AssetsPermissions.view);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final asset = await _assets.getById(id, tenantId: user.tenantId!);
    if (asset == null) return const Error(ValidationFailure(message: 'Asset not found', code: 'not_found'));
    return Success(asset);
  }

  Future<List<AssetCategory>> listCategories(String tenantId) => _categories.listActive(tenantId);

  Future<List<AssetLocation>> listLocations(String tenantId) => _locations.listActive(tenantId);
}

class DepreciationService {
  DepreciationService({
    required AssetRepository assets,
    required AssetDepreciationRepository depreciation,
    required AssetsEngine engine,
    required AuditService audit,
    required PermissionEngine permissions,
    Uuid? uuid,
  })  : _assets = assets,
        _depreciation = depreciation,
        _engine = engine,
        _audit = audit,
        _permissions = permissions,
        _uuid = uuid ?? const Uuid();

  final AssetRepository _assets;
  final AssetDepreciationRepository _depreciation;
  final AssetsEngine _engine;
  final AuditService _audit;
  final PermissionEngine _permissions;
  final Uuid _uuid;

  Future<Result<AssetDepreciation>> postPeriod({required AuthUser user, required String assetId}) async {
    try {
      _permissions.require(user, DepreciationPermissions.manage);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final tenantId = user.tenantId!;
    final asset = await _assets.getById(assetId, tenantId: tenantId);
    if (asset == null) return const Error(ValidationFailure(message: 'Asset not found', code: 'not_found'));

    final latest = await _depreciation.latestForAsset(tenantId, assetId);
    final period = (latest?.period ?? 0) + 1;
    final calc = _engine.calculateNextDepreciation(asset: asset, period: period, previous: latest);
    final now = DateTime.now().toUtc();

    final entry = await _depreciation.create(AssetDepreciation(
      id: _uuid.v4(),
      tenantId: tenantId,
      assetId: assetId,
      period: period,
      depreciationAmount: calc.depreciationAmount,
      accumulatedDepreciation: calc.accumulatedDepreciation,
      bookValue: calc.bookValue,
      postedAt: now,
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    ));

    await _assets.update(asset.copyWith(
      bookValue: calc.bookValue,
      accumulatedDepreciation: calc.accumulatedDepreciation,
      version: asset.version + 1,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    ));

    await _audit.log(action: AuditAction.create, entityType: AssetDepreciation.entityTypeName, tenantId: tenantId, employeeId: user.employeeId, entityId: entry.id);
    return Success(entry);
  }

  Future<List<AssetDepreciation>> listByAsset(String tenantId, String assetId) =>
      _depreciation.listByAsset(tenantId, assetId);

  List<DepreciationScheduleEntry> scheduleForAsset(Asset asset, {int periods = 12}) =>
      _engine.buildDepreciationSchedule(
        acquisitionCost: asset.acquisitionCost,
        salvageValue: asset.salvageValue,
        usefulLifeMonths: asset.usefulLifeMonths,
        method: asset.depreciationMethod,
        periods: periods,
      );
}

class MaintenanceService {
  MaintenanceService({
    required MaintenanceRequestRepository requests,
    required MaintenanceScheduleRepository schedules,
    required MaintenanceCostRepository costs,
    required AssetRepository assets,
    required AssetsEngine engine,
    required AuditService audit,
    required PermissionEngine permissions,
    Uuid? uuid,
  })  : _requests = requests,
        _schedules = schedules,
        _costs = costs,
        _assets = assets,
        _engine = engine,
        _audit = audit,
        _permissions = permissions,
        _uuid = uuid ?? const Uuid();

  final MaintenanceRequestRepository _requests;
  final MaintenanceScheduleRepository _schedules;
  final MaintenanceCostRepository _costs;
  final AssetRepository _assets;
  final AssetsEngine _engine;
  final AuditService _audit;
  final PermissionEngine _permissions;
  final Uuid _uuid;

  Future<Result<MaintenanceRequest>> createRequest({required AuthUser user, required MaintenanceRequestInput input}) async {
    try {
      _permissions.require(user, AssetMaintenancePermissions.manage);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final tenantId = user.tenantId!;
    final now = DateTime.now().toUtc();
    final request = await _requests.create(MaintenanceRequest(
      id: _uuid.v4(),
      tenantId: tenantId,
      assetId: input.assetId,
      title: input.title,
      description: input.description,
      priority: input.priority,
      scheduleType: input.scheduleType,
      requestedBy: user.employeeId,
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    ));
    final asset = await _assets.getById(input.assetId, tenantId: tenantId);
    if (asset != null) {
      await _assets.update(asset.copyWith(
        status: AssetStatus.inMaintenance,
        version: asset.version + 1,
        updatedAt: now,
        syncStatus: LocalSyncStatus.pending,
        isDirty: true,
      ));
    }
    await _audit.log(action: AuditAction.create, entityType: MaintenanceRequest.entityTypeName, tenantId: tenantId, employeeId: user.employeeId, entityId: request.id);
    return Success(request);
  }

  Future<List<MaintenanceRequest>> listOpen(String tenantId) => _requests.listOpen(tenantId);

  Future<List<MaintenanceSchedule>> listDue(String tenantId) =>
      _schedules.listDue(tenantId, DateTime.now().toUtc().add(const Duration(days: 30)));

  MaintenanceCostSummary summarizeCosts(List<MaintenanceCost> items) => _engine.summarizeMaintenanceCosts(items);
}

class TransferService {
  TransferService({
    required AssetRepository assets,
    required AssetTransferRepository transfers,
    required AssetsEngine engine,
    required AuditService audit,
    required PermissionEngine permissions,
    Uuid? uuid,
  })  : _assets = assets,
        _transfers = transfers,
        _engine = engine,
        _audit = audit,
        _permissions = permissions,
        _uuid = uuid ?? const Uuid();

  final AssetRepository _assets;
  final AssetTransferRepository _transfers;
  final AssetsEngine _engine;
  final AuditService _audit;
  final PermissionEngine _permissions;
  final Uuid _uuid;

  Future<Result<AssetTransfer>> initiate({required AuthUser user, required TransferInput input}) async {
    try {
      _permissions.require(user, AssetsPermissions.manage);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final tenantId = user.tenantId!;
    final asset = await _assets.getById(input.assetId, tenantId: tenantId);
    if (asset == null) return const Error(ValidationFailure(message: 'Asset not found', code: 'not_found'));

    final plan = _engine.planTransfer(asset: asset, toLocationId: input.toLocationId, notes: input.notes);
    if (plan.isFailure) return Error(plan.failureOrNull!);

    final now = DateTime.now().toUtc();
    final planned = plan.dataOrNull!;
    final transfer = await _transfers.create(AssetTransfer(
      id: _uuid.v4(),
      tenantId: planned.tenantId,
      assetId: planned.assetId,
      fromLocationId: planned.fromLocationId,
      toLocationId: planned.toLocationId,
      status: planned.status,
      notes: planned.notes,
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    ));
    await _audit.log(action: AuditAction.create, entityType: AssetTransfer.entityTypeName, tenantId: tenantId, employeeId: user.employeeId, entityId: transfer.id);
    return Success(transfer);
  }

  Future<Result<AssetTransfer>> complete({required AuthUser user, required String transferId}) async {
    try {
      _permissions.require(user, AssetsPermissions.manage);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final tenantId = user.tenantId!;
    final transfer = await _transfers.getById(transferId, tenantId: tenantId);
    if (transfer == null) return const Error(ValidationFailure(message: 'Transfer not found', code: 'not_found'));

    final statusResult = _engine.completeTransfer(transfer);
    if (statusResult.isFailure) return Error(statusResult.failureOrNull!);

    final now = DateTime.now().toUtc();
    final updated = await _transfers.update(transfer.copyWith(
      status: TransferStatus.completed,
      transferredAt: now,
      transferredBy: user.employeeId,
      version: transfer.version + 1,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    ));

    final asset = await _assets.getById(transfer.assetId, tenantId: tenantId);
    if (asset != null) {
      await _assets.update(asset.copyWith(
        locationId: transfer.toLocationId,
        status: AssetStatus.active,
        version: asset.version + 1,
        updatedAt: now,
        syncStatus: LocalSyncStatus.pending,
        isDirty: true,
      ));
      _engine.publishAssetTransferred(
        tenantId: tenantId,
        assetId: asset.id,
        fromLocationId: transfer.fromLocationId ?? asset.locationId,
        toLocationId: transfer.toLocationId,
      );
    }
    await _audit.log(action: AuditAction.update, entityType: AssetTransfer.entityTypeName, tenantId: tenantId, employeeId: user.employeeId, entityId: transfer.id);
    return Success(updated);
  }

  Future<List<AssetTransfer>> listPending(String tenantId) => _transfers.listPending(tenantId);
}

class DisposalService {
  DisposalService({
    required AssetRepository assets,
    required AssetDisposalRepository disposals,
    required AssetSettingsRepository settings,
    required AssetsEngine engine,
    required AuditService audit,
    required PermissionEngine permissions,
    Uuid? uuid,
  })  : _assets = assets,
        _disposals = disposals,
        _settings = settings,
        _engine = engine,
        _audit = audit,
        _permissions = permissions,
        _uuid = uuid ?? const Uuid();

  final AssetRepository _assets;
  final AssetDisposalRepository _disposals;
  final AssetSettingsRepository _settings;
  final AssetsEngine _engine;
  final AuditService _audit;
  final PermissionEngine _permissions;
  final Uuid _uuid;

  Future<Result<AssetDisposal>> dispose({required AuthUser user, required DisposalInput input}) async {
    try {
      _permissions.require(user, DisposalPermissions.manage);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final tenantId = user.tenantId!;
    final asset = await _assets.getById(input.assetId, tenantId: tenantId);
    if (asset == null) return const Error(ValidationFailure(message: 'Asset not found', code: 'not_found'));

    final validation = _engine.validateDisposal(asset);
    if (validation.isFailure) return Error(validation.failureOrNull!);

    final calc = _engine.calculateDisposal(asset: asset, proceeds: input.proceeds);
    final now = DateTime.now().toUtc();
    final disposal = await _disposals.create(AssetDisposal(
      id: _uuid.v4(),
      tenantId: tenantId,
      assetId: input.assetId,
      method: input.method,
      proceeds: input.proceeds,
      bookValueAtDisposal: calc.bookValue,
      gainLoss: calc.gainLoss,
      notes: input.notes,
      disposedAt: now,
      disposedBy: user.employeeId,
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    ));

    await _assets.update(asset.copyWith(
      status: AssetStatus.disposed,
      bookValue: 0,
      version: asset.version + 1,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    ));

    _engine.publishAssetDisposed(
      tenantId: tenantId,
      assetId: asset.id,
      gainLoss: calc.gainLoss,
      proceeds: input.proceeds,
    );
    await _audit.log(action: AuditAction.create, entityType: AssetDisposal.entityTypeName, tenantId: tenantId, employeeId: user.employeeId, entityId: disposal.id);
    return Success(disposal);
  }
}
