import 'package:fashion_pos_enterprise/core/business/events/business_events.dart';
import 'package:fashion_pos_enterprise/core/business/events/domain_event_bus.dart';
import 'package:fashion_pos_enterprise/core/errors/failure.dart';
import 'package:fashion_pos_enterprise/core/result/result.dart';
import 'package:fashion_pos_enterprise/features/manufacturing/domain/entities/bom.dart';
import 'package:fashion_pos_enterprise/features/manufacturing/domain/entities/planning.dart';
import 'package:fashion_pos_enterprise/features/manufacturing/domain/entities/production.dart';
import 'package:fashion_pos_enterprise/features/manufacturing/domain/entities/work_center.dart';
import 'package:fashion_pos_enterprise/features/manufacturing/domain/entities/work_order.dart';
import 'package:fashion_pos_enterprise/features/manufacturing/domain/enums/manufacturing_enums.dart';
import 'package:fashion_pos_enterprise/features/manufacturing/domain/value_objects/manufacturing_value_objects.dart';
import 'package:uuid/uuid.dart';

class MaterialRequirement {
  const MaterialRequirement({required this.productId, required this.requiredQty, this.shortage = 0});

  final String productId;
  final double requiredQty;
  final double shortage;
}

class ProductionCostBreakdown {
  const ProductionCostBreakdown({
    required this.materialCost,
    required this.laborCost,
    required this.overheadCost,
    required this.totalCost,
    required this.unitCost,
  });

  final double materialCost;
  final double laborCost;
  final double overheadCost;
  final double totalCost;
  final double unitCost;
}

class ProductionVariance {
  const ProductionVariance({
    required this.plannedQty,
    required this.completedQty,
    required this.scrappedQty,
    required this.yieldVariance,
    required this.scrapVariance,
  });

  final double plannedQty;
  final double completedQty;
  final double scrappedQty;
  final double yieldVariance;
  final double scrapVariance;
}

class PurchaseSuggestion {
  const PurchaseSuggestion({
    required this.productId,
    required this.suggestedQty,
    this.supplierId,
    this.minimumOrderQty = 1,
    this.leadTimeDays = 7,
    this.supplierPriority = 1,
  });

  final String productId;
  final double suggestedQty;
  final String? supplierId;
  final double minimumOrderQty;
  final int leadTimeDays;
  final int supplierPriority;

  double get orderQty => suggestedQty < minimumOrderQty ? minimumOrderQty : suggestedQty;
}

/// Pure manufacturing rules: BOM explosion, MRP, costing, capacity.
class ManufacturingEngine {
  ManufacturingEngine({DomainEventBus? eventBus, Uuid? uuid})
      : _eventBus = eventBus,
        _uuid = uuid ?? const Uuid();

  final DomainEventBus? _eventBus;
  final Uuid _uuid;

  Result<void> validateProductionTransition(ProductionStatus from, ProductionStatus to) {
    const allowed = {
      ProductionStatus.draft: {ProductionStatus.planned, ProductionStatus.cancelled},
      ProductionStatus.planned: {ProductionStatus.released, ProductionStatus.cancelled},
      ProductionStatus.released: {ProductionStatus.inProgress, ProductionStatus.cancelled},
      ProductionStatus.inProgress: {ProductionStatus.paused, ProductionStatus.completed, ProductionStatus.cancelled},
      ProductionStatus.paused: {ProductionStatus.inProgress, ProductionStatus.cancelled},
      ProductionStatus.completed: {ProductionStatus.closed},
      ProductionStatus.closed: {},
      ProductionStatus.cancelled: {},
    };
    if (!(allowed[from]?.contains(to) ?? false)) {
      return Error(ValidationFailure(
        message: 'Cannot transition production from ${from.value} to ${to.value}',
        code: 'invalid_transition',
      ));
    }
    return const Success(null);
  }

