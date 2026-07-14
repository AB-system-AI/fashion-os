import 'package:fashion_pos_enterprise/core/business/events/business_events.dart';
import 'package:fashion_pos_enterprise/core/business/events/domain_event_bus.dart';
import 'package:fashion_pos_enterprise/features/sales/domain/enums/sales_enums.dart';
import 'package:fashion_pos_enterprise/features/sales/domain/value_objects/sales_value_objects.dart';
import 'package:uuid/uuid.dart';

class QuotationTotals {
  const QuotationTotals({
    required this.subtotal,
    required this.discountTotal,
    required this.taxTotal,
    required this.grandTotal,
  });

  final double subtotal;
  final double discountTotal;
  final double taxTotal;
  final double grandTotal;
}

class OrderValidationResult {
  const OrderValidationResult({required this.isValid, this.errors = const []});

  final bool isValid;
  final List<String> errors;
}

class ReservationPlan {
  const ReservationPlan({
    required this.productId,
    required this.quantity,
    required this.warehouseId,
    this.variantId,
    this.shortfall = 0,
  });

  final String productId;
  final String? variantId;
  final String warehouseId;
  final double quantity;
  final double shortfall;
}

class ShipmentPlan {
  const ShipmentPlan({
    required this.lines,
    required this.totalWeight,
    required this.estimatedDeliveryDate,
  });

  final List<({String orderLineId, double quantity})> lines;
  final double totalWeight;
  final DateTime estimatedDeliveryDate;
}

class TransitionResult {
  const TransitionResult({required this.allowed, this.reason});

  final bool allowed;
  final String? reason;
}

/// Pure OMS rules: quotations, orders, shipments, reservations, returns.
class SalesOrderEngine {
  SalesOrderEngine({DomainEventBus? eventBus, Uuid? uuid})
      : _eventBus = eventBus,
        _uuid = uuid ?? const Uuid();

  final DomainEventBus? _eventBus;
  final Uuid _uuid;

  QuotationTotals calculateQuotation(List<QuotationLineInput> lines, {double headerDiscountPercent = 0}) {
    var subtotal = 0.0;
    var discountTotal = 0.0;
    var taxTotal = 0.0;
    for (final line in lines) {
      final lineSub = line.quantity * line.unitPrice;
      final lineDisc = line.discountAmount + (lineSub * line.discountPercent / 100);
      final taxable = lineSub - lineDisc;
      subtotal += lineSub;
      discountTotal += lineDisc;
      taxTotal += taxable * line.taxRate / 100;
    }
    if (headerDiscountPercent > 0) {
      final headerDisc = (subtotal - discountTotal) * headerDiscountPercent / 100;
      discountTotal += headerDisc;
      taxTotal = taxTotal * (1 - headerDiscountPercent / 100);
    }
    return QuotationTotals(
      subtotal: _round(subtotal),
      discountTotal: _round(discountTotal),
      taxTotal: _round(taxTotal),
      grandTotal: _round(subtotal - discountTotal + taxTotal),
    );
  }

  OrderValidationResult validateOrder({
    required List<OrderLineInput> lines,
    required double creditLimit,
    required double outstandingCredit,
    required double orderTotal,
    bool requireCustomer = true,
    String? customerId,
  }) {
    final errors = <String>[];
    if (requireCustomer && (customerId == null || customerId.isEmpty)) {
      errors.add('Customer is required');
    }
    if (lines.isEmpty) errors.add('At least one line is required');
    for (final line in lines) {
      if (line.quantity <= 0) errors.add('Line quantity must be positive');
      if (line.unitPrice < 0) errors.add('Unit price cannot be negative');
    }
    if (creditLimit > 0 && outstandingCredit + orderTotal > creditLimit) {
      errors.add('Credit limit exceeded');
    }
    return OrderValidationResult(isValid: errors.isEmpty, errors: errors);
  }

  bool requiresApproval({required double orderTotal, required double approvalThreshold}) =>
      approvalThreshold > 0 && orderTotal >= approvalThreshold;

  TransitionResult canTransitionQuotation(QuotationStatus from, QuotationStatus to) {
    const allowed = {
      QuotationStatus.draft: {QuotationStatus.sent, QuotationStatus.expired},
      QuotationStatus.sent: {QuotationStatus.accepted, QuotationStatus.rejected, QuotationStatus.expired},
      QuotationStatus.accepted: {},
      QuotationStatus.rejected: {},
      QuotationStatus.expired: {},
    };
    if (allowed[from]?.contains(to) ?? false) return const TransitionResult(allowed: true);
    return TransitionResult(allowed: false, reason: 'Cannot transition quotation from ${from.value} to ${to.value}');
  }

  TransitionResult canTransitionOrder(SalesOrderStatus from, SalesOrderStatus to) {
    const allowed = {
      SalesOrderStatus.draft: {SalesOrderStatus.confirmed, SalesOrderStatus.cancelled},
      SalesOrderStatus.confirmed: {SalesOrderStatus.approved, SalesOrderStatus.cancelled},
      SalesOrderStatus.approved: {SalesOrderStatus.reserved, SalesOrderStatus.cancelled},
      SalesOrderStatus.reserved: {SalesOrderStatus.picking, SalesOrderStatus.cancelled},
      SalesOrderStatus.picking: {SalesOrderStatus.packed, SalesOrderStatus.cancelled},
      SalesOrderStatus.packed: {SalesOrderStatus.shipped, SalesOrderStatus.cancelled},
      SalesOrderStatus.shipped: {SalesOrderStatus.delivered},
      SalesOrderStatus.delivered: {SalesOrderStatus.completed},
      SalesOrderStatus.completed: {},
      SalesOrderStatus.cancelled: {},
    };
    if (allowed[from]?.contains(to) ?? false) return const TransitionResult(allowed: true);
    return TransitionResult(allowed: false, reason: 'Cannot transition order from ${from.value} to ${to.value}');
  }

