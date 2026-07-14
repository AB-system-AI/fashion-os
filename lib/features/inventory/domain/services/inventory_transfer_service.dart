import 'package:uuid/uuid.dart';

import 'package:fashion_pos_enterprise/core/audit/audit_action.dart';
import 'package:fashion_pos_enterprise/core/audit/audit_service.dart';
import 'package:fashion_pos_enterprise/core/business/engines/inventory/inventory_engine.dart';
import 'package:fashion_pos_enterprise/core/errors/failure.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/pagination/paginated_result.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/repository/repository_query.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_engine.dart';
import 'package:fashion_pos_enterprise/core/result/result.dart';
import 'package:fashion_pos_enterprise/features/auth/domain/entities/auth_user.dart';
import 'package:fashion_pos_enterprise/features/inventory/domain/entities/inventory_transfer.dart';
import 'package:fashion_pos_enterprise/features/inventory/domain/enums/inventory_enums.dart';
import 'package:fashion_pos_enterprise/features/inventory/domain/repositories/inventory_repositories.dart';
import 'package:fashion_pos_enterprise/features/inventory/domain/services/stock_movement_service.dart';
import 'package:fashion_pos_enterprise/features/inventory/domain/value_objects/quantity.dart';

class InventoryTransferService {
  InventoryTransferService({
    required InventoryTransferRepository transferRepository,
    required StockLevelRepository stockLevelRepository,
    required InventoryEngine inventoryEngine,
    required StockMovementService movementService,
    required AuditService auditService,
    required PermissionEngine permissionEngine,
    Uuid? uuid,
  })  : _transfers = transferRepository,
        _levels = stockLevelRepository,
        _engine = inventoryEngine,
        _movements = movementService,
        _audit = auditService,
        _permissions = permissionEngine,
        _uuid = uuid ?? const Uuid();

  final InventoryTransferRepository _transfers;
  final StockLevelRepository _levels;
  final InventoryEngine _engine;
  final StockMovementService _movements;
  final AuditService _audit;
  final PermissionEngine _permissions;
  final Uuid _uuid;

  Future<PaginatedResult<InventoryTransfer>> list({
    required AuthUser user,
    required String tenantId,
    int page = 1,
  }) async {
    try {
      _permissions.require(user, InventoryPermissions.read);
    } on PermissionDeniedException catch (e) {
      return PaginatedResult(items: const [], page: page, pageSize: 50, totalCount: 0, hasMore: false);
    }
    return _transfers.getPage(RepositoryQuery(tenantId: tenantId, page: page, pageSize: 50, sortBy: 'updated_at'));
  }

  Future<Result<InventoryTransfer>> getById(String id, {AuthUser? user}) async {
    if (user != null) {
      try {
        _permissions.require(user, InventoryPermissions.read);
      } on PermissionDeniedException catch (e) {
        return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
      }
    }
    final transfer = await _transfers.getById(id, tenantId: user?.tenantId);
    if (transfer == null) {
      return const Error(ValidationFailure(message: 'Transfer not found', code: 'not_found'));
    }
    return Success(transfer);
  }

  Future<Result<InventoryTransfer>> create({
    required AuthUser user,
    required InventoryTransfer draft,
  }) async {
    try {
      _permissions.require(user, InventoryPermissions.transferCreate);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }

    final now = DateTime.now().toUtc();
    final transfer = InventoryTransfer(
      id: draft.id.isEmpty ? _uuid.v4() : draft.id,
      tenantId: user.tenantId ?? draft.tenantId,
      fromWarehouseId: draft.fromWarehouseId,
      toWarehouseId: draft.toWarehouseId,
      status: TransferStatus.draft,
      lines: draft.lines,
      reference: draft.reference,
      notes: draft.notes,
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    );
    final created = await _transfers.create(transfer);
    await _audit.log(
      action: AuditAction.create,
      entityType: InventoryTransfer.entityTypeName,
      tenantId: created.tenantId,
      employeeId: user.employeeId,
      entityId: created.id,
      newValue: created.toPayload(),
    );
    return Success(created);
  }

