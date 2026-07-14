import 'package:equatable/equatable.dart';

class SaleLine extends Equatable {
  const SaleLine({
    required this.id,
    required this.variantId,
    required this.productId,
    required this.productName,
    required this.sku,
    required this.quantity,
    required this.unitPrice,
    this.variantName,
    this.barcode,
    this.unitCost = 0,
    this.discountAmount = 0,
    this.taxAmount = 0,
    this.notes,
    this.weight,
    this.priceOverridden = false,
    this.approvedBy,
  });

  final String id;
  final String variantId;
  final String productId;
  final String productName;
  final String? variantName;
  final String sku;
  final String? barcode;
  final double quantity;
  final double unitPrice;
  final double unitCost;
  final double discountAmount;
  final double taxAmount;
  final String? notes;
  final double? weight;
  final bool priceOverridden;
  final String? approvedBy;

  double get lineSubtotal => quantity * unitPrice;
  double get lineTotal => lineSubtotal - discountAmount + taxAmount;

  Map<String, dynamic> toJson() => {
        'id': id,
        'variant_id': variantId,
        'product_id': productId,
        'product_name': productName,
        'variant_name': variantName,
        'sku': sku,
        'barcode': barcode,
        'quantity': quantity,
        'unit_price': unitPrice,
        'unit_cost': unitCost,
        'discount_amount': discountAmount,
        'tax_amount': taxAmount,
        'line_total': lineTotal,
        'notes': notes,
        'weight': weight,
        'price_overridden': priceOverridden,
        'approved_by': approvedBy,
      };

  factory SaleLine.fromJson(Map<String, dynamic> json) {
    return SaleLine(
      id: json['id'] as String? ?? '',
      variantId: json['variant_id'] as String? ?? '',
      productId: json['product_id'] as String? ?? '',
      productName: json['product_name'] as String? ?? '',
      variantName: json['variant_name'] as String?,
      sku: json['sku'] as String? ?? '',
      barcode: json['barcode'] as String?,
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0,
      unitPrice: (json['unit_price'] as num?)?.toDouble() ?? 0,
      unitCost: (json['unit_cost'] as num?)?.toDouble() ?? 0,
      discountAmount: (json['discount_amount'] as num?)?.toDouble() ?? 0,
      taxAmount: (json['tax_amount'] as num?)?.toDouble() ?? 0,
      notes: json['notes'] as String?,
      weight: (json['weight'] as num?)?.toDouble(),
      priceOverridden: json['price_overridden'] as bool? ?? false,
      approvedBy: json['approved_by'] as String?,
    );
  }

  SaleLine copyWith({
    double? quantity,
    double? unitPrice,
    double? discountAmount,
    double? taxAmount,
    String? notes,
    bool? priceOverridden,
    String? approvedBy,
  }) {
    return SaleLine(
      id: id,
      variantId: variantId,
      productId: productId,
      productName: productName,
      variantName: variantName,
      sku: sku,
      barcode: barcode,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      unitCost: unitCost,
      discountAmount: discountAmount ?? this.discountAmount,
      taxAmount: taxAmount ?? this.taxAmount,
      notes: notes ?? this.notes,
      weight: weight,
      priceOverridden: priceOverridden ?? this.priceOverridden,
      approvedBy: approvedBy ?? this.approvedBy,
    );
  }

  @override
  List<Object?> get props => [id, variantId, quantity, unitPrice];
}
