import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/features/purchasing/domain/enums/purchasing_enums.dart';

class PurchaseOrderLine extends Equatable {
  const PurchaseOrderLine({
    required this.id,
    required this.productId,
    required this.variantId,
    required this.quantity,
    required this.unitCost,
    this.discount = 0,
    this.tax = 0,
    this.receivedQuantity = 0,
  });

  final String id;
  final String productId;
  final String variantId;
  final double quantity;
  final double unitCost;
  final double discount;
  final double tax;
  final double receivedQuantity;

  double get remainingQuantity => (quantity - receivedQuantity).clamp(0, quantity);
  double get lineSubtotal => quantity * unitCost;
  double get lineTotal => lineSubtotal - discount + tax;

  Map<String, dynamic> toJson() => {
        'id': id,
        'product_id': productId,
        'variant_id': variantId,
        'quantity_ordered': quantity,
        'quantity_received': receivedQuantity,
        'unit_cost': unitCost,
        'discount': discount,
        'tax_amount': tax,
        'line_total': lineTotal,
      };

  factory PurchaseOrderLine.fromJson(Map<String, dynamic> json) {
    return PurchaseOrderLine(
      id: json['id'] as String? ?? '',
      productId: json['product_id'] as String? ?? '',
      variantId: json['variant_id'] as String? ?? '',
      quantity: (json['quantity_ordered'] as num?)?.toDouble() ?? (json['quantity'] as num?)?.toDouble() ?? 0,
      unitCost: (json['unit_cost'] as num?)?.toDouble() ?? 0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0,
      tax: (json['tax_amount'] as num?)?.toDouble() ?? (json['tax'] as num?)?.toDouble() ?? 0,
      receivedQuantity: (json['quantity_received'] as num?)?.toDouble() ?? (json['received_quantity'] as num?)?.toDouble() ?? 0,
    );
  }

  PurchaseOrderLine copyWith({
    double? quantity,
    double? unitCost,
    double? discount,
    double? tax,
    double? receivedQuantity,
  }) {
    return PurchaseOrderLine(
      id: id,
      productId: productId,
      variantId: variantId,
      quantity: quantity ?? this.quantity,
      unitCost: unitCost ?? this.unitCost,
      discount: discount ?? this.discount,
      tax: tax ?? this.tax,
      receivedQuantity: receivedQuantity ?? this.receivedQuantity,
    );
  }

  @override
  List<Object?> get props => [id, productId, variantId, quantity];
}

class PurchaseOrder extends Equatable implements SyncableEntity {
  const PurchaseOrder({
    required this.id,
    required this.tenantId,
    required this.supplierId,
    required this.warehouseId,
    required this.poNumber,
    required this.status,
    required this.lines,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.storeId,
    this.currency = 'USD',
    this.subtotal = 0,
    this.discountTotal = 0,
    this.taxTotal = 0,
    this.grandTotal = 0,
    this.expectedDelivery,
    this.notes,
    this.createdBy,
    this.submittedAt,
    this.receivedAt,
    this.cancelledAt,
    this.deletedAt,
  });

  static const entityTypeName = 'purchase_order';

  @override
  final String id;
  @override
  final String tenantId;
  final String? storeId;
  final String supplierId;
  final String warehouseId;
  final String poNumber;
  final PurchaseOrderStatus status;
  final String currency;
  final double subtotal;
  final double discountTotal;
  final double taxTotal;
  final double grandTotal;
  final DateTime? expectedDelivery;
  final String? notes;
  final List<PurchaseOrderLine> lines;
  final String? createdBy;
  final DateTime? submittedAt;
  final DateTime? receivedAt;
  final DateTime? cancelledAt;
  @override
  final int version;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? deletedAt;
  @override
  final LocalSyncStatus syncStatus;
  @override
  final bool isDirty;

  @override
  String get entityType => entityTypeName;

