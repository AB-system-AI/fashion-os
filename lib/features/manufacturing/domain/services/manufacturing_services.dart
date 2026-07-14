import 'package:uuid/uuid.dart';

import 'package:fashion_pos_enterprise/core/audit/audit_action.dart';
import 'package:fashion_pos_enterprise/core/audit/audit_service.dart';
import 'package:fashion_pos_enterprise/core/business/domain/enums/business_enums.dart';
import 'package:fashion_pos_enterprise/core/business/engines/hr/hr_engine.dart';
import 'package:fashion_pos_enterprise/core/business/engines/inventory/inventory_engine.dart';
import 'package:fashion_pos_enterprise/core/business/engines/manufacturing/manufacturing_engine.dart';
import 'package:fashion_pos_enterprise/core/business/engines/number_generator_engine.dart';
import 'package:fashion_pos_enterprise/core/errors/failure.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/pagination/paginated_result.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/repository/repository_query.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_engine.dart';
import 'package:fashion_pos_enterprise/core/result/result.dart';
import 'package:fashion_pos_enterprise/features/auth/domain/entities/auth_user.dart';
import 'package:fashion_pos_enterprise/features/inventory/domain/entities/stock_reservation.dart';
import 'package:fashion_pos_enterprise/features/inventory/domain/repositories/inventory_repositories.dart';
import 'package:fashion_pos_enterprise/features/inventory/domain/services/stock_movement_service.dart';
import 'package:fashion_pos_enterprise/features/inventory/domain/value_objects/quantity.dart';
import 'package:fashion_pos_enterprise/features/manufacturing/domain/entities/bom.dart';
import 'package:fashion_pos_enterprise/features/manufacturing/domain/entities/material.dart';
import 'package:fashion_pos_enterprise/features/manufacturing/domain/entities/planning.dart';
import 'package:fashion_pos_enterprise/features/manufacturing/domain/entities/production.dart';
import 'package:fashion_pos_enterprise/features/manufacturing/domain/entities/quality.dart';
import 'package:fashion_pos_enterprise/features/manufacturing/domain/entities/work_center.dart';
import 'package:fashion_pos_enterprise/features/manufacturing/domain/entities/work_order.dart';
import 'package:fashion_pos_enterprise/features/manufacturing/domain/enums/manufacturing_enums.dart';
import 'package:fashion_pos_enterprise/features/manufacturing/domain/value_objects/manufacturing_value_objects.dart';
import 'package:fashion_pos_enterprise/features/products/domain/repositories/product_repository.dart';
import 'package:fashion_pos_enterprise/features/purchasing/domain/entities/purchase_order.dart';
import 'package:fashion_pos_enterprise/features/purchasing/domain/enums/purchasing_enums.dart';
import 'package:fashion_pos_enterprise/features/purchasing/domain/services/purchase_order_service.dart';

class BomService {
  BomService({
    required BomRepository repository,
    required ManufacturingEngine engine,
    required AuditService audit,
    required PermissionEngine permissions,
  })  : _repo = repository,
        _engine = engine,
        _audit = audit,
        _permissions = permissions;

  final BomRepository _repo;
  final ManufacturingEngine _engine;
  final AuditService _audit;
  final PermissionEngine _permissions;

