import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/business/domain/value_objects/money.dart';

/// Business receipt line for receipt engine output.
class ReceiptLine extends Equatable {
  const ReceiptLine({
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
    this.sku,
    this.discountAmount,
  });

  final String description;
  final double quantity;
  final Money unitPrice;
  final Money lineTotal;
  final String? sku;
  final Money? discountAmount;

  @override
  List<Object?> get props => [description, quantity, lineTotal];
}

/// Receipt template configuration.
class ReceiptTemplate extends Equatable {
  const ReceiptTemplate({
    required this.id,
    required this.name,
    this.headerText,
    this.footerText,
    this.logoUrl,
    this.showQrCode = true,
    this.showBarcode = false,
    this.customFields = const {},
    this.paperWidthMm = 80,
  });

  final String id;
  final String name;
  final String? headerText;
  final String? footerText;
  final String? logoUrl;
  final bool showQrCode;
  final bool showBarcode;
  final Map<String, String> customFields;
  final int paperWidthMm;

  @override
  List<Object?> get props => [id, name];
}

/// Generated business receipt.
class BusinessReceipt extends Equatable {
  const BusinessReceipt({
    required this.receiptNumber,
    required this.storeName,
    required this.lines,
    required this.subtotal,
    required this.discountTotal,
    required this.taxTotal,
    required this.grandTotal,
    required this.currencyCode,
    required this.issuedAt,
    this.template,
    this.taxLines = const [],
    this.qrCodeData,
    this.barcodeData,
    this.footerText,
    this.customFields = const {},
    this.digitalReceiptUrl,
  });

  final String receiptNumber;
  final String storeName;
  final List<ReceiptLine> lines;
  final Money subtotal;
  final Money discountTotal;
  final Money taxTotal;
  final Money grandTotal;
  final String currencyCode;
  final DateTime issuedAt;
  final ReceiptTemplate? template;
  final List<ReceiptTaxLine> taxLines;
  final String? qrCodeData;
  final String? barcodeData;
  final String? footerText;
  final Map<String, String> customFields;
  final String? digitalReceiptUrl;

  @override
  List<Object?> get props => [receiptNumber, grandTotal, issuedAt];
}

class ReceiptTaxLine extends Equatable {
  const ReceiptTaxLine({required this.name, required this.amount});

  final String name;
  final Money amount;

  @override
  List<Object?> get props => [name, amount];
}

/// Receipt generation request.
class ReceiptRequest extends Equatable {
  const ReceiptRequest({
    required this.receiptNumber,
    required this.storeName,
    required this.lines,
    required this.subtotal,
    required this.discountTotal,
    required this.taxTotal,
    required this.grandTotal,
    required this.currencyCode,
    this.template,
    this.taxLines = const [],
    this.saleId,
    this.customerName,
  });

  final String receiptNumber;
  final String storeName;
  final List<ReceiptLine> lines;
  final Money subtotal;
  final Money discountTotal;
  final Money taxTotal;
  final Money grandTotal;
  final String currencyCode;
  final ReceiptTemplate? template;
  final List<ReceiptTaxLine> taxLines;
  final String? saleId;
  final String? customerName;

  @override
  List<Object?> get props => [receiptNumber, grandTotal];
}
