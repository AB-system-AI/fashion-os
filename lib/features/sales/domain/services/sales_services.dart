import 'package:uuid/uuid.dart';

import 'package:fashion_pos_enterprise/core/audit/audit_action.dart';
import 'package:fashion_pos_enterprise/core/audit/audit_service.dart';
import 'package:fashion_pos_enterprise/core/business/domain/value_objects/money.dart';
import 'package:fashion_pos_enterprise/core/business/domain/enums/business_enums.dart';
import 'package:fashion_pos_enterprise/core/business/engines/inventory/inventory_engine.dart';
import 'package:fashion_pos_enterprise/core/business/engines/number_generator_engine.dart';
import 'package:fashion_pos_enterprise/core/business/engines/sales_order/sales_order_engine.dart';
import 'package:fashion_pos_enterprise/core/errors/failure.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/pagination/paginated_result.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/repository/repository_query.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_engine.dart';
import 'package:fashion_pos_enterprise/core/result/result.dart';
import 'package:fashion_pos_enterprise/features/auth/domain/entities/auth_user.dart';
import 'package:fashion_pos_enterprise/features/customers/domain/repositories/customer_repositories.dart';
import 'package:fashion_pos_enterprise/features/inventory/domain/entities/stock_reservation.dart';
import 'package:fashion_pos_enterprise/features/inventory/domain/repositories/inventory_repositories.dart';
import 'package:fashion_pos_enterprise/features/inventory/domain/services/stock_movement_service.dart';
import 'package:fashion_pos_enterprise/features/manufacturing/domain/entities/production.dart';
import 'package:fashion_pos_enterprise/features/manufacturing/domain/enums/manufacturing_enums.dart';
import 'package:fashion_pos_enterprise/features/manufacturing/domain/services/manufacturing_services.dart';
import 'package:fashion_pos_enterprise/features/sales/domain/entities/delivery.dart';
import 'package:fashion_pos_enterprise/features/sales/domain/entities/order.dart';
import 'package:fashion_pos_enterprise/features/sales/domain/entities/quotation.dart';
import 'package:fashion_pos_enterprise/features/sales/domain/entities/returns.dart';
import 'package:fashion_pos_enterprise/features/sales/domain/entities/shipment.dart';
import 'package:fashion_pos_enterprise/features/sales/domain/entities/timeline.dart';
import 'package:fashion_pos_enterprise/features/sales/domain/enums/sales_enums.dart';
import 'package:fashion_pos_enterprise/features/sales/domain/repositories/sales_repositories.dart';
import 'package:fashion_pos_enterprise/features/sales/domain/value_objects/sales_value_objects.dart';

class QuotationService {
  QuotationService({
    required QuotationRepository repository,
    required SalesOrderEngine engine,
    required AuditService audit,
    required PermissionEngine permissions,
    required NumberGeneratorEngine numberGenerator,
    required CustomerTimelineService timeline,
    Uuid? uuid,
  })  : _repo = repository,
        _engine = engine,
        _audit = audit,
        _permissions = permissions,
        _numbers = numberGenerator,
        _timeline = timeline,
        _uuid = uuid ?? const Uuid();

  final QuotationRepository _repo;
  final SalesOrderEngine _engine;
  final AuditService _audit;
  final PermissionEngine _permissions;
  final NumberGeneratorEngine _numbers;
  final CustomerTimelineService _timeline;
  final Uuid _uuid;