  Future<Result<BillOfMaterial>> create({required AuthUser user, required BillOfMaterial bom}) async {
    try {
      _permissions.require(user, BomPermissions.manage);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final saved = await _repo.create(bom);
    await _audit.log(action: AuditAction.create, entityType: BillOfMaterial.entityTypeName, tenantId: saved.tenantId, employeeId: user.employeeId, entityId: saved.id);
    return Success(saved);
  }

  Future<Result<List<MaterialRequirement>>> explode({
    required AuthUser user,
    required BillOfMaterial bom,
    required double orderQty,
  }) async {
    try {
      _permissions.require(user, ManufacturingPermissions.view);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final lines = await _repo.listLines(bom.tenantId, bom.id);
    return Success(_engine.explodeBom(bom: bom, lines: lines, orderQty: orderQty));
  }

  Future<PaginatedResult<BillOfMaterial>> list(String tenantId) =>
      _repo.getPage(RepositoryQuery(tenantId: tenantId, pageSize: 100));

  Future<Result<BillOfMaterial>> update({required AuthUser user, required BillOfMaterial bom}) async {
    try {
      _permissions.require(user, BomPermissions.manage);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final now = DateTime.now().toUtc();
    final saved = await _repo.update(bom.copyWith(version: bom.version + 1, updatedAt: now, syncStatus: LocalSyncStatus.pending, isDirty: true));
    await _audit.log(action: AuditAction.update, entityType: BillOfMaterial.entityTypeName, tenantId: saved.tenantId, employeeId: user.employeeId, entityId: saved.id);
    return Success(saved);
  }

  Future<Result<BillOfMaterial>> archive({required AuthUser user, required BillOfMaterial bom}) async {
    try {
      _permissions.require(user, BomPermissions.manage);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final now = DateTime.now().toUtc();
    final saved = await _repo.update(bom.copyWith(active: false, version: bom.version + 1, updatedAt: now, syncStatus: LocalSyncStatus.pending, isDirty: true));
    await _audit.log(action: AuditAction.delete, entityType: BillOfMaterial.entityTypeName, tenantId: saved.tenantId, employeeId: user.employeeId, entityId: saved.id, metadata: {'archived': true});
    return Success(saved);
  }

  Future<Result<BomLine>> addLine({required AuthUser user, required BomLine line}) async {
    try {
      _permissions.require(user, BomPermissions.manage);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final saved = await _repo.createLine(line);
    await _audit.log(action: AuditAction.create, entityType: BomLine.entityTypeName, tenantId: saved.tenantId, employeeId: user.employeeId, entityId: saved.id);
    return Success(saved);
  }
}

class ProductionPlanningService {
  ProductionPlanningService({
    required BomRepository bomRepository,
    required CapacityRepository capacityRepository,
    required ManufacturingEngine engine,
    required PermissionEngine permissions,
    required StockMovementService stockMovement,
    required ProductRepository productRepository,
    required PurchaseOrderService purchaseOrderService,
  })  : _bom = bomRepository,
        _capacity = capacityRepository,
        _engine = engine,
        _permissions = permissions,
        _stock = stockMovement,
        _products = productRepository,
        _purchasing = purchaseOrderService;

  final BomRepository _bom;
  final CapacityRepository _capacity;
  final ManufacturingEngine _engine;
  final PermissionEngine _permissions;
  final StockMovementService _stock;
  final ProductRepository _products;
  final PurchaseOrderService _purchasing;

  Future<Map<String, double>> _availableStock(AuthUser user, String tenantId) async {
    final page = await _stock.listStock(user: user, tenantId: tenantId, page: 1);
    final map = <String, double>{};
    for (final level in page.items) {
      map[level.productId] = (map[level.productId] ?? 0) + level.available;
    }
    return map;
  }

  Future<Result<List<PurchaseSuggestion>>> planMrp({
    required AuthUser user,
    required BillOfMaterial bom,
    required double orderQty,
    Map<String, double>? availableStock,
  }) async {
    try {
      _permissions.require(user, PlanningPermissions.manage);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final stock = availableStock ?? await _availableStock(user, bom.tenantId);
    final lines = await _bom.listLines(bom.tenantId, bom.id);
    final requirements = _engine.explodeBom(bom: bom, lines: lines, orderQty: orderQty);
    final shortages = _engine.detectShortages(requirements: requirements, availableStock: stock);
    final supplierByProduct = <String, String?>{};
    final moqByProduct = <String, double>{};
    for (final s in shortages) {
      final product = await _products.getById(s.productId, tenantId: bom.tenantId);
      supplierByProduct[s.productId] = product?.supplierId;
      moqByProduct[s.productId] = 1;
    }
    return Success(_engine.suggestPurchases(
      shortages,
      supplierByProduct: supplierByProduct,
      minimumOrderQtyByProduct: moqByProduct,
    ));
  }

  Future<Result<List<PurchaseOrder>>> createPurchaseOrdersFromShortages({
    required AuthUser user,
    required List<PurchaseSuggestion> suggestions,
    String? storeId,
  }) async {
    try {
      _permissions.require(user, PlanningPermissions.manage);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final tenantId = user.tenantId!;
    final created = <PurchaseOrder>[];
    final bySupplier = <String, List<PurchaseSuggestion>>{};
    for (final s in suggestions) {
      final key = s.supplierId ?? 'unassigned';
      bySupplier.putIfAbsent(key, () => []).add(s);
    }
    final now = DateTime.now().toUtc();
    for (final entry in bySupplier.entries) {
      final lines = <PurchaseOrderLine>[];
      for (final s in entry.value) {
        final product = await _products.getById(s.productId, tenantId: tenantId);
        lines.add(PurchaseOrderLine(
          id: const Uuid().v4(),
          productId: s.productId,
          variantId: product?.variants.firstOrNull?.id ?? s.productId,
          quantity: s.orderQty,
          unitCost: product?.cost ?? 0,
        ));
      }
      final result = await _purchasing.create(
        user: user,
        draft: PurchaseOrder(
          id: '',
          tenantId: tenantId,
          storeId: storeId,
          supplierId: entry.key == 'unassigned' ? '' : entry.key,
          warehouseId: storeId ?? '',
          poNumber: '',
          status: PurchaseOrderStatus.draft,
          lines: lines,
          version: 1,
          createdAt: now,
          updatedAt: now,
          syncStatus: LocalSyncStatus.pending,
          isDirty: true,
        ),
      );
      if (result.isSuccess) created.add(result.dataOrNull!);
    }
    return Success(created);
  }
}

class ProductionOrderService {
  ProductionOrderService({
    required ProductionRepository repository,
    required BomRepository bomRepository,
    required ManufacturingEngine engine,
    required AuditService audit,
    required PermissionEngine permissions,
    required NumberGeneratorEngine numberGenerator,
    required StockMovementService stockMovement,
    required StockLevelRepository stockLevels,
    required StockReservationRepository reservations,
    required InventoryEngine inventoryEngine,
    required ProductionPlanningService planningService,
    Uuid? uuid,
  })  : _repo = repository,
        _bom = bomRepository,
        _engine = engine,
        _audit = audit,
        _permissions = permissions,
        _numbers = numberGenerator,
        _stock = stockMovement,
        _stockLevels = stockLevels,
        _reservations = reservations,
        _inventoryEngine = inventoryEngine,
        _planning = planningService,
        _uuid = uuid ?? const Uuid();

  final ProductionRepository _repo;
  final BomRepository _bom;
  final ManufacturingEngine _engine;
  final AuditService _audit;
  final PermissionEngine _permissions;
  final NumberGeneratorEngine _numbers;
  final StockMovementService _stock;
  final StockLevelRepository _stockLevels;
  final StockReservationRepository _reservations;
  final InventoryEngine _inventoryEngine;
  final ProductionPlanningService _planning;
  final Uuid _uuid;

  Future<Result<ProductionOrder>> create({required AuthUser user, required ProductionOrder draft}) async {
    try {
      _permissions.require(user, ProductionPermissions.create);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final numberResult = draft.orderNumber.isNotEmpty
        ? Success(draft.orderNumber)
        : (await _numbers.next(type: DocumentNumberType.productionOrder, tenantId: user.tenantId!)).map((n) => n.value);
    if (numberResult.isFailure) return Error(numberResult.failureOrNull!);
    final now = DateTime.now().toUtc();
    final order = ProductionOrder(
      id: draft.id.isEmpty ? _uuid.v4() : draft.id,
      tenantId: draft.tenantId,
      orderNumber: numberResult.dataOrNull!,
      productId: draft.productId,
      bomId: draft.bomId,
      status: draft.status,
      plannedQty: draft.plannedQty,
      warehouseId: draft.warehouseId,
      plannedStart: draft.plannedStart,
      plannedEnd: draft.plannedEnd,
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    );
    final saved = await _repo.create(order);
    if (saved.bomId != null) {
      final bom = await _bom.getById(saved.bomId!, tenantId: saved.tenantId);
      if (bom != null) {
        final lines = await _bom.listLines(saved.tenantId, bom.id);
        final reqs = _engine.explodeBom(bom: bom, lines: lines, orderQty: saved.plannedQty);
        for (final r in reqs) {
          await _repo.createLine(ProductionOrderLine(
            id: _uuid.v4(),
            tenantId: saved.tenantId,
            productionOrderId: saved.id,
            componentProductId: r.productId,
            requiredQty: r.requiredQty,
            version: 1,
            createdAt: now,
            updatedAt: now,
            syncStatus: LocalSyncStatus.pending,
            isDirty: true,
          ));
        }
      }
    }
    await _audit.log(action: AuditAction.create, entityType: ProductionOrder.entityTypeName, tenantId: saved.tenantId, employeeId: user.employeeId, entityId: saved.id);
    return Success(saved);
  }

  Future<Result<ProductionOrder>> release({required AuthUser user, required ProductionOrder order}) async {
    try {
      _permissions.require(user, ProductionPermissions.release);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final transition = _engine.validateProductionTransition(order.status, ProductionStatus.released);
    if (transition.isFailure) return Error(transition.failureOrNull!);
    final now = DateTime.now().toUtc();
    final saved = await _repo.update(order.copyWith(status: ProductionStatus.released, version: order.version + 1, updatedAt: now, syncStatus: LocalSyncStatus.pending, isDirty: true));
    await _reserveMaterials(user: user, order: saved);
    if (saved.bomId != null) {
      final bom = await _bom.getById(saved.bomId!, tenantId: saved.tenantId);
      if (bom != null) {
        final mrp = await _planning.planMrp(user: user, bom: bom, orderQty: saved.plannedQty);
        if (mrp.isSuccess && mrp.dataOrNull!.isNotEmpty) {
          await _planning.createPurchaseOrdersFromShortages(user: user, suggestions: mrp.dataOrNull!);
        }
      }
    }
    await _audit.log(action: AuditAction.update, entityType: ProductionOrder.entityTypeName, tenantId: saved.tenantId, employeeId: user.employeeId, entityId: saved.id, metadata: {'status': 'released', 'integration': 'inventory_reserve,mrp_purchasing'});
    return Success(saved);
  }

  Future<void> _reserveMaterials({required AuthUser user, required ProductionOrder order}) async {
    final warehouseId = order.warehouseId;
    if (warehouseId == null) return;
    final lines = await _repo.listLines(order.tenantId, order.id);
    final now = DateTime.now().toUtc();
    for (final line in lines) {
      final qty = line.requiredQty - line.issuedQty;
      if (qty <= 0) continue;
      final level = await _stockLevels.findLevel(tenantId: order.tenantId, warehouseId: warehouseId, productId: line.componentProductId);
      if (level == null) continue;
      final reserved = _inventoryEngine.reserveStock(level: level, quantity: Quantity(qty));
      if (reserved.isSuccess) {
        await _stockLevels.update(reserved.dataOrNull!);
        await _reservations.create(StockReservation(
          id: _uuid.v4(),
          tenantId: order.tenantId,
          warehouseId: warehouseId,
          productId: line.componentProductId,
          quantity: qty,
          referenceType: 'production_order',
          referenceId: order.id,
          version: 1,
          createdAt: now,
          updatedAt: now,
          syncStatus: LocalSyncStatus.pending,
          isDirty: true,
        ));
      }
    }
  }

  Future<Result<ProductionOrder>> start({required AuthUser user, required ProductionOrder order}) async {
    try {
      _permissions.require(user, ProductionPermissions.create);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final transition = _engine.validateProductionTransition(order.status, ProductionStatus.inProgress);
    if (transition.isFailure) return Error(transition.failureOrNull!);
    final now = DateTime.now().toUtc();
    final saved = await _repo.update(order.copyWith(status: ProductionStatus.inProgress, actualStart: now, version: order.version + 1, updatedAt: now, syncStatus: LocalSyncStatus.pending, isDirty: true));
    _engine.publishProductionStarted(productionOrderId: saved.id, tenantId: saved.tenantId);
    await _audit.log(action: AuditAction.update, entityType: ProductionOrder.entityTypeName, tenantId: saved.tenantId, employeeId: user.employeeId, entityId: saved.id, metadata: {'status': 'inProgress'});
    return Success(saved);
  }

  Future<Result<ProductionOrder>> complete({required AuthUser user, required ProductionOrder order, required double completedQty}) async {
    try {
      _permissions.require(user, ProductionPermissions.complete);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final transition = _engine.validateProductionTransition(order.status, ProductionStatus.completed);
    if (transition.isFailure) return Error(transition.failureOrNull!);
    final now = DateTime.now().toUtc();
    final saved = await _repo.update(order.copyWith(
      status: ProductionStatus.completed,
      completedQty: completedQty,
      actualEnd: now,
      version: order.version + 1,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    ));
    _engine.publishProductionCompleted(productionOrderId: saved.id, completedQty: completedQty, tenantId: saved.tenantId);
    await _audit.log(action: AuditAction.update, entityType: ProductionOrder.entityTypeName, tenantId: saved.tenantId, employeeId: user.employeeId, entityId: saved.id, metadata: {'status': 'completed'});
    return Success(saved);
  }

  Future<List<ProductionOrder>> listByStatus(String tenantId, ProductionStatus status) => _repo.listByStatus(tenantId, status);

  Future<Result<ProductionOrder>> createFromCustomerOrder({
    required AuthUser user,
    required String customerId,
    required String productId,
    required double quantity,
    String? bomId,
    String? warehouseId,
    String? customerOrderRef,
  }) async {
    final now = DateTime.now().toUtc();
    return create(
      user: user,
      draft: ProductionOrder(
        id: '',
        tenantId: user.tenantId!,
        orderNumber: '',
        productId: productId,
        bomId: bomId,
        plannedQty: quantity,
        warehouseId: warehouseId,
        version: 1,
        createdAt: now,
        updatedAt: now,
        syncStatus: LocalSyncStatus.pending,
        isDirty: true,
      ),
    );
  }
}

class WorkOrderService {
  WorkOrderService({
    required WorkOrderRepository repository,
    required ManufacturingEngine engine,
    required AuditService audit,
    required PermissionEngine permissions,
    required NumberGeneratorEngine numberGenerator,
    required HREngine hrEngine,
    Uuid? uuid,
  })  : _repo = repository,
        _engine = engine,
        _audit = audit,
        _permissions = permissions,
        _numbers = numberGenerator,
        _hr = hrEngine,
        _uuid = uuid ?? const Uuid();

  final WorkOrderRepository _repo;
  final ManufacturingEngine _engine;
  final AuditService _audit;
  final PermissionEngine _permissions;
  final NumberGeneratorEngine _numbers;
  final HREngine _hr;
  final Uuid _uuid;

  Future<Result<WorkOrder>> create({required AuthUser user, required WorkOrder draft}) async {
    try {
      _permissions.require(user, ProductionPermissions.create);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final numberResult = draft.workOrderNumber.isNotEmpty
        ? Success(draft.workOrderNumber)
        : (await _numbers.next(type: DocumentNumberType.workOrder, tenantId: user.tenantId!)).map((n) => n.value);
    if (numberResult.isFailure) return Error(numberResult.failureOrNull!);
    final now = DateTime.now().toUtc();
    final wo = WorkOrder(
      id: draft.id.isEmpty ? _uuid.v4() : draft.id,
      tenantId: draft.tenantId,
      workOrderNumber: numberResult.dataOrNull!,
      productionOrderId: draft.productionOrderId,
      workCenterId: draft.workCenterId,
      employeeId: draft.employeeId,
      status: WorkOrderStatus.draft,
      plannedHours: draft.plannedHours,
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    );
    final saved = await _repo.create(wo);
    await _audit.log(action: AuditAction.create, entityType: WorkOrder.entityTypeName, tenantId: saved.tenantId, employeeId: user.employeeId, entityId: saved.id);
    return Success(saved);
  }

  Future<Result<WorkOrder>> assign({required AuthUser user, required WorkOrder workOrder, required String employeeId}) async {
    try {
      _permissions.require(user, ProductionPermissions.create);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final transition = _engine.validateWorkOrderTransition(workOrder.status, WorkOrderStatus.assigned);
    if (transition.isFailure) return Error(transition.failureOrNull!);
    final now = DateTime.now().toUtc();
    final saved = await _repo.update(workOrder.copyWith(status: WorkOrderStatus.assigned, employeeId: employeeId, version: workOrder.version + 1, updatedAt: now, syncStatus: LocalSyncStatus.pending, isDirty: true));
    await _audit.log(action: AuditAction.update, entityType: WorkOrder.entityTypeName, tenantId: saved.tenantId, employeeId: user.employeeId, entityId: saved.id, metadata: {'status': 'assigned'});
    return Success(saved);
  }

  Future<Result<WorkOrder>> start({required AuthUser user, required WorkOrder workOrder}) async {
    try {
      _permissions.require(user, ProductionPermissions.create);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final transition = _engine.validateWorkOrderTransition(workOrder.status, WorkOrderStatus.started);
    if (transition.isFailure) return Error(transition.failureOrNull!);
    final now = DateTime.now().toUtc();
    final saved = await _repo.update(workOrder.copyWith(status: WorkOrderStatus.started, version: workOrder.version + 1, updatedAt: now, syncStatus: LocalSyncStatus.pending, isDirty: true));
    await _audit.log(action: AuditAction.update, entityType: WorkOrder.entityTypeName, tenantId: saved.tenantId, employeeId: user.employeeId, entityId: saved.id, metadata: {'status': 'started'});
    return Success(saved);
  }

  Future<Result<WorkOrder>> complete({
    required AuthUser user,
    required WorkOrder workOrder,
    double regularHours = 0,
    double overtimeHours = 0,
    double hourlyRate = 0,
    double shiftPremium = 0,
  }) async {
    try {
      _permissions.require(user, ProductionPermissions.complete);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final transition = _engine.validateWorkOrderTransition(workOrder.status, WorkOrderStatus.completed);
    if (transition.isFailure) return Error(transition.failureOrNull!);
    final laborCost = (regularHours * hourlyRate) +
        _hr.calculateOvertimeAmount(hourlyRate: hourlyRate, hours: overtimeHours) +
        (regularHours * shiftPremium);
    final actualHours = regularHours + overtimeHours;
    final now = DateTime.now().toUtc();
    final saved = await _repo.update(workOrder.copyWith(
      status: WorkOrderStatus.completed,
      actualHours: actualHours > 0 ? actualHours : workOrder.actualHours,
      version: workOrder.version + 1,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    ));
    _engine.publishWorkOrderCompleted(workOrderId: saved.id, tenantId: saved.tenantId);
    await _audit.log(
      action: AuditAction.update,
      entityType: WorkOrder.entityTypeName,
      tenantId: saved.tenantId,
      employeeId: user.employeeId,
      entityId: saved.id,
      metadata: {'status': 'completed', 'laborCost': laborCost, 'regularHours': regularHours, 'overtimeHours': overtimeHours},
    );
    return Success(saved);
  }

  Future<List<WorkOrder>> listByProductionOrder(String tenantId, String productionOrderId) =>
      _repo.listByProductionOrder(tenantId, productionOrderId);
}

class MaterialConsumptionService {
  MaterialConsumptionService({
    required ProductionRepository repository,
    required ManufacturingEngine engine,
    required AuditService audit,
    required PermissionEngine permissions,
    required StockMovementService stockMovement,
    Uuid? uuid,
  })  : _repo = repository,
        _engine = engine,
        _audit = audit,
        _permissions = permissions,
        _stock = stockMovement,
        _uuid = uuid ?? const Uuid();

  final ProductionRepository _repo;
  final ManufacturingEngine _engine;
  final AuditService _audit;
  final PermissionEngine _permissions;
  final StockMovementService _stock;
  final Uuid _uuid;

  Future<Result<MaterialIssue>> issue({required AuthUser user, required MaterialIssue issue}) async {
    try {
      _permissions.require(user, ProductionPermissions.create);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final now = DateTime.now().toUtc();
    final draft = MaterialIssue(
      id: issue.id.isEmpty ? _uuid.v4() : issue.id,
      tenantId: issue.tenantId,
      productionOrderId: issue.productionOrderId,
      productId: issue.productId,
      quantity: issue.quantity,
      warehouseId: issue.warehouseId,
      issueDate: issue.issueDate ?? now,
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    );
    final saved = await _repo.createMaterialIssue(draft);
    if (saved.warehouseId != null) {
      final stockResult = await _stock.issueStock(
        user: user,
        warehouseId: saved.warehouseId!,
        productId: saved.productId,
        quantity: saved.quantity,
        notes: 'MO material issue ${saved.productionOrderId}',
      );
      if (stockResult.isFailure) return Error(stockResult.failureOrNull!);
    }
    _engine.publishMaterialIssued(issueId: saved.id, productId: saved.productId, quantity: saved.quantity, tenantId: saved.tenantId);
    await _audit.log(action: AuditAction.create, entityType: MaterialIssue.entityTypeName, tenantId: saved.tenantId, employeeId: user.employeeId, entityId: saved.id, metadata: {'integration': 'inventory_issue'});
    return Success(saved);
  }

  Future<Result<MaterialReturn>> returnMaterial({required AuthUser user, required MaterialReturn materialReturn}) async {
    try {
      _permissions.require(user, ProductionPermissions.create);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final saved = await _repo.createMaterialReturn(materialReturn);
    if (saved.warehouseId != null) {
      final stockResult = await _stock.receiveStock(
        user: user,
        warehouseId: saved.warehouseId!,
        productId: saved.productId,
        quantity: saved.quantity,
        notes: 'MO material return ${saved.productionOrderId}',
      );
      if (stockResult.isFailure) return Error(stockResult.failureOrNull!);
    }
    _engine.publishMaterialReturned(returnId: saved.id, productId: saved.productId, quantity: saved.quantity, tenantId: saved.tenantId);
    await _audit.log(action: AuditAction.create, entityType: MaterialReturn.entityTypeName, tenantId: saved.tenantId, employeeId: user.employeeId, entityId: saved.id, metadata: {'integration': 'inventory_receive'});
    return Success(saved);
  }
}

class ProductionReceiptService {
  ProductionReceiptService({
    required ProductionRepository repository,
    required ManufacturingEngine engine,
    required AuditService audit,
    required PermissionEngine permissions,
    required StockMovementService stockMovement,
    Uuid? uuid,
  })  : _repo = repository,
        _engine = engine,
        _audit = audit,
        _permissions = permissions,
        _stock = stockMovement,
        _uuid = uuid ?? const Uuid();

  final ProductionRepository _repo;
  final ManufacturingEngine _engine;
  final AuditService _audit;
  final PermissionEngine _permissions;
  final StockMovementService _stock;
  final Uuid _uuid;

  Future<Result<FinishedGoodsReceipt>> receive({required AuthUser user, required FinishedGoodsReceipt receipt}) async {
    try {
      _permissions.require(user, ProductionPermissions.complete);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final now = DateTime.now().toUtc();
    final draft = FinishedGoodsReceipt(
      id: receipt.id.isEmpty ? _uuid.v4() : receipt.id,
      tenantId: receipt.tenantId,
      productionOrderId: receipt.productionOrderId,
      productId: receipt.productId,
      quantity: receipt.quantity,
      warehouseId: receipt.warehouseId,
      receiptDate: receipt.receiptDate ?? now,
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    );
    final saved = await _repo.createFinishedGoodsReceipt(draft);
    if (saved.warehouseId != null) {
      final stockResult = await _stock.receiveStock(
        user: user,
        warehouseId: saved.warehouseId!,
        productId: saved.productId,
        quantity: saved.quantity,
        notes: 'FG receipt MO ${saved.productionOrderId}',
      );
      if (stockResult.isFailure) return Error(stockResult.failureOrNull!);
    }
    _engine.publishFinishedGoodsReceived(receiptId: saved.id, productId: saved.productId, quantity: saved.quantity, tenantId: saved.tenantId);
    await _audit.log(action: AuditAction.create, entityType: FinishedGoodsReceipt.entityTypeName, tenantId: saved.tenantId, employeeId: user.employeeId, entityId: saved.id, metadata: {'integration': 'inventory_fg_pos'});
    return Success(saved);
  }
}

class QualityInspectionService {
  QualityInspectionService({
    required QualityRepository repository,
    required ManufacturingEngine engine,
    required AuditService audit,
    required PermissionEngine permissions,
    Uuid? uuid,
  })  : _repo = repository,
        _engine = engine,
        _audit = audit,
        _permissions = permissions,
        _uuid = uuid ?? const Uuid();

  final QualityRepository _repo;
  final ManufacturingEngine _engine;
  final AuditService _audit;
  final PermissionEngine _permissions;
  final Uuid _uuid;

  Future<Result<QualityInspection>> inspect({required AuthUser user, required QualityInspection draft}) async {
    try {
      _permissions.require(user, QualityPermissions.manage);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final result = _engine.evaluateInspection(inspected: draft.inspectedQty, passed: draft.passedQty, failed: draft.failedQty);
    final now = DateTime.now().toUtc();
    final inspection = QualityInspection(
      id: draft.id.isEmpty ? _uuid.v4() : draft.id,
      tenantId: draft.tenantId,
      productionOrderId: draft.productionOrderId,
      inspectorId: user.employeeId,
      inspectedQty: draft.inspectedQty,
      passedQty: draft.passedQty,
      failedQty: draft.failedQty,
      result: result,
      notes: draft.notes,
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    );
    final saved = await _repo.create(inspection);
    if (result == QualityResult.pass) {
      _engine.publishQualityPassed(inspectionId: saved.id, tenantId: saved.tenantId);
    } else if (result == QualityResult.fail || result == QualityResult.scrap) {
      _engine.publishQualityFailed(inspectionId: saved.id, tenantId: saved.tenantId);
    }
    await _audit.log(action: AuditAction.create, entityType: QualityInspection.entityTypeName, tenantId: saved.tenantId, employeeId: user.employeeId, entityId: saved.id);
    return Success(saved);
  }
}

class CapacityPlanningService {
  CapacityPlanningService({
    required CapacityRepository repository,
    required WorkOrderRepository workOrderRepository,
    required ManufacturingEngine engine,
    required PermissionEngine permissions,
  })  : _capacity = repository,
        _workOrders = workOrderRepository,
        _engine = engine,
        _permissions = permissions;

  final CapacityRepository _capacity;
  final WorkOrderRepository _workOrders;
  final ManufacturingEngine _engine;
  final PermissionEngine _permissions;

  Future<Result<CapacityHours>> analyze({required AuthUser user, required WorkCenter center, required double scheduledHours, required double utilizedHours}) async {
    try {
      _permissions.require(user, PlanningPermissions.manage);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    return Success(_engine.calculateCapacity(workCenter: center, scheduledHours: scheduledHours, utilizedHours: utilizedHours));
  }
}

class MaintenanceService {
  MaintenanceService({
    required QualityRepository repository,
    required AuditService audit,
    required PermissionEngine permissions,
  })  : _repo = repository,
        _audit = audit,
        _permissions = permissions;

  final QualityRepository _repo;
  final AuditService _audit;
  final PermissionEngine _permissions;

  Future<Result<MaintenanceRequest>> create({required AuthUser user, required MaintenanceRequest request}) async {
    try {
      _permissions.require(user, MaintenancePermissions.manage);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final saved = await _repo.createMaintenance(request);
    await _audit.log(action: AuditAction.create, entityType: MaintenanceRequest.entityTypeName, tenantId: saved.tenantId, employeeId: user.employeeId, entityId: saved.id);
    return Success(saved);
  }
}

class ManufacturingReportService {
  ManufacturingReportService({
    required ManufacturingEngine engine,
    required PermissionEngine permissions,
    required ProductionRepository productionRepository,
    required WorkOrderRepository workOrderRepository,
    required CapacityRepository capacityRepository,
  })  : _engine = engine,
        _permissions = permissions,
        _production = productionRepository,
        _workOrders = workOrderRepository,
        _capacity = capacityRepository;

  final ManufacturingEngine _engine;
  final PermissionEngine _permissions;
  final ProductionRepository _production;
  final WorkOrderRepository _workOrders;
  final CapacityRepository _capacity;

  ProductionVariance variance({required AuthUser user, required double planned, required double completed, required double scrapped}) {
    _permissions.require(user, ManufacturingPermissions.view);
    return _engine.calculateVariance(plannedQty: planned, completedQty: completed, scrappedQty: scrapped);
  }

  Future<ManufacturingReportBundle> generate({required AuthUser user, required String tenantId}) async {
    _permissions.require(user, ManufacturingPermissions.view);
    final orders = await _production.listByStatus(tenantId, ProductionStatus.completed);
    final inProgress = await _production.listByStatus(tenantId, ProductionStatus.inProgress);
    var totalPlanned = 0.0;
    var totalCompleted = 0.0;
    var totalScrapped = 0.0;
    for (final o in orders) {
      totalPlanned += o.plannedQty;
      totalCompleted += o.completedQty;
      totalScrapped += o.scrappedQty;
    }
    final efficiency = totalPlanned > 0 ? (totalCompleted / totalPlanned) * 100 : 0;
    final yieldRate = YieldRate(inputQty: totalPlanned, outputQty: totalCompleted);
    final scrapRate = ScrapRate(produced: totalCompleted + totalScrapped, scrapped: totalScrapped);
    return ManufacturingReportBundle(
      productionEfficiencyPercent: efficiency,
      ordersInProgress: inProgress.length,
      ordersCompleted: orders.length,
      yieldPercent: yieldRate.rate * 100,
      scrapPercent: scrapRate.rate * 100,
      totalPlannedQty: totalPlanned,
      totalCompletedQty: totalCompleted,
      totalScrappedQty: totalScrapped,
    );
  }
}

class ManufacturingReportBundle {
  const ManufacturingReportBundle({
    required this.productionEfficiencyPercent,
    required this.ordersInProgress,
    required this.ordersCompleted,
    required this.yieldPercent,
    required this.scrapPercent,
    required this.totalPlannedQty,
    required this.totalCompletedQty,
    required this.totalScrappedQty,
  });

  final double productionEfficiencyPercent;
  final int ordersInProgress;
  final int ordersCompleted;
  final double yieldPercent;
  final double scrapPercent;
  final double totalPlannedQty;
  final double totalCompletedQty;
  final double totalScrappedQty;
}

class ManufacturingBarcodeService {
  ManufacturingBarcodeService({
    required PermissionEngine permissions,
    required ProductionRepository productionRepository,
    required WorkOrderRepository workOrderRepository,
    required MaterialConsumptionService materialConsumption,
    required ProductionReceiptService productionReceipt,
  })  : _permissions = permissions,
        _production = productionRepository,
        _workOrders = workOrderRepository,
        _material = materialConsumption,
        _receipt = productionReceipt;

  final PermissionEngine _permissions;
  final ProductionRepository _production;
  final WorkOrderRepository _workOrders;
  final MaterialConsumptionService _material;
  final ProductionReceiptService _receipt;

  String productionBarcode(String orderNumber) => 'MO:$orderNumber';
  String workOrderBarcode(String workOrderNumber) => 'WO:$workOrderNumber';

  Result<BarcodeAction> parse({required AuthUser user, required String barcode}) {
    try {
      _permissions.require(user, ManufacturingPermissions.view);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    if (barcode.startsWith('MO:')) {
      return Success(BarcodeAction(type: BarcodeActionType.productionLookup, reference: barcode.substring(3)));
    }
    if (barcode.startsWith('WO:')) {
      return Success(BarcodeAction(type: BarcodeActionType.workOrderLookup, reference: barcode.substring(3)));
    }
    return const Error(ValidationFailure(message: 'Invalid manufacturing barcode', code: 'invalid_barcode'));
  }

  Future<Result<ProductionOrder?>> lookupProduction(AuthUser user, String orderNumber) async {
    final tenantId = user.tenantId;
    if (tenantId == null) return const Success(null);
    return Success(await _production.findByOrderNumber(tenantId, orderNumber));
  }

  Future<Result<WorkOrder?>> lookupWorkOrder(AuthUser user, String workOrderNumber) async {
    final tenantId = user.tenantId;
    if (tenantId == null) return const Success(null);
    final page = await _workOrders.getPage(RepositoryQuery(tenantId: tenantId, search: workOrderNumber, pageSize: 50));
    for (final w in page.items) {
      if (w.workOrderNumber == workOrderNumber) return Success(w);
    }
    return const Success(null);
  }
}

enum BarcodeActionType { productionLookup, workOrderLookup, materialIssue, finishedGoodsReceipt }

class BarcodeAction {
  const BarcodeAction({required this.type, required this.reference});
  final BarcodeActionType type;
  final String reference;
}
