import 'package:fashion_pos_enterprise/core/business/events/business_events.dart';
import 'package:fashion_pos_enterprise/core/business/events/domain_event_bus.dart';
import 'package:fashion_pos_enterprise/core/errors/failure.dart';
import 'package:fashion_pos_enterprise/core/result/result.dart';
import 'package:fashion_pos_enterprise/features/pos/domain/entities/coupon.dart';
import 'package:fashion_pos_enterprise/features/pos/domain/entities/payment.dart';
import 'package:fashion_pos_enterprise/features/pos/domain/entities/sale.dart';
import 'package:fashion_pos_enterprise/features/pos/domain/entities/sale_line.dart';
import 'package:fashion_pos_enterprise/features/pos/domain/enums/pos_enums.dart';
import 'package:uuid/uuid.dart';

class SaleTotals {
  const SaleTotals({
    required this.subtotal,
    required this.discountTotal,
    required this.taxTotal,
    required this.grandTotal,
    required this.lineTotals,
  });

  final double subtotal;
  final double discountTotal;
  final double taxTotal;
  final double grandTotal;
  final List<double> lineTotals;
}

class SplitPaymentResult {
  const SplitPaymentResult({
    required this.payments,
    required this.totalPaid,
    required this.changeDue,
    required this.amountDue,
    required this.isBalanced,
  });

  final List<Payment> payments;
  final double totalPaid;
  final double changeDue;
  final double amountDue;
  final bool isBalanced;
}

class RefundValidation {
  const RefundValidation({required this.isValid, this.message, this.maxRefundable = 0});

  final bool isValid;
  final String? message;
  final double maxRefundable;
}

class ExchangeValidation {
  const ExchangeValidation({
    required this.isValid,
    this.message,
    this.priceDifference = 0,
    this.requiresPayment = false,
    this.requiresRefund = false,
  });

  final bool isValid;
  final String? message;
  final double priceDifference;
  final bool requiresPayment;
  final bool requiresRefund;
}

class LayawayCalculation {
  const LayawayCalculation({
    required this.totalAmount,
    required this.depositAmount,
    required this.remainingBalance,
    required this.installmentAmount,
    required this.installmentCount,
  });

  final double totalAmount;
  final double depositAmount;
  final double remainingBalance;
  final double installmentAmount;
  final int installmentCount;
}

/// Pure sales calculation, validation, and orchestration rules.
class SalesEngine {
  SalesEngine({
    DomainEventBus? eventBus,
    Uuid? uuid,
  })  : _eventBus = eventBus,
        _uuid = uuid ?? const Uuid();

  final DomainEventBus? _eventBus;
  final Uuid _uuid;

  SaleTotals calculateSale(List<SaleLine> lines) {
    var subtotal = 0.0;
    var discountTotal = 0.0;
    var taxTotal = 0.0;
    final lineTotals = <double>[];

    for (final line in lines) {
      subtotal += line.lineSubtotal;
      discountTotal += line.discountAmount;
      taxTotal += line.taxAmount;
      lineTotals.add(line.lineTotal);
    }

    final grandTotal = subtotal - discountTotal + taxTotal;
    return SaleTotals(
      subtotal: subtotal,
      discountTotal: discountTotal,
      taxTotal: taxTotal,
      grandTotal: _roundCurrency(grandTotal),
      lineTotals: lineTotals,
    );
  }

  Result<void> validateLines(List<SaleLine> lines) {
    if (lines.isEmpty) {
      return const Error(ValidationFailure(message: 'Sale requires at least one line', code: 'no_lines'));
    }
    for (final line in lines) {
      if (line.quantity <= 0) {
        return const Error(ValidationFailure(message: 'Line quantity must be positive', code: 'invalid_quantity'));
      }
      if (line.unitPrice < 0) {
        return const Error(ValidationFailure(message: 'Unit price cannot be negative', code: 'invalid_price'));
      }
    }
    return const Success(null);
  }

  Result<Coupon> validateCoupon({
    required Coupon coupon,
    required double orderSubtotal,
    String? customerId,
    DateTime? at,
  }) {
    final now = at ?? DateTime.now().toUtc();
    if (!coupon.active) {
      return const Error(ValidationFailure(message: 'Coupon is inactive', code: 'coupon_inactive'));
    }
    if (coupon.startsAt != null && now.isBefore(coupon.startsAt!)) {
      return const Error(ValidationFailure(message: 'Coupon is not yet valid', code: 'coupon_not_started'));
    }
    if (coupon.endsAt != null && now.isAfter(coupon.endsAt!)) {
      return const Error(ValidationFailure(message: 'Coupon has expired', code: 'coupon_expired'));
    }
    if (coupon.maxUses != null && coupon.usedCount >= coupon.maxUses!) {
      return const Error(ValidationFailure(message: 'Coupon usage limit reached', code: 'coupon_exhausted'));
    }
    if (coupon.customerId != null && coupon.customerId != customerId) {
      return const Error(ValidationFailure(message: 'Coupon not valid for this customer', code: 'coupon_customer'));
    }
    if (coupon.minOrderAmount != null && orderSubtotal < coupon.minOrderAmount!) {
      return Error(ValidationFailure(
        message: 'Minimum order amount not met',
        code: 'coupon_min_order',
      ));
    }
    return Success(coupon);
  }

  double calculateCouponDiscount(Coupon coupon, double subtotal) {
    return switch (coupon.couponType) {
      CouponType.percentage => _roundCurrency(subtotal * coupon.value / 100),
      CouponType.fixed => _roundCurrency(coupon.value.clamp(0, subtotal)),
      CouponType.bogo => 0,
      CouponType.freeShipping => 0,
    };
  }