  Result<void> validateWorkOrderTransition(WorkOrderStatus from, WorkOrderStatus to) {
    const allowed = {
      WorkOrderStatus.draft: {WorkOrderStatus.assigned, WorkOrderStatus.rejected},
      WorkOrderStatus.assigned: {WorkOrderStatus.started, WorkOrderStatus.rejected},
      WorkOrderStatus.started: {WorkOrderStatus.paused, WorkOrderStatus.completed, WorkOrderStatus.rejected},
      WorkOrderStatus.paused: {WorkOrderStatus.started, WorkOrderStatus.rejected},
      WorkOrderStatus.completed: {},
      WorkOrderStatus.rejected: {},
    };
    if (!(allowed[from]?.contains(to) ?? false)) {
      return Error(ValidationFailure(
        message: 'Cannot transition work order from ${from.value} to ${to.value}',
        code: 'invalid_transition',
      ));
    }
    return const Success(null);
  }

  List<MaterialRequirement> explodeBom({
    required BillOfMaterial bom,
    required List<BomLine> lines,
    required double orderQty,
    Map<String, List<BomLine>>? subBomsByProduct,
  }) {
    final scale = orderQty / (bom.quantity > 0 ? bom.quantity : 1);
    final requirements = <String, double>{};

    void addLine(BomLine line, double multiplier) {
      final qty = _round(line.quantity * multiplier * (1 + line.scrapPercent / 100));
      requirements[line.componentProductId] = (requirements[line.componentProductId] ?? 0) + qty;
      final subLines = subBomsByProduct?[line.componentProductId];
      if (subLines != null) {
        for (final sub in subLines) {
          addLine(sub, qty);
        }
      }
    }

    for (final line in lines) {
      addLine(line, scale);
    }

    return requirements.entries
        .map((e) => MaterialRequirement(productId: e.key, requiredQty: e.value))
        .toList();
  }

  List<MaterialRequirement> detectShortages({
    required List<MaterialRequirement> requirements,
    required Map<String, double> availableStock,
  }) {
    return requirements.map((r) {
      final available = availableStock[r.productId] ?? 0;
      final shortage = (r.requiredQty - available).clamp(0, double.infinity);
      return MaterialRequirement(productId: r.productId, requiredQty: r.requiredQty, shortage: _round(shortage));
    }).where((r) => r.shortage > 0).toList();
  }

  List<PurchaseSuggestion> suggestPurchases(
    List<MaterialRequirement> shortages, {
    Map<String, String?> supplierByProduct = const {},
    Map<String, double> minimumOrderQtyByProduct = const {},
    Map<String, int> leadTimeDaysByProduct = const {},
    Map<String, int> supplierPriorityByProduct = const {},
  }) {
    return shortages
        .where((s) => s.shortage > 0)
        .map((s) => PurchaseSuggestion(
              productId: s.productId,
              suggestedQty: s.shortage,
              supplierId: supplierByProduct[s.productId],
              minimumOrderQty: minimumOrderQtyByProduct[s.productId] ?? 1,
              leadTimeDays: leadTimeDaysByProduct[s.productId] ?? 7,
              supplierPriority: supplierPriorityByProduct[s.productId] ?? 1,
            ))
        .toList()
      ..sort((a, b) => a.supplierPriority.compareTo(b.supplierPriority));
  }

  CapacityHours calculateCapacity({
    required WorkCenter workCenter,
    required double scheduledHours,
    required double utilizedHours,
  }) {
    final status = scheduledHours > workCenter.capacityHoursPerDay
        ? CapacityStatus.overloaded
        : scheduledHours > workCenter.capacityHoursPerDay * 0.8
            ? CapacityStatus.partial
            : CapacityStatus.available;
    return CapacityHours(
      available: workCenter.capacityHoursPerDay,
      scheduled: scheduledHours,
      utilized: utilizedHours,
    );
  }

  double machineUtilization({required double utilizedHours, required double availableHours}) {
    if (availableHours <= 0) return 0;
    return _round((utilizedHours / availableHours) * 100);
  }

  ProductionCostBreakdown calculateProductionCost({
    required double materialCost,
    required double laborHours,
    required double laborRate,
    required double overheadRate,
    required double completedQty,
  }) {
    final labor = _round(laborHours * laborRate);
    final overhead = _round(labor * overheadRate);
    final total = _round(materialCost + labor + overhead);
    final unit = completedQty > 0 ? _round(total / completedQty) : 0;
    return ProductionCostBreakdown(
      materialCost: materialCost,
      laborCost: labor,
      overheadCost: overhead,
      totalCost: total,
      unitCost: unit,
    );
  }

