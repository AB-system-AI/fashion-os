import 'package:uuid/uuid.dart';

import 'package:fashion_pos_enterprise/core/audit/audit_action.dart';
import 'package:fashion_pos_enterprise/core/audit/audit_service.dart';
import 'package:fashion_pos_enterprise/core/business/domain/enums/business_enums.dart';
import 'package:fashion_pos_enterprise/core/business/engines/number_generator_engine.dart';
import 'package:fashion_pos_enterprise/core/errors/failure.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_engine.dart';
import 'package:fashion_pos_enterprise/core/result/result.dart';
import 'package:fashion_pos_enterprise/features/auth/domain/entities/auth_user.dart';
import 'package:fashion_pos_enterprise/features/inventory/domain/services/stock_movement_service.dart';
import 'package:fashion_pos_enterprise/features/purchasing/domain/entities/purchase_return.dart';
import 'package:fashion_pos_enterprise/features/purchasing/domain/entities/supplier.dart';
import 'package:fashion_pos_enterprise/features/purchasing/domain/enums/purchasing_enums.dart';
import 'package:fashion_pos_enterprise/features/purchasing/domain/repositories/purchasing_repositories.dart';

class PurchaseReturnService {
  PurchaseReturnService({
    required PurchaseReturnRepository returnRepository,
    required SupplierRepository supplierRepository,
    required StockMovementService stockMovementService,
    required AuditService auditService,
    required PermissionEngine permissionEngine,
    required NumberGeneratorEngine numberGenerator,
    Uuid? uuid,
  })  : _returns = returnRepository,
        _suppliers = supplierRepository,
        _stock = stockMovementService,
        _audit = auditService,
        _permissions = permissionEngine,
        _numbers = numberGenerator,
        _uuid = uuid ?? const Uuid();

  final PurchaseReturnRepository _returns;
  final SupplierRepository _suppliers;
  final StockMovementService _stock;
  final AuditService _audit;
  final PermissionEngine _permissions;
  final NumberGeneratorEngine _numbers;
  final Uuid _uuid;

  Future<Result<PurchaseReturn>> create({
    required AuthUser user,
    required PurchaseReturn draft,
  }) async {
    try {
      _permissions.require(user, PurchasePermissions.returnCreate);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }

    if (draft.lines.isEmpty) {
      return const Error(ValidationFailure(message: 'Return requires at least one line', code: 'no_lines'));
    }

    final tenantId = user.tenantId ?? draft.tenantId;
    final numberResult = draft.returnNumber.isNotEmpty
        ? Success(draft.returnNumber)
        : (await _numbers.next(type: DocumentNumberType.returnOrder, tenantId: tenantId)).map((n) => n.value);
    if (numberResult.isFailure) return Error(numberResult.failureOrNull!);

    final totalAmount = draft.lines.fold<double>(0, (sum, l) => sum + l.quantity * l.unitCost);
    final now = DateTime.now().toUtc();
    final purchaseReturn = PurchaseReturn(
      id: draft.id.isEmpty ? _uuid.v4() : draft.id,
      tenantId: tenantId,
      supplierId: draft.supplierId,
      warehouseId: draft.warehouseId,
      purchaseOrderId: draft.purchaseOrderId,
      returnNumber: numberResult.dataOrNull!,
      status: PurchaseReturnStatus.draft,
      lines: draft.lines,
      totalAmount: totalAmount,
      notes: draft.notes,
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    );

    final created = await _returns.create(purchaseReturn);
    await _audit.log(
      action: AuditAction.create,
      entityType: PurchaseReturn.entityTypeName,
      tenantId: created.tenantId,
      employeeId: user.employeeId,
      entityId: created.id,
      newValue: created.toPayload(),
    );
    return Success(created);
  }

  Future<Result<PurchaseReturn>> approve({
    required AuthUser user,
    required PurchaseReturn purchaseReturn,
  }) async {
    try {
      _permissions.require(user, PurchasePermissions.returnApprove);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }

    final updated = await _returns.update(
      purchaseReturn.copyWith(
        status: PurchaseReturnStatus.approved,
        approvedBy: user.employeeId,
        updatedAt: DateTime.now().toUtc(),
        syncStatus: LocalSyncStatus.pending,
        isDirty: true,
      ),
    );
    await _audit.log(
      action: AuditAction.update,
      entityType: PurchaseReturn.entityTypeName,
      tenantId: user.tenantId,
      employeeId: user.employeeId,
      entityId: updated.id,
      metadata: {'status': PurchaseReturnStatus.approved.value},
    );
    return Success(updated);
  }

  Future<Result<PurchaseReturn>> complete({
    required AuthUser user,
    required PurchaseReturn purchaseReturn,
  }) async {
    try {
      _permissions.require(user, PurchasePermissions.returnApprove);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }

    if (purchaseReturn.status != PurchaseReturnStatus.approved) {
      return const Error(ValidationFailure(message: 'Return must be approved first', code: 'invalid_state'));
    }

    for (final line in purchaseReturn.lines) {
      await _stock.issueStock(
        user: user,
        warehouseId: purchaseReturn.warehouseId,
        productId: line.productId,
        variantId: line.variantId,
        quantity: line.quantity,
        notes: 'Return ${purchaseReturn.returnNumber}',
      );
    }

    final now = DateTime.now().toUtc();
    final supplier = await _suppliers.getById(purchaseReturn.supplierId, tenantId: purchaseReturn.tenantId);
    if (supplier != null) {
      await _suppliers.update(
        supplier.copyWith(
          currentBalance: (supplier.currentBalance - purchaseReturn.totalAmount).clamp(0, double.infinity),
          updatedAt: now,
          syncStatus: LocalSyncStatus.pending,
          isDirty: true,
        ),
      );
    }

    final completed = await _returns.update(
      purchaseReturn.copyWith(
        status: PurchaseReturnStatus.completed,
        completedAt: now,
        updatedAt: now,
        syncStatus: LocalSyncStatus.pending,
        isDirty: true,
      ),
    );

    await _audit.log(
      action: AuditAction.inventoryChange,
      entityType: PurchaseReturn.entityTypeName,
      tenantId: user.tenantId,
      employeeId: user.employeeId,
      entityId: completed.id,
      metadata: {'action': 'complete'},
    );
    return Success(completed);
  }
}