  TransitionResult canTransitionShipment(ShipmentStatus from, ShipmentStatus to) {
    const allowed = {
      ShipmentStatus.pending: {ShipmentStatus.picking, ShipmentStatus.failed},
      ShipmentStatus.picking: {ShipmentStatus.packed, ShipmentStatus.failed},
      ShipmentStatus.packed: {ShipmentStatus.dispatched, ShipmentStatus.failed},
      ShipmentStatus.dispatched: {ShipmentStatus.delivered, ShipmentStatus.failed, ShipmentStatus.returned},
      ShipmentStatus.delivered: {},
      ShipmentStatus.failed: {ShipmentStatus.pending},
      ShipmentStatus.returned: {},
    };
    if (allowed[from]?.contains(to) ?? false) return const TransitionResult(allowed: true);
    return TransitionResult(allowed: false, reason: 'Cannot transition shipment from ${from.value} to ${to.value}');
  }

  List<ReservationPlan> planReservations({
    required List<OrderLineInput> lines,
    required String defaultWarehouseId,
    required Map<String, double> availableByProduct,
  }) {
    return lines.map((line) {
      final key = line.variantId ?? line.productId;
      final available = availableByProduct[key] ?? 0;
      final shortfall = line.quantity > available ? line.quantity - available : 0;
      return ReservationPlan(
        productId: line.productId,
        variantId: line.variantId,
        warehouseId: line.warehouseId ?? defaultWarehouseId,
        quantity: line.quantity > available ? available : line.quantity,
        shortfall: shortfall,
      );
    }).toList();
  }

  ShipmentPlan planShipment({
    required List<({String orderLineId, double quantity, double weight})> lines,
    required DateTime shipDate,
    int transitDays = 3,
  }) {
    final totalWeight = lines.fold<double>(0, (s, l) => s + l.weight * l.quantity);
    return ShipmentPlan(
      lines: lines.map((l) => (orderLineId: l.orderLineId, quantity: l.quantity)).toList(),
      totalWeight: _round(totalWeight),
      estimatedDeliveryDate: shipDate.add(Duration(days: transitDays)),
    );
  }

  bool isInvoiceEligible(SalesOrderStatus status) =>
      status == SalesOrderStatus.delivered || status == SalesOrderStatus.completed || status == SalesOrderStatus.shipped;

  ReturnValidation validateReturn({
    required double originalQty,
    required double returnQty,
    required double alreadyReturned,
  }) {
    final maxReturn = originalQty - alreadyReturned;
    if (returnQty <= 0) return const ReturnValidation(isValid: false, message: 'Return quantity must be positive');
    if (returnQty > maxReturn) {
      return ReturnValidation(isValid: false, message: 'Return exceeds available quantity', maxReturnable: maxReturn);
    }
    return ReturnValidation(isValid: true, maxReturnable: maxReturn);
  }

  ExchangeValidation validateExchange({
    required double returnValue,
    required double newValue,
  }) {
    final diff = newValue - returnValue;
    return ExchangeValidation(
      isValid: true,
      priceDifference: _round(diff),
      requiresPayment: diff > 0,
      requiresRefund: diff < 0,
    );
  }

  double conversionRate({required int quotationsSent, required int ordersCreated}) {
    if (quotationsSent <= 0) return 0;
    return _round((ordersCreated / quotationsSent) * 100);
  }

  double fulfillmentRate({required double orderedQty, required double shippedQty}) {
    if (orderedQty <= 0) return 0;
    return _round((shippedQty / orderedQty) * 100);
  }

  void publishQuotationAccepted({
    required String tenantId,
    required String quotationId,
    required String customerId,
  }) {
    _eventBus?.publish(QuotationAcceptedEvent(
      eventId: _uuid.v4(),
      occurredAt: DateTime.now().toUtc(),
      tenantId: tenantId,
      quotationId: quotationId,
      customerId: customerId,
    ));
  }

  void publishSalesOrderConfirmed({
    required String tenantId,
    required String orderId,
    required String customerId,
    required double grandTotal,
  }) {
    _eventBus?.publish(SalesOrderConfirmedEvent(
      eventId: _uuid.v4(),
      occurredAt: DateTime.now().toUtc(),
      tenantId: tenantId,
      orderId: orderId,
      customerId: customerId,
      grandTotal: grandTotal,
    ));
  }

  void publishShipmentDispatched({
    required String tenantId,
    required String shipmentId,
    required String orderId,
  }) {
    _eventBus?.publish(ShipmentDispatchedEvent(
      eventId: _uuid.v4(),
      occurredAt: DateTime.now().toUtc(),
      tenantId: tenantId,
      shipmentId: shipmentId,
      orderId: orderId,
    ));
  }

  double _round(double v) => double.parse(v.toStringAsFixed(4));
}
