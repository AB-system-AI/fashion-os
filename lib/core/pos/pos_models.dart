import 'dart:convert';

import 'package:equatable/equatable.dart';

/// Serializable POS cart state for crash recovery.
class PosCartSnapshot extends Equatable {
  const PosCartSnapshot({
    required this.id,
    required this.tenantId,
    required this.storeId,
    required this.employeeId,
    required this.lines,
    required this.updatedAt,
    this.registerId,
    this.cashSessionId,
    this.customerId,
    this.discountTotal = 0,
    this.note,
  });

  final String id;
  final String tenantId;
  final String storeId;
  final String? registerId;
  final String employeeId;
  final String? cashSessionId;
  final String? customerId;
  final List<PosCartLine> lines;
  final double discountTotal;
  final String? note;
  final DateTime updatedAt;

  double get subtotal => lines.fold(0, (sum, line) => sum + line.lineTotal);
  double get total => subtotal - discountTotal;
  int get itemCount => lines.fold(0, (sum, line) => sum + line.quantity);

  Map<String, dynamic> toJson() => {
        'id': id,
        'tenant_id': tenantId,
        'store_id': storeId,
        'register_id': registerId,
        'employee_id': employeeId,
        'cash_session_id': cashSessionId,
        'customer_id': customerId,
        'lines': lines.map((l) => l.toJson()).toList(),
        'discount_total': discountTotal,
        'note': note,
        'updated_at': updatedAt.toIso8601String(),
      };

  factory PosCartSnapshot.fromJson(Map<String, dynamic> json) {
    return PosCartSnapshot(
      id: json['id'] as String,
      tenantId: json['tenant_id'] as String,
      storeId: json['store_id'] as String,
      registerId: json['register_id'] as String?,
      employeeId: json['employee_id'] as String,
      cashSessionId: json['cash_session_id'] as String?,
      customerId: json['customer_id'] as String?,
      lines: (json['lines'] as List<dynamic>)
          .map((e) => PosCartLine.fromJson(e as Map<String, dynamic>))
          .toList(),
      discountTotal: (json['discount_total'] as num?)?.toDouble() ?? 0,
      note: json['note'] as String?,
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  @override
  List<Object?> get props => [id, storeId, employeeId, lines, updatedAt];
}

class PosCartLine extends Equatable {
  const PosCartLine({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.unitPrice,
    this.sku,
    this.barcode,
    this.variantId,
  });

  final String productId;
  final String? variantId;
  final String name;
  final String? sku;
  final String? barcode;
  final int quantity;
  final double unitPrice;

  double get lineTotal => unitPrice * quantity;

  Map<String, dynamic> toJson() => {
        'product_id': productId,
        'variant_id': variantId,
        'name': name,
        'sku': sku,
        'barcode': barcode,
        'quantity': quantity,
        'unit_price': unitPrice,
      };

  factory PosCartLine.fromJson(Map<String, dynamic> json) {
    return PosCartLine(
      productId: json['product_id'] as String,
      variantId: json['variant_id'] as String?,
      name: json['name'] as String,
      sku: json['sku'] as String?,
      barcode: json['barcode'] as String?,
      quantity: json['quantity'] as int,
      unitPrice: (json['unit_price'] as num).toDouble(),
    );
  }

  @override
  List<Object?> get props => [productId, variantId, quantity, unitPrice];
}

/// Open cash drawer session snapshot.
class PosCashSessionSnapshot extends Equatable {
  const PosCashSessionSnapshot({
    required this.id,
    required this.tenantId,
    required this.storeId,
    required this.registerId,
    required this.employeeId,
    required this.openingFloat,
    required this.openedAt,
    required this.updatedAt,
    this.closingFloat,
    this.notes,
  });

  final String id;
  final String tenantId;
  final String storeId;
  final String registerId;
  final String employeeId;
  final double openingFloat;
  final double? closingFloat;
  final String? notes;
  final DateTime openedAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'tenant_id': tenantId,
        'store_id': storeId,
        'register_id': registerId,
        'employee_id': employeeId,
        'opening_float': openingFloat,
        'closing_float': closingFloat,
        'notes': notes,
        'opened_at': openedAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  factory PosCashSessionSnapshot.fromJson(Map<String, dynamic> json) {
    return PosCashSessionSnapshot(
      id: json['id'] as String,
      tenantId: json['tenant_id'] as String,
      storeId: json['store_id'] as String,
      registerId: json['register_id'] as String,
      employeeId: json['employee_id'] as String,
      openingFloat: (json['opening_float'] as num).toDouble(),
      closingFloat: (json['closing_float'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
      openedAt: DateTime.parse(json['opened_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  @override
  List<Object?> get props => [id, storeId, registerId, employeeId, updatedAt];
}

/// Recovery bundle after unexpected shutdown.
class PosRecoveryBundle {
  const PosRecoveryBundle({
    this.activeCart,
    this.openCashSession,
    this.pendingSaleIds = const [],
  });

  final PosCartSnapshot? activeCart;
  final PosCashSessionSnapshot? openCashSession;
  final List<String> pendingSaleIds;

  bool get hasRecoverableState =>
      activeCart != null || openCashSession != null || pendingSaleIds.isNotEmpty;
}

String encodePosJson(Map<String, dynamic> json) => jsonEncode(json);

Map<String, dynamic> decodePosJson(String source) =>
    jsonDecode(source) as Map<String, dynamic>;
