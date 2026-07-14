import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/business/domain/enums/business_enums.dart';
import 'package:fashion_pos_enterprise/core/business/events/domain_event_bus.dart';

// ---------------------------------------------------------------------------
// Sale events
// ---------------------------------------------------------------------------

class SaleCreatedEvent extends DomainEvent {
  const SaleCreatedEvent({
    required super.eventId,
    required super.occurredAt,
    required this.saleId,
    required this.employeeId,
    super.tenantId,
    super.storeId,
    super.correlationId,
  });

  final String saleId;
  final String employeeId;

  @override
  String get eventType => 'sale.created';

  @override
  List<Object?> get props => [...super.props, saleId, employeeId];
}

class SaleCompletedEvent extends DomainEvent {
  const SaleCompletedEvent({
    required super.eventId,
    required super.occurredAt,
    required this.saleId,
    required this.grandTotalMinor,
    required this.currencyCode,
    super.tenantId,
    super.storeId,
    super.correlationId,
  });

  final String saleId;
  final int grandTotalMinor;
  final String currencyCode;

  @override
  String get eventType => 'sale.completed';

  @override
  List<Object?> get props => [...super.props, saleId, grandTotalMinor, currencyCode];
}

class SaleCancelledEvent extends DomainEvent {
  const SaleCancelledEvent({
    required super.eventId,
    required super.occurredAt,
    required this.saleId,
    this.reason,
    super.tenantId,
    super.storeId,
    super.correlationId,
  });

  final String saleId;
  final String? reason;

  @override
  String get eventType => 'sale.cancelled';

  @override
  List<Object?> get props => [...super.props, saleId, reason];
}

class PaymentReceivedEvent extends DomainEvent {
  const PaymentReceivedEvent({
    required super.eventId,
    required super.occurredAt,
    required this.saleId,
    required this.paymentId,
    required this.amountMinor,
    super.tenantId,
    super.storeId,
    super.correlationId,
  });

  final String saleId;
  final String paymentId;
  final int amountMinor;

  @override
  String get eventType => 'payment.received';

  @override
  List<Object?> get props => [...super.props, saleId, paymentId, amountMinor];
}

class CashSessionClosedEvent extends DomainEvent {
  const CashSessionClosedEvent({
    required super.eventId,
    required super.occurredAt,
    required this.sessionId,
    required this.actualCashMinor,
    required this.differenceMinor,
    super.tenantId,
    super.storeId,
    super.correlationId,
  });

  final String sessionId;
  final int actualCashMinor;
  final int differenceMinor;

  @override
  String get eventType => 'cash_session.closed';

  @override
  List<Object?> get props => [...super.props, sessionId, actualCashMinor, differenceMinor];
}

// ---------------------------------------------------------------------------
// Product & inventory events
// ---------------------------------------------------------------------------

class ProductUpdatedEvent extends DomainEvent {
  const ProductUpdatedEvent({
    required super.eventId,
    required super.occurredAt,
    required this.productId,
    super.tenantId,
    super.correlationId,
  });

  final String productId;

  @override
  String get eventType => 'product.updated';

  @override
  List<Object?> get props => [...super.props, productId];
}

class StockChangedEvent extends DomainEvent {
  const StockChangedEvent({
    required super.eventId,
    required super.occurredAt,
    required this.variantId,
    required this.warehouseId,
    required this.quantityBefore,
    required this.quantityAfter,
    required this.movementType,
    super.tenantId,
    super.storeId,
    super.correlationId,
  });

  final String variantId;
  final String warehouseId;
  final double quantityBefore;
  final double quantityAfter;
  final String movementType;

  @override
  String get eventType => 'stock.changed';

  @override
  List<Object?> get props => [
        ...super.props,
        variantId,
        warehouseId,
        quantityBefore,
        quantityAfter,
        movementType,
      ];
}

// ---------------------------------------------------------------------------
// Customer & purchase events
// ---------------------------------------------------------------------------

class CustomerCreatedEvent extends DomainEvent {
  const CustomerCreatedEvent({
    required super.eventId,
    required super.occurredAt,
    required this.customerId,
    super.tenantId,
    super.correlationId,
  });

  final String customerId;

  @override
  String get eventType => 'customer.created';

  @override
  List<Object?> get props => [...super.props, customerId];
}