  Future<Result<Quotation>> create({
    required AuthUser user,
    required String customerId,
    required List<QuotationLineInput> lines,
    String? notes,
  }) async {
    try {
      _permissions.require(user, QuotationPermissions.create);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final number = await _numbers.next(type: DocumentNumberType.quotation, tenantId: user.tenantId!);
    if (number.isFailure) return Error(number.failureOrNull!);
    final totals = _engine.calculateQuotation(lines);
    final now = DateTime.now().toUtc();
    final quotation = await _repo.create(Quotation(
      id: _uuid.v4(),
      tenantId: user.tenantId!,
      quotationNumber: number.dataOrNull!.value,
      customerId: customerId,
      subtotal: totals.subtotal,
      discountTotal: totals.discountTotal,
      taxTotal: totals.taxTotal,
      grandTotal: totals.grandTotal,
      notes: notes,
      createdBy: user.employeeId,
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    ));
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      await _repo.createLine(QuotationLine(
        id: _uuid.v4(),
        tenantId: user.tenantId!,
        quotationId: quotation.id,
        lineNumber: i + 1,
        productId: line.productId,
        variantId: line.variantId,
        quantity: line.quantity,
        unitPrice: line.unitPrice,
        discountPercent: line.discountPercent,
        taxRate: line.taxRate,
        version: 1,
        createdAt: now,
        updatedAt: now,
        syncStatus: LocalSyncStatus.pending,
        isDirty: true,
      ));
    }
    await _timeline.record(
      user: user,
      customerId: customerId,
      eventType: TimelineEventType.quotationCreated,
      title: 'Quotation ${quotation.quotationNumber} created',
      referenceType: Quotation.entityTypeName,
      referenceId: quotation.id,
    );
    await _audit.log(action: AuditAction.create, entityType: Quotation.entityTypeName, tenantId: quotation.tenantId, employeeId: user.employeeId, entityId: quotation.id);
    return Success(quotation);
  }

  Future<Result<Quotation>> transition({
    required AuthUser user,
    required Quotation quotation,
    required QuotationStatus to,
  }) async {
    try {
      _permissions.require(user, to == QuotationStatus.accepted ? QuotationPermissions.approve : QuotationPermissions.create);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final check = _engine.canTransitionQuotation(quotation.status, to);
    if (!check.allowed) return Error(ValidationFailure(message: check.reason ?? 'Invalid transition', code: 'invalid_transition'));
    final now = DateTime.now().toUtc();
    final saved = await _repo.update(quotation.copyWith(status: to, version: quotation.version + 1, updatedAt: now, syncStatus: LocalSyncStatus.pending, isDirty: true));
    if (to == QuotationStatus.accepted && quotation.customerId != null) {
      _engine.publishQuotationAccepted(tenantId: quotation.tenantId, quotationId: quotation.id, customerId: quotation.customerId!);
    }
    await _audit.log(action: AuditAction.update, entityType: Quotation.entityTypeName, tenantId: saved.tenantId, employeeId: user.employeeId, entityId: saved.id, metadata: {'status': to.value});
    return Success(saved);
  }

  Future<PaginatedResult<Quotation>> list(String tenantId) => _repo.getPage(RepositoryQuery(tenantId: tenantId, pageSize: 200));
}

class SalesOrderService {
  SalesOrderService({
    required SalesOrderRepository repository,
    required QuotationRepository quotations,
    required SalesOrderEngine engine,
    required AuditService audit,
    required PermissionEngine permissions,
    required NumberGeneratorEngine numberGenerator,
    required CustomerRepository customers,
    required ReservationService reservations,
    required CustomerTimelineService timeline,
    ProductionOrderService? productionOrders,
    Uuid? uuid,
  })  : _repo = repository,
        _quotations = quotations,
        _engine = engine,
        _audit = audit,
        _permissions = permissions,
        _numbers = numberGenerator,
        _customers = customers,
        _reservations = reservations,
        _timeline = timeline,
        _production = productionOrders,
        _uuid = uuid ?? const Uuid();

  final SalesOrderRepository _repo;
  final QuotationRepository _quotations;
  final SalesOrderEngine _engine;
  final AuditService _audit;
  final PermissionEngine _permissions;
  final NumberGeneratorEngine _numbers;
  final CustomerRepository _customers;
  final ReservationService _reservations;
  final CustomerTimelineService _timeline;
  final ProductionOrderService? _production;
  final Uuid _uuid;

