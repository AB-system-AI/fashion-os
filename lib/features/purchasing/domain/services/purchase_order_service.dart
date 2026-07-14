import 'package:uuid/uuid.dart';

import 'package:fashion_pos_enterprise/core/audit/audit_action.dart';
import 'package:fashion_pos_enterprise/core/audit/audit_service.dart';
import 'package:fashion_pos_enterprise/core/business/domain/enums/business_enums.dart';
import 'package:fashion_pos_enterprise/core/business/engines/number_generator_engine.dart';
import 'package:fashion_pos_enterprise/core/business/engines/purchasing/purchase_engine.dart';
import 'package:fashion_pos_enterprise/core/errors/failure.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/pagination/paginated_result.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/repository/repository_query.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_engine.dart';
import 'package:fashion_pos_enterprise/core/result/result.dart';
import 'package:fashion_pos_enterprise/features/auth/domain/entities/auth_user.dart';
import 'package:fashion_pos_enterprise/features/purchasing/domain/entities/purchase_order.dart';
import 'package:fashion_pos_enterprise/features/purchasing/domain/enums/purchasing_enums.dart';
import 'package:fashion_pos_enterprise/features/purchasing/domain/repositories/purchasing_repositories.dart';

class PurchaseOrderService {
  PurchaseOrderService({
    required PurchaseOrderRepository repository,
    required PurchaseEngine purchaseEngine,
    required AuditService auditService,
    required PermissionEngine permissionEngine,
    required NumberGeneratorEngine numberGenerator,
    Uuid? uuid,
  })  : _repository = repository,
        _engine = purchaseEngine,
        _audit = auditService,
        _permissions = permissionEngine,
        _numbers = numberGenerator,
        _uuid = uuid ?? const Uuid();

  final PurchaseOrderRepository _repository;
  final PurchaseEngine _engine;
  final AuditService _audit;
  final PermissionEngine _permissions;
  final NumberGeneratorEngine _numbers;
  final Uuid _uuid;

  Future<PaginatedResult<PurchaseOrder>> list({
    required AuthUser user,
    required String tenantId,
    PurchaseOrderStatus? status,
    int page = 1,
  }) async {
    try {
      _permissions.require(user, PurchasePermissions.view);
    } on PermissionDeniedException {
      return PaginatedResult(items: const [], page: page, pageSize: 50, totalCount: 0, hasMore: false);
    }
    final pageResult = await _repository.getPage(
      RepositoryQuery(tenantId: tenantId, page: page, pageSize: 50, sortBy: 'updated_at'),
    );
    if (status == null) return pageResult;
    return PaginatedResult(
      items: pageResult.items.where((o) => o.status == status).toList(),
      page: pageResult.page,
      pageSize: pageResult.pageSize,
      totalCount: pageResult.totalCount,
      hasMore: pageResult.hasMore,
    );
  }

  Future<Result<PurchaseOrder>> getById(String id, {AuthUser? user}) async {
    if (user != null) {
      try {
        _permissions.require(user, PurchasePermissions.view);
      } on PermissionDeniedException catch (e) {
        return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
      }
    }
    final order = await _repository.getById(id, tenantId: user?.tenantId);
    if (order == null) {
      return const Error(ValidationFailure(message: 'Purchase order not found', code: 'not_found'));
    }
    return Success(order);
  }

  Future<Result<PurchaseOrder>> create({required AuthUser user, required PurchaseOrder draft}) async {
    try {
      _permissions.require(user, PurchasePermissions.create);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }

    final lineCheck = draft.lines.isEmpty ? const Success(null) : _engine.validateLines(draft.lines);
    if (lineCheck.isFailure) return Error(lineCheck.failureOrNull!);

    final tenantId = user.tenantId ?? draft.tenantId;
    final poNumberResult = draft.poNumber.isNotEmpty
        ? Success(draft.poNumber)
        : (await _numbers.next(type: DocumentNumberType.purchase, tenantId: tenantId, storeId: draft.storeId))
            .map((n) => n.value);
    if (poNumberResult.isFailure) return Error(poNumberResult.failureOrNull!);

    final totals = _engine.calculateTotals(draft.lines);
    final now = DateTime.now().toUtc();
    final linesWithIds = draft.lines
        .map((l) => l.id.isEmpty ? l.copyWith() : l)
        .map((l) => PurchaseOrderLine(
              id: l.id.isEmpty ? _uuid.v4() : l.id,
              productId: l.productId,
              variantId: l.variantId,
              quantity: l.quantity,
              unitCost: l.unitCost,
              discount: l.discount,
              tax: l.tax,
            ))
        .toList();

    final order = PurchaseOrder(
      id: draft.id.isEmpty ? _uuid.v4() : draft.id,
      tenantId: tenantId,
      storeId: draft.storeId,
      supplierId: draft.supplierId,
      warehouseId: draft.warehouseId,
      poNumber: poNumberResult.dataOrNull!,
      status: PurchaseOrderStatus.draft,
      currency: draft.currency,
      subtotal: totals.subtotal,
      discountTotal: totals.discountTotal,
      taxTotal: totals.taxTotal,
      grandTotal: totals.grandTotal,
      expectedDelivery: draft.expectedDelivery,
      notes: draft.notes,
      lines: linesWithIds,
      createdBy: user.employeeId,
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    );

    final created = await _repository.create(order);
    await _audit.log(
      action: AuditAction.create,
      entityType: PurchaseOrder.entityTypeName,
      tenantId: created.tenantId,
      employeeId: user.employeeId,
      entityId: created.id,
      newValue: created.toPayload(),
    );
    return Success(created);
  }

