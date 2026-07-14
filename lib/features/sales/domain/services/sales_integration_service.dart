import 'package:fashion_pos_enterprise/core/business/events/business_events.dart';
import 'package:fashion_pos_enterprise/core/business/events/domain_event_bus.dart';
import 'package:fashion_pos_enterprise/core/audit/audit_action.dart';
import 'package:fashion_pos_enterprise/core/audit/audit_service.dart';

/// Cross-module sales OMS integration: timeline, accounting hooks, manufacturing, analytics audit.
class SalesIntegrationService {
  SalesIntegrationService({
    required DomainEventBus eventBus,
    required AuditService audit,
  })  : _eventBus = eventBus,
        _audit = audit;

  final DomainEventBus _eventBus;
  final AuditService _audit;

  void register() {
    _eventBus.subscribe(DomainEventTypes.quotationAccepted, _onQuotationAccepted);
    _eventBus.subscribe(DomainEventTypes.salesOrderConfirmed, _onSalesOrderConfirmed);
    _eventBus.subscribe(DomainEventTypes.shipmentDispatched, _onShipmentDispatched);
  }

  Future<void> _onQuotationAccepted(DomainEvent event) async {
    if (event is! QuotationAcceptedEvent || event.tenantId == null) return;
    await _audit.log(
      action: AuditAction.update,
      entityType: 'integration',
      tenantId: event.tenantId,
      entityId: event.quotationId,
      metadata: {'integration': 'crm_analytics', 'event': 'quotation.accepted', 'customerId': event.customerId},
    );
  }

  Future<void> _onSalesOrderConfirmed(DomainEvent event) async {
    if (event is! SalesOrderConfirmedEvent || event.tenantId == null) return;
    await _audit.log(
      action: AuditAction.update,
      entityType: 'integration',
      tenantId: event.tenantId,
      entityId: event.orderId,
      metadata: {'integration': 'accounting_crm', 'event': 'sales_order.confirmed', 'grandTotal': event.grandTotal},
    );
  }

  Future<void> _onShipmentDispatched(DomainEvent event) async {
    if (event is! ShipmentDispatchedEvent || event.tenantId == null) return;
    await _audit.log(
      action: AuditAction.update,
      entityType: 'integration',
      tenantId: event.tenantId,
      entityId: event.shipmentId,
      metadata: {'integration': 'inventory_accounting', 'event': 'shipment.dispatched', 'orderId': event.orderId},
    );
  }
}
