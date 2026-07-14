import 'package:uuid/uuid.dart';

import 'package:fashion_pos_enterprise/core/audit/audit_action.dart';
import 'package:fashion_pos_enterprise/core/audit/audit_service.dart';
import 'package:fashion_pos_enterprise/core/errors/failure.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/pagination/paginated_result.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/repository/repository_query.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_engine.dart';
import 'package:fashion_pos_enterprise/core/result/result.dart';
import 'package:fashion_pos_enterprise/features/auth/domain/entities/auth_user.dart';
import 'package:fashion_pos_enterprise/features/inventory/domain/entities/warehouse.dart';
import 'package:fashion_pos_enterprise/features/inventory/domain/repositories/inventory_repositories.dart';

class WarehouseService {
  WarehouseService({
    required WarehouseRepository repository,
    required AuditService auditService,
    required PermissionEngine permissionEngine,
    Uuid? uuid,
  })  : _repository = repository,
        _audit = auditService,
        _permissions = permissionEngine,
        _uuid = uuid ?? const Uuid();

  final WarehouseRepository _repository;
  final AuditService _audit;
  final PermissionEngine _permissions;
  final Uuid _uuid;

  Future<PaginatedResult<Warehouse>> list({
    required String tenantId,
    int page = 1,
    int pageSize = 100,
  }) {
    return _repository.getPage(
      RepositoryQuery(tenantId: tenantId, page: page, pageSize: pageSize, sortBy: 'name'),
    );
  }

  Future<Result<Warehouse>> getById(String id, {AuthUser? user}) async {
    if (user != null) {
      try {
        _permissions.require(user, WarehousePermissions.view);
      } on PermissionDeniedException catch (e) {
        return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
      }
    }
    final warehouse = await _repository.getById(id, tenantId: user?.tenantId);
    if (warehouse == null) {
      return const Error(ValidationFailure(message: 'Warehouse not found', code: 'not_found'));
    }
    return Success(warehouse);
  }

  Future<Result<Warehouse>> create({required AuthUser user, required Warehouse draft}) async {
    try {
      _permissions.require(user, WarehousePermissions.create);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }

    final now = DateTime.now().toUtc();
    final warehouse = Warehouse(
      id: draft.id.isEmpty ? _uuid.v4() : draft.id,
      tenantId: user.tenantId ?? draft.tenantId,
      name: draft.name.trim(),
      code: draft.code,
      storeId: draft.storeId,
      address: draft.address,
      isActive: draft.isActive,
      isDefault: draft.isDefault,
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    );
    final created = await _repository.create(warehouse);
    await _audit.log(
      action: AuditAction.create,
      entityType: Warehouse.entityTypeName,
      tenantId: created.tenantId,
      employeeId: user.employeeId,
      entityId: created.id,
      newValue: created.toPayload(),
    );
    return Success(created);
  }

  Future<Result<Warehouse>> update({
    required AuthUser user,
    required Warehouse warehouse,
    Warehouse? previous,
  }) async {
    try {
      _permissions.require(user, WarehousePermissions.update);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }

    final updated = await _repository.update(
      warehouse.copyWith(
        updatedAt: DateTime.now().toUtc(),
        syncStatus: LocalSyncStatus.pending,
        isDirty: true,
      ),
    );
    await _audit.log(
      action: AuditAction.update,
      entityType: Warehouse.entityTypeName,
      tenantId: updated.tenantId,
      employeeId: user.employeeId,
      entityId: updated.id,
      oldValue: previous?.toPayload(),
      newValue: updated.toPayload(),
    );
    return Success(updated);
  }

  Future<Result<Warehouse>> archive({required AuthUser user, required Warehouse warehouse}) {
    return update(user: user, warehouse: warehouse.copyWith(isActive: false), previous: warehouse);
  }

  Future<Result<void>> delete({required AuthUser user, required String warehouseId}) async {
    try {
      _permissions.require(user, WarehousePermissions.delete);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    await _repository.softDelete(warehouseId, tenantId: user.tenantId);
    await _audit.log(
      action: AuditAction.delete,
      entityType: Warehouse.entityTypeName,
      tenantId: user.tenantId,
      employeeId: user.employeeId,
      entityId: warehouseId,
    );
    return const Success(null);
  }
}
