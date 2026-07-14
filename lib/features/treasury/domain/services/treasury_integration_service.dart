import 'package:fashion_pos_enterprise/core/business/events/business_events.dart';
import 'package:fashion_pos_enterprise/core/business/events/domain_event_bus.dart';
import 'package:fashion_pos_enterprise/core/audit/audit_action.dart';
import 'package:fashion_pos_enterprise/core/audit/audit_service.dart';

/// Cross-module treasury integration: Accounting, CRM, Purchasing, Sales OMS, HR, Analytics.
class TreasuryIntegrationService {
  TreasuryIntegrationService({
    required DomainEventBus eventBus,
    required AuditService audit,
  })  : _eventBus = eventBus,
        _audit = audit;

  final DomainEventBus _eventBus;
  final AuditService _audit;

  void register() {
    _eventBus.subscribe(DomainEventTypes.paymentReceived, _onPaymentReceived);
    _eventBus.subscribe(DomainEventTypes.paymentRecorded, _onPaymentRecorded);
    _eventBus.subscribe(DomainEventTypes.salesOrderConfirmed, _onSalesOrderConfirmed);
    _eventBus.subscribe(DomainEventTypes.purchaseReceived, _onPurchaseReceived);
    _eventBus.subscribe(DomainEventTypes.journalPosted, _onJournalPosted);
    _eventBus.subscribe(DomainEventTypes.payrollApproved, _onPayrollApproved);
    _eventBus.subscribe(DomainEventTypes.reconciliationCompleted, _onReconciliationCompleted);
  }

  Future<void> _onPaymentReceived(DomainEvent event) async {
    if (event is! PaymentReceivedEvent || event.tenantId == null) return;
    await _audit.log(
      action: AuditAction.update,
      entityType: 'integration',
      tenantId: event.tenantId,
      entityId: event.paymentId,
      metadata: {'integration': 'treasury_accounting', 'event': 'payment.received', 'amountMinor': event.amountMinor},
    );
  }

  Future<void> _onPaymentRecorded(DomainEvent event) async {
    if (event is! PaymentRecordedEvent || event.tenantId == null) return;
    await _audit.log(
      action: AuditAction.update,
      entityType: 'integration',
      tenantId: event.tenantId,
      entityId: event.paymentId,
      metadata: {'integration': 'treasury_accounting', 'event': 'payment.recorded'},
    );
  }

  Future<void> _onSalesOrderConfirmed(DomainEvent event) async {
    if (event is! SalesOrderConfirmedEvent || event.tenantId == null) return;
    await _audit.log(
      action: AuditAction.update,
      entityType: 'integration',
      tenantId: event.tenantId,
      entityId: event.orderId,
      metadata: {'integration': 'treasury_sales', 'event': 'sales_order.confirmed', 'grandTotal': event.grandTotal},
    );
  }

  Future<void> _onPurchaseReceived(DomainEvent event) async {
    if (event is! PurchaseReceivedEvent || event.tenantId == null) return;
    await _audit.log(
      action: AuditAction.update,
      entityType: 'integration',
      tenantId: event.tenantId,
      entityId: event.purchaseId,
      metadata: {'integration': 'treasury_purchasing', 'event': 'purchase.received'},
    );
  }

  Future<void> _onJournalPosted(DomainEvent event) async {
    if (event is! JournalPostedEvent || event.tenantId == null) return;
    await _audit.log(
      action: AuditAction.update,
      entityType: 'integration',
      tenantId: event.tenantId,
      entityId: event.journalEntryId,
      metadata: {'integration': 'treasury_accounting', 'event': 'journal.posted'},
    );
  }

  Future<void> _onPayrollApproved(DomainEvent event) async {
    if (event is! PayrollApprovedEvent || event.tenantId == null) return;
    await _audit.log(
      action: AuditAction.update,
      entityType: 'integration',
      tenantId: event.tenantId,
      entityId: event.payrollRunId,
      metadata: {'integration': 'treasury_hr', 'event': 'payroll.approved'},
    );
  }

  Future<void> _onReconciliationCompleted(DomainEvent event) async {
    if (event is! ReconciliationCompletedEvent || event.tenantId == null) return;
    await _audit.log(
      action: AuditAction.update,
      entityType: 'integration',
      tenantId: event.tenantId,
      entityId: event.sessionId,
      metadata: {'integration': 'treasury_analytics', 'event': 'reconciliation.completed'},
    );
  }
}