class PurchaseReceivedEvent extends DomainEvent {
  const PurchaseReceivedEvent({
    required super.eventId,
    required super.occurredAt,
    required this.purchaseId,
    required this.supplierId,
    super.tenantId,
    super.storeId,
    super.correlationId,
  });

  final String purchaseId;
  final String supplierId;

  @override
  String get eventType => 'purchase.received';

  @override
  List<Object?> get props => [...super.props, purchaseId, supplierId];
}

// ---------------------------------------------------------------------------
// Loyalty & promotion events
// ---------------------------------------------------------------------------

class LoyaltyTierChangedEvent extends DomainEvent {
  const LoyaltyTierChangedEvent({
    required super.eventId,
    required super.occurredAt,
    required this.customerId,
    required this.previousTier,
    required this.newTier,
    super.tenantId,
    super.correlationId,
  });

  final String customerId;
  final LoyaltyTier previousTier;
  final LoyaltyTier newTier;

  @override
  String get eventType => 'loyalty.tier_changed';

  @override
  List<Object?> get props => [...super.props, customerId, previousTier, newTier];
}

class PromotionAppliedEvent extends DomainEvent {
  const PromotionAppliedEvent({
    required super.eventId,
    required super.occurredAt,
    required this.promotionId,
    required this.discountMinor,
    super.tenantId,
    super.storeId,
    super.correlationId,
  });

  final String promotionId;
  final int discountMinor;

  @override
  String get eventType => 'promotion.applied';

  @override
  List<Object?> get props => [...super.props, promotionId, discountMinor];
}

// ---------------------------------------------------------------------------
// Accounting events
// ---------------------------------------------------------------------------

class JournalPostedEvent extends DomainEvent {
  const JournalPostedEvent({
    required super.eventId,
    required super.occurredAt,
    required this.journalEntryId,
    super.tenantId,
    super.storeId,
    super.correlationId,
  });

  final String journalEntryId;

  @override
  String get eventType => 'journal.posted';

  @override
  List<Object?> get props => [...super.props, journalEntryId];
}

class FiscalClosedEvent extends DomainEvent {
  const FiscalClosedEvent({
    required super.eventId,
    required super.occurredAt,
    required this.fiscalPeriodId,
    super.tenantId,
    super.correlationId,
  });

  final String fiscalPeriodId;

  @override
  String get eventType => 'fiscal.closed';

  @override
  List<Object?> get props => [...super.props, fiscalPeriodId];
}

class PaymentRecordedEvent extends DomainEvent {
  const PaymentRecordedEvent({
    required super.eventId,
    required super.occurredAt,
    required this.paymentId,
    required this.amountMinor,
    super.tenantId,
    super.storeId,
    super.correlationId,
  });

  final String paymentId;
  final int amountMinor;

  @override
  String get eventType => 'payment.recorded';

  @override
  List<Object?> get props => [...super.props, paymentId, amountMinor];
}

class ReconciliationCompletedEvent extends DomainEvent {
  const ReconciliationCompletedEvent({
    required super.eventId,
    required super.occurredAt,
    required this.sessionId,
    super.tenantId,
    super.correlationId,
  });

  final String sessionId;

  @override
  String get eventType => 'reconciliation.completed';

  @override
  List<Object?> get props => [...super.props, sessionId];
}

// ---------------------------------------------------------------------------
// HR events
// ---------------------------------------------------------------------------

class AttendanceRecordedEvent extends DomainEvent {
  const AttendanceRecordedEvent({
    required super.eventId,
    required super.occurredAt,
    required this.attendanceId,
    required this.employeeId,
    super.tenantId,
    super.storeId,
    super.correlationId,
  });

  final String attendanceId;
  final String employeeId;

  @override
  String get eventType => 'attendance.recorded';

  @override
  List<Object?> get props => [...super.props, attendanceId, employeeId];
}

class PayrollCalculatedEvent extends DomainEvent {
  const PayrollCalculatedEvent({
    required super.eventId,
    required super.occurredAt,
    required this.payrollRunId,
    required this.totalNetMinor,
    super.tenantId,
    super.correlationId,
  });

  final String payrollRunId;
  final int totalNetMinor;

  @override
  String get eventType => 'payroll.calculated';

  @override
  List<Object?> get props => [...super.props, payrollRunId, totalNetMinor];
}