  SplitPaymentResult calculateSplitPayments({
    required List<Payment> payments,
    required double grandTotal,
    PaymentMethodKind? changeMethod,
  }) {
    final totalPaid = payments.fold(0.0, (s, p) => s + p.amount);
    final amountDue = (grandTotal - totalPaid).clamp(0, double.infinity);
    final changeDue = (totalPaid - grandTotal).clamp(0, double.infinity);
    final isBalanced = (totalPaid - grandTotal).abs() < 0.01 || (totalPaid >= grandTotal && changeDue >= 0);
    return SplitPaymentResult(
      payments: payments,
      totalPaid: _roundCurrency(totalPaid),
      changeDue: _roundCurrency(changeDue),
      amountDue: _roundCurrency(amountDue),
      isBalanced: isBalanced,
    );
  }

  double calculateCashChange(double cashTendered, double grandTotal) {
    return _roundCurrency((cashTendered - grandTotal).clamp(0, double.infinity));
  }

  double roundCash(double amount, {double increment = 0.05}) {
    if (increment <= 0) return _roundCurrency(amount);
    return (amount / increment).round() * increment;
  }

  RefundValidation validateRefund({
    required Sale originalSale,
    required double refundAmount,
    required bool isPartial,
  }) {
    if (!originalSale.isCompleted) {
      return const RefundValidation(isValid: false, message: 'Original sale is not completed');
    }
    if (refundAmount <= 0) {
      return const RefundValidation(isValid: false, message: 'Refund amount must be positive');
    }
    if (refundAmount > originalSale.grandTotal) {
      return RefundValidation(
        isValid: false,
        message: 'Refund exceeds sale total',
        maxRefundable: originalSale.grandTotal,
      );
    }
    if (!isPartial && (refundAmount - originalSale.grandTotal).abs() > 0.01) {
      return RefundValidation(
        isValid: false,
        message: 'Full refund must match sale total',
        maxRefundable: originalSale.grandTotal,
      );
    }
    return RefundValidation(isValid: true, maxRefundable: originalSale.grandTotal);
  }

  ExchangeValidation validateExchange({
    required double returnValue,
    required double newSaleValue,
  }) {
    if (returnValue <= 0 || newSaleValue < 0) {
      return const ExchangeValidation(isValid: false, message: 'Invalid exchange amounts');
    }
    final diff = newSaleValue - returnValue;
    return ExchangeValidation(
      isValid: true,
      priceDifference: _roundCurrency(diff),
      requiresPayment: diff > 0.01,
      requiresRefund: diff < -0.01,
    );
  }

  LayawayCalculation calculateLayaway({
    required double totalAmount,
    required double depositPercent,
    int installmentCount = 3,
  }) {
    final deposit = _roundCurrency(totalAmount * depositPercent / 100);
    final remaining = (totalAmount - deposit).clamp(0, double.infinity);
    final installment = installmentCount > 0 ? _roundCurrency(remaining / installmentCount) : remaining;
    return LayawayCalculation(
      totalAmount: totalAmount,
      depositAmount: deposit,
      remainingBalance: remaining,
      installmentAmount: installment,
      installmentCount: installmentCount,
    );
  }

  Sale applyTotals(Sale sale) {
    final totals = calculateSale(sale.lines);
    return sale.copyWith(
      subtotal: totals.subtotal,
      discountTotal: totals.discountTotal,
      taxTotal: totals.taxTotal,
      grandTotal: totals.grandTotal,
      amountDue: (totals.grandTotal - sale.amountPaid).clamp(0, double.infinity),
    );
  }

  void publishSaleCompleted({
    required String saleId,
    required double grandTotal,
    String currencyCode = 'USD',
    String? tenantId,
    String? storeId,
  }) {
    _eventBus?.publish(
      SaleCompletedEvent(
        eventId: _uuid.v4(),
        occurredAt: DateTime.now().toUtc(),
        saleId: saleId,
        grandTotalMinor: (grandTotal * 100).round(),
        currencyCode: currencyCode,
        tenantId: tenantId,
        storeId: storeId,
      ),
    );
  }

  void publishSaleCancelled({
    required String saleId,
    String? reason,
    String? tenantId,
    String? storeId,
  }) {
    _eventBus?.publish(
      SaleCancelledEvent(
        eventId: _uuid.v4(),
        occurredAt: DateTime.now().toUtc(),
        saleId: saleId,
        reason: reason,
        tenantId: tenantId,
        storeId: storeId,
      ),
    );
  }

  void publishPaymentReceived({
    required String saleId,
    required String paymentId,
    required double amount,
    String? tenantId,
    String? storeId,
  }) {
    _eventBus?.publish(
      PaymentReceivedEvent(
        eventId: _uuid.v4(),
        occurredAt: DateTime.now().toUtc(),
        saleId: saleId,
        paymentId: paymentId,
        amountMinor: (amount * 100).round(),
        tenantId: tenantId,
        storeId: storeId,
      ),
    );
  }

  void publishCashSessionClosed({
    required String sessionId,
    required double actualCash,
    required double difference,
    String? tenantId,
    String? storeId,
  }) {
    _eventBus?.publish(
      CashSessionClosedEvent(
        eventId: _uuid.v4(),
        occurredAt: DateTime.now().toUtc(),
        sessionId: sessionId,
        actualCashMinor: (actualCash * 100).round(),
        differenceMinor: (difference * 100).round(),
        tenantId: tenantId,
        storeId: storeId,
      ),
    );
  }

  double _roundCurrency(double value) => double.parse(value.toStringAsFixed(2));
}
