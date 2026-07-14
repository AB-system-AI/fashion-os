import 'package:equatable/equatable.dart';

class QuotationLineInput extends Equatable {
  const QuotationLineInput({
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    this.variantId,
    this.discountPercent = 0,
    this.discountAmount = 0,
    this.taxRate = 0,
  });

  final String productId;
  final String? variantId;
  final double quantity;
  final double unitPrice;
  final double discountPercent;
  final double discountAmount;
  final double taxRate;

  @override
  List<Object?> get props => [productId, quantity, unitPrice];
}

class OrderLineInput extends Equatable {
  const OrderLineInput({
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    this.variantId,
    this.warehouseId,
    this.weight = 1,
  });

  final String productId;
  final String? variantId;
  final String? warehouseId;
  final double quantity;
  final double unitPrice;
  final double weight;

  @override
  List<Object?> get props => [productId, quantity];
}

class ReturnValidation extends Equatable {
  const ReturnValidation({required this.isValid, this.message, this.maxReturnable = 0});

  final bool isValid;
  final String? message;
  final double maxReturnable;

  @override
  List<Object?> get props => [isValid, message, maxReturnable];
}

class ExchangeValidation extends Equatable {
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

  @override
  List<Object?> get props => [isValid, priceDifference];
}

class SalesReportSummary extends Equatable {
  const SalesReportSummary({
    required this.openOrders,
    required this.quotationsSent,
    required this.conversionRate,
    required this.fulfillmentRate,
    required this.openBackorders,
    required this.pendingShipments,
  });

  final int openOrders;
  final int quotationsSent;
  final double conversionRate;
  final double fulfillmentRate;
  final int openBackorders;
  final int pendingShipments;

  @override
  List<Object?> get props => [openOrders, conversionRate, fulfillmentRate];
}