class PayrollApprovedEvent extends DomainEvent {
  const PayrollApprovedEvent({
    required super.eventId,
    required super.occurredAt,
    required this.payrollRunId,
    required this.totalGrossMinor,
    required this.totalTaxMinor,
    required this.totalNetMinor,
    super.tenantId,
    super.correlationId,
  });

  final String payrollRunId;
  final int totalGrossMinor;
  final int totalTaxMinor;
  final int totalNetMinor;

  @override
  String get eventType => 'payroll.approved';

  @override
  List<Object?> get props => [...super.props, payrollRunId, totalGrossMinor, totalTaxMinor, totalNetMinor];
}

class LeaveApprovedEvent extends DomainEvent {
  const LeaveApprovedEvent({
    required super.eventId,
    required super.occurredAt,
    required this.leaveRequestId,
    required this.employeeId,
    required this.days,
    super.tenantId,
    super.correlationId,
  });

  final String leaveRequestId;
  final String employeeId;
  final double days;

  @override
  String get eventType => 'leave.approved';

  @override
  List<Object?> get props => [...super.props, leaveRequestId, employeeId, days];
}

// ---------------------------------------------------------------------------
// Manufacturing events
// ---------------------------------------------------------------------------

class ProductionStartedEvent extends DomainEvent {
  const ProductionStartedEvent({
    required super.eventId,
    required super.occurredAt,
    required this.productionOrderId,
    super.tenantId,
    super.correlationId,
  });

  final String productionOrderId;

  @override
  String get eventType => 'production.started';

  @override
  List<Object?> get props => [...super.props, productionOrderId];
}

class ProductionCompletedEvent extends DomainEvent {
  const ProductionCompletedEvent({
    required super.eventId,
    required super.occurredAt,
    required this.productionOrderId,
    required this.completedQty,
    super.tenantId,
    super.correlationId,
  });

  final String productionOrderId;
  final double completedQty;

  @override
  String get eventType => 'production.completed';

  @override
  List<Object?> get props => [...super.props, productionOrderId, completedQty];
}

class WorkOrderCompletedEvent extends DomainEvent {
  const WorkOrderCompletedEvent({
    required super.eventId,
    required super.occurredAt,
    required this.workOrderId,
    super.tenantId,
    super.correlationId,
  });

  final String workOrderId;

  @override
  String get eventType => 'work_order.completed';

  @override
  List<Object?> get props => [...super.props, workOrderId];
}

class MaterialIssuedEvent extends DomainEvent {
  const MaterialIssuedEvent({
    required super.eventId,
    required super.occurredAt,
    required this.issueId,
    required this.productId,
    required this.quantity,
    super.tenantId,
    super.correlationId,
  });

  final String issueId;
  final String productId;
  final double quantity;

  @override
  String get eventType => 'material.issued';

  @override
  List<Object?> get props => [...super.props, issueId, productId, quantity];
}

class MaterialReturnedEvent extends DomainEvent {
  const MaterialReturnedEvent({
    required super.eventId,
    required super.occurredAt,
    required this.returnId,
    required this.productId,
    required this.quantity,
    super.tenantId,
    super.correlationId,
  });

  final String returnId;
  final String productId;
  final double quantity;

  @override
  String get eventType => 'material.returned';

  @override
  List<Object?> get props => [...super.props, returnId, productId, quantity];
}

class QualityPassedEvent extends DomainEvent {
  const QualityPassedEvent({
    required super.eventId,
    required super.occurredAt,
    required this.inspectionId,
    super.tenantId,
    super.correlationId,
  });

  final String inspectionId;

  @override
  String get eventType => 'quality.passed';

  @override
  List<Object?> get props => [...super.props, inspectionId];
}

class QualityFailedEvent extends DomainEvent {
  const QualityFailedEvent({
    required super.eventId,
    required super.occurredAt,
    required this.inspectionId,
    super.tenantId,
    super.correlationId,
  });

  final String inspectionId;

  @override
  String get eventType => 'quality.failed';

  @override
  List<Object?> get props => [...super.props, inspectionId];
}

class FinishedGoodsReceivedEvent extends DomainEvent {
  const FinishedGoodsReceivedEvent({
    required super.eventId,
    required super.occurredAt,
    required this.receiptId,
    required this.productId,
    required this.quantity,
    super.tenantId,
    super.correlationId,
  });