  Future<Result<InventoryTransfer>> submitForApproval({
    required AuthUser user,
    required InventoryTransfer transfer,
  }) {
    return _transition(
      user: user,
      transfer: transfer,
      next: TransferStatus.pendingApproval,
      permission: InventoryPermissions.transferCreate,
    );
  }

  Future<Result<InventoryTransfer>> approve({
    required AuthUser user,
    required InventoryTransfer transfer,
  }) {
    return _transition(
      user: user,
      transfer: transfer,
      next: TransferStatus.pendingApproval,
      permission: InventoryPermissions.transferApprove,
      approvedBy: user.employeeId,
    );
  }

  Future<Result<InventoryTransfer>> ship({
    required AuthUser user,
    required InventoryTransfer transfer,
  }) async {
    final result = await _transition(
      user: user,
      transfer: transfer,
      next: TransferStatus.shipped,
      permission: InventoryPermissions.transferApprove,
      shippedAt: DateTime.now().toUtc(),
    );
    if (result.isFailure) return result;

    final shipped = result.dataOrNull!;
    for (final line in shipped.lines) {
      await _movements.issueStock(
        user: user,
        warehouseId: shipped.fromWarehouseId,
        productId: line.productId,
        variantId: line.variantId,
        quantity: line.quantity,
        notes: 'Transfer ${shipped.id} ship',
      );
    }
    return result;
  }

  Future<Result<InventoryTransfer>> receive({
    required AuthUser user,
    required InventoryTransfer transfer,
  }) async {
    try {
      _permissions.require(user, InventoryPermissions.transferReceive);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }

    if (transfer.status != TransferStatus.shipped) {
      return const Error(ValidationFailure(message: 'Transfer must be shipped before receive', code: 'invalid_state'));
    }

    for (final line in transfer.lines) {
      await _movements.receiveStock(
        user: user,
        warehouseId: transfer.toWarehouseId,
        productId: line.productId,
        variantId: line.variantId,
        quantity: line.quantity,
        notes: 'Transfer ${transfer.id} receive',
      );
    }

    final received = await _transfers.update(
      transfer.copyWith(
        status: TransferStatus.received,
        receivedAt: DateTime.now().toUtc(),
        updatedAt: DateTime.now().toUtc(),
        syncStatus: LocalSyncStatus.pending,
        isDirty: true,
      ),
    );
    await _audit.log(
      action: AuditAction.inventoryChange,
      entityType: InventoryTransfer.entityTypeName,
      tenantId: user.tenantId,
      employeeId: user.employeeId,
      entityId: received.id,
      metadata: {'action': 'receive'},
    );
    return Success(received);
  }

  Future<Result<InventoryTransfer>> complete({
    required AuthUser user,
    required InventoryTransfer transfer,
  }) {
    return _transition(
      user: user,
      transfer: transfer,
      next: TransferStatus.completed,
      permission: InventoryPermissions.transferReceive,
      completedAt: DateTime.now().toUtc(),
    );
  }

  Future<Result<InventoryTransfer>> cancel({
    required AuthUser user,
    required InventoryTransfer transfer,
  }) {
    return _transition(
      user: user,
      transfer: transfer,
      next: TransferStatus.cancelled,
      permission: InventoryPermissions.transferCreate,
    );
  }

  Future<Result<InventoryTransfer>> _transition({
    required AuthUser user,
    required InventoryTransfer transfer,
    required TransferStatus next,
    required String permission,
    String? approvedBy,
    DateTime? shippedAt,
    DateTime? completedAt,
  }) async {
    try {
      _permissions.require(user, permission);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }

    final updated = await _transfers.update(
      transfer.copyWith(
        status: next,
        approvedBy: approvedBy ?? transfer.approvedBy,
        shippedAt: shippedAt ?? transfer.shippedAt,
        completedAt: completedAt ?? transfer.completedAt,
        updatedAt: DateTime.now().toUtc(),
        syncStatus: LocalSyncStatus.pending,
        isDirty: true,
      ),
    );
    await _audit.log(
      action: AuditAction.update,
      entityType: InventoryTransfer.entityTypeName,
      tenantId: user.tenantId,
      employeeId: user.employeeId,
      entityId: updated.id,
      metadata: {'status': next.value},
    );
    return Success(updated);
  }
}