  @override
  Map<String, dynamic> toPayload() => {
        'id': id,
        'tenant_id': tenantId,
        'store_id': storeId,
        'supplier_id': supplierId,
        'warehouse_id': warehouseId,
        'po_number': poNumber,
        'status': status.value,
        'currency': currency,
        'subtotal': subtotal,
        'discount_total': discountTotal,
        'tax_total': taxTotal,
        'grand_total': grandTotal,
        'expected_date': expectedDelivery?.toIso8601String().split('T').first,
        'notes': notes,
        'lines': lines.map((l) => l.toJson()).toList(),
        'created_by': createdBy,
        'submitted_at': submittedAt?.toIso8601String(),
        'received_at': receivedAt?.toIso8601String(),
        'cancelled_at': cancelledAt?.toIso8601String(),
        'version': version,
      };

  factory PurchaseOrder.fromPayload(Map<String, dynamic> json, LocalRecord record) {
    final rawLines = json['lines'] as List<dynamic>? ?? const [];
    return PurchaseOrder(
      id: record.id,
      tenantId: record.tenantId,
      storeId: json['store_id'] as String? ?? record.storeId,
      supplierId: json['supplier_id'] as String? ?? '',
      warehouseId: json['warehouse_id'] as String? ?? '',
      poNumber: json['po_number'] as String? ?? record.searchName ?? '',
      status: PurchaseOrderStatus.fromValue(json['status'] as String?),
      currency: json['currency'] as String? ?? 'USD',
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0,
      discountTotal: (json['discount_total'] as num?)?.toDouble() ?? 0,
      taxTotal: (json['tax_total'] as num?)?.toDouble() ?? 0,
      grandTotal: (json['grand_total'] as num?)?.toDouble() ?? 0,
      expectedDelivery: json['expected_date'] != null ? DateTime.tryParse(json['expected_date'] as String) : null,
      notes: json['notes'] as String?,
      lines: rawLines.map((e) => PurchaseOrderLine.fromJson(Map<String, dynamic>.from(e as Map))).toList(),
      createdBy: json['created_by'] as String?,
      submittedAt: json['submitted_at'] != null ? DateTime.tryParse(json['submitted_at'] as String) : null,
      receivedAt: json['received_at'] != null ? DateTime.tryParse(json['received_at'] as String) : null,
      cancelledAt: json['cancelled_at'] != null ? DateTime.tryParse(json['cancelled_at'] as String) : null,
      version: record.version,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
      deletedAt: record.deletedAt,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  PurchaseOrder copyWith({
    String? supplierId,
    String? warehouseId,
    PurchaseOrderStatus? status,
    String? currency,
    double? subtotal,
    double? discountTotal,
    double? taxTotal,
    double? grandTotal,
    DateTime? expectedDelivery,
    String? notes,
    List<PurchaseOrderLine>? lines,
    String? createdBy,
    DateTime? submittedAt,
    DateTime? receivedAt,
    DateTime? cancelledAt,
    int? version,
    DateTime? updatedAt,
    LocalSyncStatus? syncStatus,
    bool? isDirty,
  }) {
    return PurchaseOrder(
      id: id,
      tenantId: tenantId,
      storeId: storeId,
      supplierId: supplierId ?? this.supplierId,
      warehouseId: warehouseId ?? this.warehouseId,
      poNumber: poNumber,
      status: status ?? this.status,
      currency: currency ?? this.currency,
      subtotal: subtotal ?? this.subtotal,
      discountTotal: discountTotal ?? this.discountTotal,
      taxTotal: taxTotal ?? this.taxTotal,
      grandTotal: grandTotal ?? this.grandTotal,
      expectedDelivery: expectedDelivery ?? this.expectedDelivery,
      notes: notes ?? this.notes,
      lines: lines ?? this.lines,
      createdBy: createdBy ?? this.createdBy,
      submittedAt: submittedAt ?? this.submittedAt,
      receivedAt: receivedAt ?? this.receivedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      version: version ?? this.version,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      isDirty: isDirty ?? this.isDirty,
    );
  }

  @override
  List<Object?> get props => [id, poNumber, status, supplierId];
}