  ProductionVariance calculateVariance({
    required double plannedQty,
    required double completedQty,
    required double scrappedQty,
  }) {
    final yield = YieldRate(inputQty: plannedQty, outputQty: completedQty);
    final scrap = ScrapRate(produced: completedQty + scrappedQty, scrapped: scrappedQty);
    return ProductionVariance(
      plannedQty: plannedQty,
      completedQty: completedQty,
      scrappedQty: scrappedQty,
      yieldVariance: _round((yield.rate - 1) * plannedQty),
      scrapVariance: _round(scrap.rate * 100),
    );
  }

  double calculateWipValuation({
    required double materialIssued,
    required double laborCost,
    required double completionPercent,
  }) {
    return _round((materialIssued + laborCost) * completionPercent.clamp(0, 1));
  }

  DateTime? expectedCompletion({
    required DateTime start,
    required double remainingQty,
    required OperationDuration duration,
  }) {
    if (remainingQty <= 0) return start;
    final minutes = duration.totalMinutes(remainingQty);
    return start.add(Duration(minutes: minutes.ceil()));
  }

  QualityResult evaluateInspection({required double inspected, required double passed, required double failed}) {
    if (failed <= 0 && passed >= inspected) return QualityResult.pass;
    if (passed <= 0) return QualityResult.fail;
    if (failed > 0 && passed > 0) return QualityResult.hold;
    return QualityResult.rework;
  }

  void publishProductionStarted({required String productionOrderId, String? tenantId}) {
    _eventBus?.publish(ProductionStartedEvent(
      eventId: _uuid.v4(),
      occurredAt: DateTime.now().toUtc(),
      productionOrderId: productionOrderId,
      tenantId: tenantId,
    ));
  }

  void publishProductionCompleted({required String productionOrderId, required double completedQty, String? tenantId}) {
    _eventBus?.publish(ProductionCompletedEvent(
      eventId: _uuid.v4(),
      occurredAt: DateTime.now().toUtc(),
      productionOrderId: productionOrderId,
      completedQty: completedQty,
      tenantId: tenantId,
    ));
  }

  void publishWorkOrderCompleted({required String workOrderId, String? tenantId}) {
    _eventBus?.publish(WorkOrderCompletedEvent(
      eventId: _uuid.v4(),
      occurredAt: DateTime.now().toUtc(),
      workOrderId: workOrderId,
      tenantId: tenantId,
    ));
  }

  void publishMaterialIssued({required String issueId, required String productId, required double quantity, String? tenantId}) {
    _eventBus?.publish(MaterialIssuedEvent(
      eventId: _uuid.v4(),
      occurredAt: DateTime.now().toUtc(),
      issueId: issueId,
      productId: productId,
      quantity: quantity,
      tenantId: tenantId,
    ));
  }

  void publishMaterialReturned({required String returnId, required String productId, required double quantity, String? tenantId}) {
    _eventBus?.publish(MaterialReturnedEvent(
      eventId: _uuid.v4(),
      occurredAt: DateTime.now().toUtc(),
      returnId: returnId,
      productId: productId,
      quantity: quantity,
      tenantId: tenantId,
    ));
  }

  void publishQualityPassed({required String inspectionId, String? tenantId}) {
    _eventBus?.publish(QualityPassedEvent(
      eventId: _uuid.v4(),
      occurredAt: DateTime.now().toUtc(),
      inspectionId: inspectionId,
      tenantId: tenantId,
    ));
  }

  void publishQualityFailed({required String inspectionId, String? tenantId}) {
    _eventBus?.publish(QualityFailedEvent(
      eventId: _uuid.v4(),
      occurredAt: DateTime.now().toUtc(),
      inspectionId: inspectionId,
      tenantId: tenantId,
    ));
  }

  void publishFinishedGoodsReceived({
    required String receiptId,
    required String productId,
    required double quantity,
    String? tenantId,
  }) {
    _eventBus?.publish(FinishedGoodsReceivedEvent(
      eventId: _uuid.v4(),
      occurredAt: DateTime.now().toUtc(),
      receiptId: receiptId,
      productId: productId,
      quantity: quantity,
      tenantId: tenantId,
    ));
  }

  double _round(double v) => double.parse(v.toStringAsFixed(4));
}