  Future<Result<PurchaseOrder>> update({required AuthUser user, required PurchaseOrder order}) async {
    try {
      _permissions.require(user, PurchasePermissions.update);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }

    if (!order.status.isEditable) {
      return const Error(ValidationFailure(message: 'Only draft orders can be edited', code: 'invalid_state'));
    }

    final lineCheck = _engine.validateLines(order.lines);
    if (lineCheck.isFailure) return Error(lineCheck.failureOrNull!);

    final totals = _engine.calculateTotals(order.lines);
    final updated = await _repository.update(
      order.copyWith(
        subtotal: totals.subtotal,
        discountTotal: totals.discountTotal,
        taxTotal: totals.taxTotal,
        grandTotal: totals.grandTotal,
        updatedAt: DateTime.now().toUtc(),
        syncStatus: LocalSyncStatus.pending,
        isDirty: true,
      ),
    );
    await _audit.log(
      action: AuditAction.update,
      entityType: PurchaseOrder.entityTypeName,
      tenantId: user.tenantId,
      employeeId: user.employeeId,
      entityId: updated.id,
      newValue: updated.toPayload(),
    );
    return Success(updated);
  }

  Future<Result<PurchaseOrder>> submitForApproval({
    required AuthUser user,
    required PurchaseOrder order,
  }) async {
    final lineCheck = _engine.validateLines(order.lines);
    if (lineCheck.isFailure) return Error(lineCheck.failureOrNull!);
    return _transition(user: user, order: order, next: PurchaseOrderStatus.pendingApproval, permission: PurchasePermissions.create);
  }

  Future<Result<PurchaseOrder>> approve({
    required AuthUser user,
    required PurchaseOrder order,
  }) {
    return _transition(user: user, order: order, next: PurchaseOrderStatus.approved, permission: PurchasePermissions.approve);
  }

  Future<Result<PurchaseOrder>> send({
    required AuthUser user,
    required PurchaseOrder order,
  }) {
    return _transition(user: user, order: order, next: PurchaseOrderStatus.sent, permission: PurchasePermissions.send);
  }

  Future<Result<PurchaseOrder>> close({
    required AuthUser user,
    required PurchaseOrder order,
  }) {
    return _transition(user: user, order: order, next: PurchaseOrderStatus.closed, permission: PurchasePermissions.close);
  }

  Future<Result<PurchaseOrder>> cancel({
    required AuthUser user,
    required PurchaseOrder order,
  }) {
    return _transition(
      user: user,
      order: order,
      next: PurchaseOrderStatus.cancelled,
      permission: PurchasePermissions.cancel,
      cancelledAt: DateTime.now().toUtc(),
    );
  }

  Future<Result<PurchaseOrder>> _transition({
    required AuthUser user,
    required PurchaseOrder order,
    required PurchaseOrderStatus next,
    required String permission,
    DateTime? cancelledAt,
  }) async {
    try {
      _permissions.require(user, permission);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }

    final openCheck = _engine.validateOrderOpen(order);
    if (openCheck.isFailure && next != PurchaseOrderStatus.closed) {
      return Error(openCheck.failureOrNull!);
    }

    final updated = await _repository.update(
      order.copyWith(
        status: next,
        submittedAt: next == PurchaseOrderStatus.pendingApproval ? DateTime.now().toUtc() : order.submittedAt,
        cancelledAt: cancelledAt ?? order.cancelledAt,
        updatedAt: DateTime.now().toUtc(),
        syncStatus: LocalSyncStatus.pending,
        isDirty: true,
      ),
    );
    await _audit.log(
      action: AuditAction.update,
      entityType: PurchaseOrder.entityTypeName,
      tenantId: user.tenantId,
      employeeId: user.employeeId,
      entityId: updated.id,
      metadata: {'status': next.value},
    );
    return Success(updated);
  }
}