  Future<Result<SalesOrder>> createFromQuotation({required AuthUser user, required Quotation quotation}) async {
    try {
      _permissions.require(user, SalesOmsPermissions.manage);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    if (quotation.status != QuotationStatus.accepted) {
      return const Error(ValidationFailure(message: 'Quotation must be accepted', code: 'invalid_state'));
    }
    final lines = await _quotations.listLines(user.tenantId!, quotation.id);
    return create(
      user: user,
      customerId: quotation.customerId!,
      quotationId: quotation.id,
      lines: lines.map((l) => OrderLineInput(productId: l.productId, variantId: l.variantId, quantity: l.quantity, unitPrice: l.unitPrice)).toList(),
      grandTotal: quotation.grandTotal,
      subtotal: quotation.subtotal,
      discountTotal: quotation.discountTotal,
      taxTotal: quotation.taxTotal,
    );
  }

  Future<Result<SalesOrder>> create({
    required AuthUser user,
    required String customerId,
    required List<OrderLineInput> lines,
    String? quotationId,
    double? grandTotal,
    double? subtotal,
    double? discountTotal,
    double? taxTotal,
    PlanningMethod planningMethod = PlanningMethod.makeToStock,
  }) async {
    try {
      _permissions.require(user, SalesOmsPermissions.manage);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final customer = await _customers.getById(customerId, tenantId: user.tenantId);
    if (customer == null) return const Error(ValidationFailure(message: 'Customer not found', code: 'not_found'));
    final total = grandTotal ?? lines.fold<double>(0, (s, l) => s + l.quantity * l.unitPrice);
    final validation = _engine.validateOrder(
      lines: lines,
      customerId: customerId,
      creditLimit: customer.creditLimit,
      outstandingCredit: customer.outstandingCredit,
      orderTotal: total,
    );
    if (!validation.isValid) return Error(ValidationFailure(message: validation.errors.join(', '), code: 'validation_failed'));
    final number = await _numbers.next(type: DocumentNumberType.saleOrder, tenantId: user.tenantId!);
    if (number.isFailure) return Error(number.failureOrNull!);
    final now = DateTime.now().toUtc();
    var order = await _repo.create(SalesOrder(
      id: _uuid.v4(),
      tenantId: user.tenantId!,
      orderNumber: number.dataOrNull!.value,
      customerId: customerId,
      quotationId: quotationId,
      subtotal: subtotal ?? total,
      discountTotal: discountTotal ?? 0,
      taxTotal: taxTotal ?? 0,
      grandTotal: total,
      planningMethod: planningMethod,
      createdBy: user.employeeId,
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    ));
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      await _repo.createLine(SalesOrderLine(
        id: _uuid.v4(),
        tenantId: user.tenantId!,
        orderId: order.id,
        lineNumber: i + 1,
        productId: line.productId,
        variantId: line.variantId,
        quantity: line.quantity,
        unitPrice: line.unitPrice,
        version: 1,
        createdAt: now,
        updatedAt: now,
        syncStatus: LocalSyncStatus.pending,
        isDirty: true,
      ));
    }
    await _timeline.record(user: user, customerId: customerId, eventType: TimelineEventType.orderCreated, title: 'Order ${order.orderNumber}', referenceType: SalesOrder.entityTypeName, referenceId: order.id);
    await _audit.log(action: AuditAction.create, entityType: SalesOrder.entityTypeName, tenantId: order.tenantId, employeeId: user.employeeId, entityId: order.id);
    return Success(order);
  }

  Future<Result<SalesOrder>> confirm({required AuthUser user, required SalesOrder order}) async =>
      _transition(user: user, order: order, to: SalesOrderStatus.confirmed, permission: SalesOmsPermissions.manage, event: TimelineEventType.orderConfirmed);

  Future<Result<SalesOrder>> approve({required AuthUser user, required SalesOrder order, SalesSettings? settings}) async {
    if (_engine.requiresApproval(orderTotal: order.grandTotal, approvalThreshold: settings?.approvalThreshold ?? 0)) {
      try {
        _permissions.require(user, SalesApprovalPermissions.approve);
      } on PermissionDeniedException catch (e) {
        return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
      }
    }
    final result = await _transition(user: user, order: order, to: SalesOrderStatus.approved, permission: SalesApprovalPermissions.approve, event: TimelineEventType.orderApproved);
    if (result.isFailure) return result;
    if (settings?.autoReserveOnApprove ?? true) {
      await _reservations.reserveForOrder(user: user, order: result.dataOrNull!);
    }
    if (order.planningMethod == PlanningMethod.makeToOrder && _production != null) {
      final now = DateTime.now().toUtc();
      final firstLine = (await _repo.listLines(order.tenantId, order.id)).firstOrNull;
      if (firstLine != null) {
        final po = await _production!.create(
          user: user,
          draft: ProductionOrder(
            id: '',
            tenantId: order.tenantId,
            orderNumber: '',
            productId: firstLine.productId,
            plannedQty: firstLine.quantity,
            version: 1,
            createdAt: now,
            updatedAt: now,
            syncStatus: LocalSyncStatus.pending,
            isDirty: true,
            status: ProductionStatus.draft,
          ),
        );
        if (po.isSuccess) {
          await _repo.update(result.dataOrNull!.copyWith(productionOrderId: po.dataOrNull!.id, version: result.dataOrNull!.version + 1, updatedAt: now, syncStatus: LocalSyncStatus.pending, isDirty: true));
        }
      }
    }
    return result;
  }

  Future<Result<SalesOrder>> _transition({
    required AuthUser user,
    required SalesOrder order,
    required SalesOrderStatus to,
    required String permission,
    required TimelineEventType event,
  }) async {
    try {
      _permissions.require(user, permission);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final check = _engine.canTransitionOrder(order.status, to);
    if (!check.allowed) return Error(ValidationFailure(message: check.reason ?? 'Invalid transition', code: 'invalid_transition'));
    final now = DateTime.now().toUtc();
    final saved = await _repo.update(order.copyWith(status: to, version: order.version + 1, updatedAt: now, syncStatus: LocalSyncStatus.pending, isDirty: true));
    if (order.customerId != null) {
      await _timeline.record(user: user, customerId: order.customerId!, eventType: event, title: 'Order ${order.orderNumber} → ${to.value}', referenceType: SalesOrder.entityTypeName, referenceId: order.id);
    }
    if (to == SalesOrderStatus.confirmed && order.customerId != null) {
      _engine.publishSalesOrderConfirmed(tenantId: order.tenantId, orderId: order.id, customerId: order.customerId!, grandTotal: order.grandTotal);
    }
    await _audit.log(action: AuditAction.update, entityType: SalesOrder.entityTypeName, tenantId: saved.tenantId, employeeId: user.employeeId, entityId: saved.id, metadata: {'status': to.value});
    return Success(saved);
  }

  Future<PaginatedResult<SalesOrder>> list(String tenantId) => _repo.getPage(RepositoryQuery(tenantId: tenantId, pageSize: 200));
  Future<SalesOrder?> getById(String id, String tenantId) => _repo.getById(id, tenantId: tenantId);
}

class ReservationService {
  ReservationService({
    required SalesReservationRepository repository,
    required SalesOrderRepository orders,
    required StockLevelRepository stockLevels,
    required StockReservationRepository stockReservations,
    required InventoryEngine inventoryEngine,
    required SalesOrderEngine engine,
    required AuditService audit,
    required PermissionEngine permissions,
    required CustomerTimelineService timeline,
    Uuid? uuid,
  })  : _repo = repository,
        _orders = orders,
        _stockLevels = stockLevels,
        _stockReservations = stockReservations,
        _inventoryEngine = inventoryEngine,
        _engine = engine,
        _audit = audit,
        _permissions = permissions,
        _timeline = timeline,
        _uuid = uuid ?? const Uuid();

  final SalesReservationRepository _repo;
  final SalesOrderRepository _orders;
  final StockLevelRepository _stockLevels;
  final StockReservationRepository _stockReservations;
  final InventoryEngine _inventoryEngine;
  final SalesOrderEngine _engine;
  final AuditService _audit;
  final PermissionEngine _permissions;
  final CustomerTimelineService _timeline;
  final Uuid _uuid;

  Future<Result<List<SalesReservation>>> reserveForOrder({required AuthUser user, required SalesOrder order}) async {
    try {
      _permissions.require(user, SalesOmsPermissions.manage);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final lines = await _orders.listLines(order.tenantId, order.id);
    final stockPage = await _stockLevels.getPage(RepositoryQuery(tenantId: order.tenantId, pageSize: 2000));
    final available = {for (final l in stockPage.items) l.productId: l.onHand - l.reserved};
    final plans = _engine.planReservations(
      lines: lines.map((l) => OrderLineInput(productId: l.productId, variantId: l.variantId, quantity: l.quantity, unitPrice: l.unitPrice, warehouseId: order.warehouseId)).toList(),
      defaultWarehouseId: order.warehouseId ?? stockPage.items.firstOrNull?.warehouseId ?? '',
      availableByProduct: available,
    );
    final now = DateTime.now().toUtc();
    final created = <SalesReservation>[];
    for (var i = 0; i < lines.length; i++) {
      final plan = plans[i];
      if (plan.quantity <= 0 && plan.shortfall <= 0) continue;
      if (plan.shortfall > 0) {
        await _repo.createBackOrder(BackOrder(
          id: _uuid.v4(),
          tenantId: order.tenantId,
          orderId: order.id,
          orderLineId: lines[i].id,
          productId: plan.productId,
          quantity: plan.shortfall,
          version: 1,
          createdAt: now,
          updatedAt: now,
          syncStatus: LocalSyncStatus.pending,
          isDirty: true,
        ));
      }
      if (plan.quantity > 0) {
        final level = stockPage.items.where((l) => l.productId == plan.productId).firstOrNull;
        if (level != null) {
          final reserveResult = _inventoryEngine.reserveStock(level: level, quantity: Quantity(plan.quantity));
          if (reserveResult.isSuccess) {
            await _stockLevels.update(reserveResult.dataOrNull!);
          }
        }
        final stockRes = await _stockReservations.create(StockReservation(
          id: _uuid.v4(),
          tenantId: order.tenantId,
          warehouseId: plan.warehouseId,
          productId: plan.productId,
          variantId: plan.variantId,
          quantity: plan.quantity,
          referenceType: SalesOrder.entityTypeName,
          referenceId: order.id,
          version: 1,
          createdAt: now,
          updatedAt: now,
          syncStatus: LocalSyncStatus.pending,
          isDirty: true,
        ));
        final salesRes = await _repo.create(SalesReservation(
          id: _uuid.v4(),
          tenantId: order.tenantId,
          orderId: order.id,
          orderLineId: lines[i].id,
          productId: plan.productId,
          warehouseId: plan.warehouseId,
          quantity: plan.quantity,
          stockReservationId: stockRes.id,
          version: 1,
          createdAt: now,
          updatedAt: now,
          syncStatus: LocalSyncStatus.pending,
          isDirty: true,
        ));
        created.add(salesRes);
      }
    }
    await _orders.update(order.copyWith(status: SalesOrderStatus.reserved, version: order.version + 1, updatedAt: now, syncStatus: LocalSyncStatus.pending, isDirty: true));
    if (order.customerId != null) {
      await _timeline.record(user: user, customerId: order.customerId!, eventType: TimelineEventType.stockReserved, title: 'Stock reserved for ${order.orderNumber}', referenceType: SalesOrder.entityTypeName, referenceId: order.id);
    }
    await _audit.log(action: AuditAction.update, entityType: SalesReservation.entityTypeName, tenantId: order.tenantId, employeeId: user.employeeId, entityId: order.id);
    return Success(created);
  }
}

class ShipmentService {
  ShipmentService({
    required ShipmentRepository repository,
    required SalesOrderRepository orders,
    required SalesOrderEngine engine,
    required AuditService audit,
    required PermissionEngine permissions,
    required NumberGeneratorEngine numberGenerator,
    required StockMovementService stockMovement,
    required CustomerTimelineService timeline,
    Uuid? uuid,
  })  : _repo = repository,
        _orders = orders,
        _engine = engine,
        _audit = audit,
        _permissions = permissions,
        _numbers = numberGenerator,
        _stock = stockMovement,
        _timeline = timeline,
        _uuid = uuid ?? const Uuid();

  final ShipmentRepository _repo;
  final SalesOrderRepository _orders;
  final SalesOrderEngine _engine;
  final AuditService _audit;
  final PermissionEngine _permissions;
  final NumberGeneratorEngine _numbers;
  final StockMovementService _stock;
  final CustomerTimelineService _timeline;
  final Uuid _uuid;

  Future<Result<Shipment>> create({required AuthUser user, required SalesOrder order}) async {
    try {
      _permissions.require(user, ShipmentPermissions.manage);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final number = await _numbers.next(type: DocumentNumberType.shipmentDoc, tenantId: user.tenantId!);
    if (number.isFailure) return Error(number.failureOrNull!);
    final lines = await _orders.listLines(order.tenantId, order.id);
    final now = DateTime.now().toUtc();
    final shipment = await _repo.create(Shipment(
      id: _uuid.v4(),
      tenantId: user.tenantId!,
      shipmentNumber: number.dataOrNull!.value,
      orderId: order.id,
      warehouseId: order.warehouseId,
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    ));
    for (final line in lines) {
      await _repo.createLine(ShipmentLine(
        id: _uuid.v4(),
        tenantId: user.tenantId!,
        shipmentId: shipment.id,
        orderLineId: line.id,
        productId: line.productId,
        quantity: line.quantity - line.shippedQty,
        version: 1,
        createdAt: now,
        updatedAt: now,
        syncStatus: LocalSyncStatus.pending,
        isDirty: true,
      ));
    }
    await _timeline.record(user: user, customerId: order.customerId ?? '', eventType: TimelineEventType.shipmentCreated, title: 'Shipment ${shipment.shipmentNumber}', referenceType: Shipment.entityTypeName, referenceId: shipment.id);
    await _audit.log(action: AuditAction.create, entityType: Shipment.entityTypeName, tenantId: shipment.tenantId, employeeId: user.employeeId, entityId: shipment.id);
    return Success(shipment);
  }

  Future<Result<Shipment>> dispatch({required AuthUser user, required Shipment shipment}) async {
    try {
      _permissions.require(user, ShipmentPermissions.manage);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final check = _engine.canTransitionShipment(shipment.status, ShipmentStatus.dispatched);
    if (!check.allowed) return Error(ValidationFailure(message: check.reason ?? 'Invalid transition', code: 'invalid_transition'));
    final now = DateTime.now().toUtc();
    final saved = await _repo.update(shipment.copyWith(status: ShipmentStatus.dispatched, shippedAt: now, version: shipment.version + 1, updatedAt: now, syncStatus: LocalSyncStatus.pending, isDirty: true));
    _engine.publishShipmentDispatched(tenantId: shipment.tenantId, shipmentId: shipment.id, orderId: shipment.orderId);
    await _audit.log(action: AuditAction.update, entityType: Shipment.entityTypeName, tenantId: saved.tenantId, employeeId: user.employeeId, entityId: saved.id, metadata: {'status': 'dispatched'});
    return Success(saved);
  }

  Future<List<Shipment>> listByStatus(String tenantId, ShipmentStatus status) => _repo.listByStatus(tenantId, status);
}

class DeliveryService {
  DeliveryService({
    required DeliveryRepository repository,
    required ShipmentRepository shipments,
    required SalesOrderEngine engine,
    required AuditService audit,
    required PermissionEngine permissions,
    required NumberGeneratorEngine numberGenerator,
    required CustomerTimelineService timeline,
    Uuid? uuid,
  })  : _repo = repository,
        _shipments = shipments,
        _engine = engine,
        _audit = audit,
        _permissions = permissions,
        _numbers = numberGenerator,
        _timeline = timeline,
        _uuid = uuid ?? const Uuid();

  final DeliveryRepository _repo;
  final ShipmentRepository _shipments;
  final SalesOrderEngine _engine;
  final AuditService _audit;
  final PermissionEngine _permissions;
  final NumberGeneratorEngine _numbers;
  final CustomerTimelineService _timeline;
  final Uuid _uuid;

  Future<Result<Delivery>> createFromShipment({required AuthUser user, required Shipment shipment, String? recipientName, String? address}) async {
    try {
      _permissions.require(user, DeliveryPermissions.manage);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final now = DateTime.now().toUtc();
    final delivery = await _repo.create(Delivery(
      id: _uuid.v4(),
      tenantId: user.tenantId!,
      deliveryNumber: 'DEL-${now.millisecondsSinceEpoch}',
      shipmentId: shipment.id,
      orderId: shipment.orderId,
      recipientName: recipientName,
      address: address,
      estimatedAt: now.add(const Duration(days: 3)),
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    ));
    await _audit.log(action: AuditAction.create, entityType: Delivery.entityTypeName, tenantId: delivery.tenantId, employeeId: user.employeeId, entityId: delivery.id);
    return Success(delivery);
  }

  Future<Result<Delivery>> markDelivered({required AuthUser user, required Delivery delivery, String? customerId}) async {
    try {
      _permissions.require(user, DeliveryPermissions.manage);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final now = DateTime.now().toUtc();
    final saved = await _repo.update(delivery.copyWith(status: DeliveryStatus.delivered, deliveredAt: now, version: delivery.version + 1, updatedAt: now, syncStatus: LocalSyncStatus.pending, isDirty: true));
    if (customerId != null && customerId.isNotEmpty) {
      await _timeline.record(user: user, customerId: customerId, eventType: TimelineEventType.delivered, title: 'Delivery ${delivery.deliveryNumber} completed', referenceType: Delivery.entityTypeName, referenceId: delivery.id);
    }
    return Success(saved);
  }
}

class ReturnService {
  ReturnService({
    required ReturnRepository repository,
    required SalesOrderRepository orders,
    required SalesOrderEngine engine,
    required AuditService audit,
    required PermissionEngine permissions,
    required CustomerTimelineService timeline,
    Uuid? uuid,
  })  : _repo = repository,
        _orders = orders,
        _engine = engine,
        _audit = audit,
        _permissions = permissions,
        _timeline = timeline,
        _uuid = uuid ?? const Uuid();

  final ReturnRepository _repo;
  final SalesOrderRepository _orders;
  final SalesOrderEngine _engine;
  final AuditService _audit;
  final PermissionEngine _permissions;
  final CustomerTimelineService _timeline;
  final Uuid _uuid;

  Future<Result<SalesReturnRequest>> create({
    required AuthUser user,
    required String orderId,
    required String orderLineId,
    required double quantity,
    String? reason,
  }) async {
    try {
      _permissions.require(user, SalesReturnPermissions.manage);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final order = await _orders.getById(orderId, tenantId: user.tenantId);
    if (order == null) return const Error(ValidationFailure(message: 'Order not found', code: 'not_found'));
    final line = (await _orders.listLines(user.tenantId!, orderId)).where((l) => l.id == orderLineId).firstOrNull;
    if (line == null) return const Error(ValidationFailure(message: 'Line not found', code: 'not_found'));
    final validation = _engine.validateReturn(originalQty: line.quantity, returnQty: quantity, alreadyReturned: line.returnedQty);
    if (!validation.isValid) return Error(ValidationFailure(message: validation.message ?? 'Invalid return', code: 'validation_failed'));
    final now = DateTime.now().toUtc();
    final request = await _repo.create(SalesReturnRequest(
      id: _uuid.v4(),
      tenantId: user.tenantId!,
      returnNumber: 'RTN-${now.millisecondsSinceEpoch}',
      orderId: orderId,
      orderLineId: orderLineId,
      quantity: quantity,
      reason: reason,
      refundAmount: quantity * line.unitPrice,
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    ));
    await _orders.updateLine(line.copyWith(returnedQty: line.returnedQty + quantity, version: line.version + 1, updatedAt: now, syncStatus: LocalSyncStatus.pending, isDirty: true));
    if (order.customerId != null) {
      await _timeline.record(user: user, customerId: order.customerId!, eventType: TimelineEventType.returnRequested, title: 'Return requested', referenceType: SalesReturnRequest.entityTypeName, referenceId: request.id);
    }
    await _audit.log(action: AuditAction.create, entityType: SalesReturnRequest.entityTypeName, tenantId: request.tenantId, employeeId: user.employeeId, entityId: request.id);
    return Success(request);
  }
}

class ExchangeService {
  ExchangeService({
    required ExchangeRepository repository,
    required SalesOrderEngine engine,
    required AuditService audit,
    required PermissionEngine permissions,
    required CustomerTimelineService timeline,
    Uuid? uuid,
  })  : _repo = repository,
        _engine = engine,
        _audit = audit,
        _permissions = permissions,
        _timeline = timeline,
        _uuid = uuid ?? const Uuid();

  final ExchangeRepository _repo;
  final SalesOrderEngine _engine;
  final AuditService _audit;
  final PermissionEngine _permissions;
  final CustomerTimelineService _timeline;
  final Uuid _uuid;

  Future<Result<ExchangeRequest>> create({
    required AuthUser user,
    required String orderId,
    required double returnValue,
    required String newProductId,
    required double newValue,
    String? customerId,
  }) async {
    try {
      _permissions.require(user, SalesExchangePermissions.manage);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final validation = _engine.validateExchange(returnValue: returnValue, newValue: newValue);
    if (!validation.isValid) return Error(ValidationFailure(message: validation.message ?? 'Invalid exchange', code: 'validation_failed'));
    final now = DateTime.now().toUtc();
    final request = await _repo.create(ExchangeRequest(
      id: _uuid.v4(),
      tenantId: user.tenantId!,
      exchangeNumber: 'EXC-${now.millisecondsSinceEpoch}',
      orderId: orderId,
      newProductId: newProductId,
      priceDifference: validation.priceDifference,
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    ));
    if (customerId != null) {
      await _timeline.record(user: user, customerId: customerId, eventType: TimelineEventType.exchangeRequested, title: 'Exchange requested', referenceType: ExchangeRequest.entityTypeName, referenceId: request.id);
    }
    await _audit.log(action: AuditAction.create, entityType: ExchangeRequest.entityTypeName, tenantId: request.tenantId, employeeId: user.employeeId, entityId: request.id);
    return Success(request);
  }
}

class CustomerTimelineService {
  CustomerTimelineService({required CustomerTimelineRepository repository, Uuid? uuid}) : _repo = repository, _uuid = uuid ?? const Uuid();

  final CustomerTimelineRepository _repo;
  final Uuid _uuid;

  Future<void> record({
    required AuthUser user,
    required String customerId,
    required TimelineEventType eventType,
    required String title,
    String? description,
    String? referenceType,
    String? referenceId,
  }) async {
    if (customerId.isEmpty) return;
    final now = DateTime.now().toUtc();
    await _repo.create(CustomerOrderTimeline(
      id: _uuid.v4(),
      tenantId: user.tenantId!,
      customerId: customerId,
      eventType: eventType,
      title: title,
      description: description,
      referenceType: referenceType,
      referenceId: referenceId,
      employeeId: user.employeeId,
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    ));
  }

  Future<List<CustomerOrderTimeline>> list(String tenantId, String customerId) => _repo.listByCustomer(tenantId, customerId);
}

class SalesReportService {
  SalesReportService({
    required QuotationRepository quotations,
    required SalesOrderRepository orders,
    required SalesReservationRepository reservations,
    required ShipmentRepository shipments,
    required SalesOrderEngine engine,
    required PermissionEngine permissions,
  })  : _quotations = quotations,
        _orders = orders,
        _reservations = reservations,
        _shipments = shipments,
        _engine = engine,
        _permissions = permissions;

  final QuotationRepository _quotations;
  final SalesOrderRepository _orders;
  final SalesReservationRepository _reservations;
  final ShipmentRepository _shipments;
  final SalesOrderEngine _engine;
  final PermissionEngine _permissions;

  Future<Result<SalesReportSummary>> generate({required AuthUser user}) async {
    try {
      _permissions.require(user, SalesOmsPermissions.view);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final tenantId = user.tenantId!;
    final sent = await _quotations.listByStatus(tenantId, QuotationStatus.sent);
    final accepted = await _quotations.listByStatus(tenantId, QuotationStatus.accepted);
    final openOrders = await _orders.listByStatus(tenantId, SalesOrderStatus.confirmed);
    final approved = await _orders.listByStatus(tenantId, SalesOrderStatus.approved);
    final backorders = await _reservations.listBackOrders(tenantId, status: BackOrderStatus.open);
    final pendingShipments = await _shipments.listByStatus(tenantId, ShipmentStatus.pending);
    final allOrders = await _orders.getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    final shippedQty = allOrders.items.fold<double>(0, (s, o) => s + (o.status.index >= SalesOrderStatus.shipped.index ? 1 : 0));
    return Success(SalesReportSummary(
      openOrders: openOrders.length + approved.length,
      quotationsSent: sent.length,
      conversionRate: _engine.conversionRate(quotationsSent: sent.length + accepted.length, ordersCreated: allOrders.items.length),
      fulfillmentRate: _engine.fulfillmentRate(orderedQty: allOrders.items.length.toDouble(), shippedQty: shippedQty),
      openBackorders: backorders.length,
      pendingShipments: pendingShipments.length,
    ));
  }
}