  final String receiptId;
  final String productId;
  final double quantity;

  @override
  String get eventType => 'finished_goods.received';

  @override
  List<Object?> get props => [...super.props, receiptId, productId, quantity];
}

class QuotationAcceptedEvent extends DomainEvent {
  const QuotationAcceptedEvent({
    required super.eventId,
    required super.occurredAt,
    required this.quotationId,
    required this.customerId,
    super.tenantId,
    super.correlationId,
  });

  final String quotationId;
  final String customerId;

  @override
  String get eventType => 'quotation.accepted';

  @override
  List<Object?> get props => [...super.props, quotationId, customerId];
}

class SalesOrderConfirmedEvent extends DomainEvent {
  const SalesOrderConfirmedEvent({
    required super.eventId,
    required super.occurredAt,
    required this.orderId,
    required this.customerId,
    required this.grandTotal,
    super.tenantId,
    super.correlationId,
  });

  final String orderId;
  final String customerId;
  final double grandTotal;

  @override
  String get eventType => 'sales_order.confirmed';

  @override
  List<Object?> get props => [...super.props, orderId, customerId, grandTotal];
}

class ShipmentDispatchedEvent extends DomainEvent {
  const ShipmentDispatchedEvent({
    required super.eventId,
    required super.occurredAt,
    required this.shipmentId,
    required this.orderId,
    super.tenantId,
    super.correlationId,
  });

  final String shipmentId;
  final String orderId;

  @override
  String get eventType => 'shipment.dispatched';

  @override
  List<Object?> get props => [...super.props, shipmentId, orderId];
}

class AssetDisposedEvent extends DomainEvent {
  const AssetDisposedEvent({
    required super.eventId,
    required super.occurredAt,
    required this.assetId,
    required this.gainLoss,
    required this.proceeds,
    super.tenantId,
    super.correlationId,
  });

  final String assetId;
  final double gainLoss;
  final double proceeds;

  @override
  String get eventType => 'asset.disposed';

  @override
  List<Object?> get props => [...super.props, assetId, gainLoss, proceeds];
}

class AssetTransferredEvent extends DomainEvent {
  const AssetTransferredEvent({
    required super.eventId,
    required super.occurredAt,
    required this.assetId,
    required this.fromLocationId,
    required this.toLocationId,
    super.tenantId,
    super.correlationId,
  });

  final String assetId;
  final String fromLocationId;
  final String toLocationId;

  @override
  String get eventType => 'asset.transferred';

  @override
  List<Object?> get props => [...super.props, assetId, fromLocationId, toLocationId];
}

/// Well-known domain event type constants.
abstract final class DomainEventTypes {
  static const saleCreated = 'sale.created';
  static const saleCompleted = 'sale.completed';
  static const saleCancelled = 'sale.cancelled';
  static const paymentReceived = 'payment.received';
  static const cashSessionClosed = 'cash_session.closed';
  static const productUpdated = 'product.updated';
  static const stockChanged = 'stock.changed';
  static const customerCreated = 'customer.created';
  static const purchaseReceived = 'purchase.received';
  static const loyaltyTierChanged = 'loyalty.tier_changed';
  static const promotionApplied = 'promotion.applied';
  static const journalPosted = 'journal.posted';
  static const fiscalClosed = 'fiscal.closed';
  static const paymentRecorded = 'payment.recorded';
  static const reconciliationCompleted = 'reconciliation.completed';
  static const attendanceRecorded = 'attendance.recorded';
  static const payrollCalculated = 'payroll.calculated';
  static const payrollApproved = 'payroll.approved';
  static const leaveApproved = 'leave.approved';
  static const productionStarted = 'production.started';
  static const productionCompleted = 'production.completed';
  static const workOrderCompleted = 'work_order.completed';
  static const materialIssued = 'material.issued';
  static const materialReturned = 'material.returned';
  static const qualityPassed = 'quality.passed';
  static const qualityFailed = 'quality.failed';
  static const finishedGoodsReceived = 'finished_goods.received';
  static const quotationAccepted = 'quotation.accepted';
  static const salesOrderConfirmed = 'sales_order.confirmed';
  static const shipmentDispatched = 'shipment.dispatched';
  static const assetDisposed = 'asset.disposed';
  static const assetTransferred = 'asset.transferred';
}
