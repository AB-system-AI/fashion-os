import 'package:uuid/uuid.dart';

import 'package:fashion_pos_enterprise/core/audit/audit_action.dart';
import 'package:fashion_pos_enterprise/core/audit/audit_service.dart';
import 'package:fashion_pos_enterprise/core/business/domain/enums/business_enums.dart';
import 'package:fashion_pos_enterprise/core/business/engines/number_generator_engine.dart';
import 'package:fashion_pos_enterprise/core/business/engines/purchasing/purchase_engine.dart';
import 'package:fashion_pos_enterprise/core/business/events/business_events.dart';
import 'package:fashion_pos_enterprise/core/business/events/domain_event_bus.dart';
import 'package:fashion_pos_enterprise/core/errors/failure.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_engine.dart';
import 'package:fashion_pos_enterprise/core/result/result.dart';
import 'package:fashion_pos_enterprise/features/auth/domain/entities/auth_user.dart';
import 'package:fashion_pos_enterprise/features/inventory/domain/services/stock_movement_service.dart';
import 'package:fashion_pos_enterprise/features/purchasing/domain/entities/purchase_order.dart';
import 'package:fashion_pos_enterprise/features/purchasing/domain/entities/purchase_receipt.dart';
import 'package:fashion_pos_enterprise/features/purchasing/domain/entities/supplier.dart';
import 'package:fashion_pos_enterprise/features/purchasing/domain/repositories/purchasing_repositories.dart';

class PurchaseReceiptService {
  PurchaseReceiptService({
    required PurchaseOrderRepository purchaseOrderRepository,
    required PurchaseReceiptRepository receiptRepository,
    required SupplierRepository supplierRepository,
    required PurchaseEngine purchaseEngine,
    required StockMovementService stockMovementService,
    required AuditService auditService,
    required PermissionEngine permissionEngine,
    required NumberGeneratorEngine numberGenerator,
    DomainEventBus? eventBus,
    Uuid? uuid,
  })  : _orders = purchaseOrderRepository,
        _receipts = receiptRepository,
        _suppliers = supplierRepository,
        _engine = purchaseEngine,
        _stock = stockMovementService,
        _audit = auditService,
        _permissions = permissionEngine,
        _numbers = numberGenerator,
        _eventBus = eventBus,
        _uuid = uuid ?? const Uuid();

  final PurchaseOrderRepository _orders;
  final PurchaseReceiptRepository _receipts;
  final SupplierRepository _suppliers;
  final PurchaseEngine _engine;
  final StockMovementService _stock;
  final AuditService _audit;
  final PermissionEngine _permissions;
  final NumberGeneratorEngine _numbers;
  final DomainEventBus? _eventBus;
  final Uuid _uuid;

  Future<Result<PurchaseReceipt>> receive({
    required AuthUser user,
    required String purchaseOrderId,
    required Map<String, double> quantitiesByLineId,
    String? notes,
    bool allowOverReceive = false,
  }) async {
    try {
      _permissions.require(user, PurchasePermissions.receive);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }

    final order = await _orders.getById(purchaseOrderId, tenantId: user.tenantId);
    if (order == null) {
      return const Error(ValidationFailure(message: 'Purchase order not found', code: 'not_found'));
    }

    final validation = _engine.validateReceiving(
      order: order,
      quantitiesByLineId: quantitiesByLineId,
      allowOverReceive: allowOverReceive,
    );
    if (validation.isFailure) return Error(validation.failureOrNull!);

    final receiptNumberResult = await _numbers.next(
      type: DocumentNumberType.receipt,
      tenantId: order.tenantId,
      storeId: order.storeId,
    );
    if (receiptNumberResult.isFailure) return Error(receiptNumberResult.failureOrNull!);

    final now = DateTime.now().toUtc();
    final receiptLines = <PurchaseReceiptLine>[];
    for (final line in order.lines) {
      final qty = quantitiesByLineId[line.id] ?? 0;
      if (qty <= 0) continue;
      receiptLines.add(
        PurchaseReceiptLine(
          poLineId: line.id,
          productId: line.productId,
          variantId: line.variantId,
          quantityReceived: qty,
          unitCost: line.unitCost,
        ),
      );
      await _stock.receiveStock(
        user: user,
        warehouseId: order.warehouseId,
        productId: line.productId,
        variantId: line.variantId,
        quantity: qty,
        notes: 'PO ${order.poNumber} receipt',
      );
    }

    final receipt = PurchaseReceipt(
      id: _uuid.v4(),
      tenantId: order.tenantId,
      purchaseOrderId: order.id,
      warehouseId: order.warehouseId,
      receiptNumber: receiptNumberResult.dataOrNull!.value,
      lines: receiptLines,
      receivedAt: now,
      notes: notes,
      receivedBy: user.employeeId,
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    );
    final createdReceipt = await _receipts.create(receipt);

    final updatedLines = _engine.applyReceivedQuantities(lines: order.lines, quantitiesByLineId: quantitiesByLineId);
    final nextStatus = _engine.resolveStatusAfterReceive(updatedLines);
    final updatedOrder = await _orders.update(
      order.copyWith(
        lines: updatedLines,
        status: nextStatus,
        receivedAt: nextStatus == PurchaseOrderStatus.received ? now : order.receivedAt,
        updatedAt: now,
        syncStatus: LocalSyncStatus.pending,
        isDirty: true,
      ),
    );

    final supplier = await _suppliers.getById(order.supplierId, tenantId: order.tenantId);
    if (supplier != null) {
      final receiveTotal = receiptLines.fold<double>(0, (sum, l) => sum + l.quantityReceived * l.unitCost);
      await _suppliers.update(
        supplier.copyWith(
          currentBalance: supplier.currentBalance + receiveTotal,
          updatedAt: now,
          syncStatus: LocalSyncStatus.pending,
          isDirty: true,
        ),
      );
    }

    await _audit.log(
      action: AuditAction.inventoryChange,
      entityType: PurchaseReceipt.entityTypeName,
      tenantId: order.tenantId,
      employeeId: user.employeeId,
      entityId: createdReceipt.id,
      metadata: {'purchase_order_id': order.id, 'lines': receiptLines.length},
    );

    _eventBus?.publish(
      PurchaseReceivedEvent(
        eventId: _uuid.v4(),
        occurredAt: now,
        purchaseId: order.id,
        supplierId: order.supplierId,
        tenantId: order.tenantId,
        storeId: order.storeId,
      ),
    );

    return Success(createdReceipt);
  }

  Future<List<PurchaseReceipt>> listByOrder(String tenantId, String purchaseOrderId) {
    return _receipts.listByPurchaseOrder(tenantId, purchaseOrderId);
  }
}
