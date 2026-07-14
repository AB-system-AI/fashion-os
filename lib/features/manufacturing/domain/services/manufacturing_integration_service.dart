import 'package:fashion_pos_enterprise/core/audit/audit_action.dart';
import 'package:fashion_pos_enterprise/core/audit/audit_service.dart';
import 'package:fashion_pos_enterprise/core/business/events/business_events.dart';
import 'package:fashion_pos_enterprise/core/business/events/domain_event_bus.dart';
import 'package:fashion_pos_enterprise/features/manufacturing/domain/repositories/manufacturing_repositories.dart';

/// Cross-module manufacturing integration: CRM readiness, audit on events, POS availability hooks.
class ManufacturingIntegrationService {
  ManufacturingIntegrationService({
    required DomainEventBus eventBus,
    required AuditService audit,
    ProductionRepository? productionRepository,
  })  : _eventBus = eventBus,
        _audit = audit,
        _production = productionRepository;

  final DomainEventBus _eventBus;
  final AuditService _audit;
  final ProductionRepository? _production;

  void register() {
    _eventBus.subscribe(DomainEventTypes.materialIssued, _onMaterialIssued);
    _eventBus.subscribe(DomainEventTypes.finishedGoodsReceived, _onFinishedGoodsReceived);
    _eventBus.subscribe(DomainEventTypes.productionCompleted, _onProductionCompleted);
    _eventBus.subscribe(DomainEventTypes.productionStarted, _onProductionStarted);
    _eventBus.subscribe(DomainEventTypes.workOrderCompleted, _onWorkOrderCompleted);
  }

  Future<void> _onMaterialIssued(DomainEvent event) async {
    if (event is! MaterialIssuedEvent || event.tenantId == null) return;
    await _audit.log(
      action: AuditAction.update,
      entityType: 'integration',
      tenantId: event.tenantId,
      entityId: event.issueId,
      metadata: {'integration': 'inventory_accounting', 'event': 'material.issued', 'productId': event.productId, 'qty': event.quantity},
    );
  }

  Future<void> _onFinishedGoodsReceived(DomainEvent event) async {
    if (event is! FinishedGoodsReceivedEvent || event.tenantId == null) return;
    await _audit.log(
      action: AuditAction.update,
      entityType: 'integration',
      tenantId: event.tenantId,
      entityId: event.receiptId,
      metadata: {'integration': 'inventory_pos_accounting', 'event': 'finished_goods.received', 'productId': event.productId, 'qty': event.quantity, 'posAvailable': true},
    );
  }

  Future<void> _onProductionStarted(DomainEvent event) async {
    if (event is! ProductionStartedEvent || event.tenantId == null) return;
    await _audit.log(
      action: AuditAction.update,
      entityType: 'integration',
      tenantId: event.tenantId,
      entityId: event.productionOrderId,
      metadata: {'integration': 'inventory_accounting', 'event': 'production.started'},
    );
  }

  Future<void> _onProductionCompleted(DomainEvent event) async {
    if (event is! ProductionCompletedEvent || event.tenantId == null) return;
    final order = await _production?.getById(event.productionOrderId, tenantId: event.tenantId);
    await _audit.log(
      action: AuditAction.update,
      entityType: 'integration',
      tenantId: event.tenantId,
      entityId: event.productionOrderId,
      metadata: {
        'integration': 'inventory_accounting_crm_pos',
        'event': 'production.completed',
        'completedQty': event.completedQty,
        'crmReadyForDelivery': order != null,
      },
    );
  }

  Future<void> _onWorkOrderCompleted(DomainEvent event) async {
    if (event is! WorkOrderCompletedEvent || event.tenantId == null) return;
    await _audit.log(
      action: AuditAction.update,
      entityType: 'integration',
      tenantId: event.tenantId,
      entityId: event.workOrderId,
      metadata: {'integration': 'hr_accounting', 'event': 'work_order.completed'},
    );
  }
}
