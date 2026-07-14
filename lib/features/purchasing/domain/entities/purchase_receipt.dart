import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';

class PurchaseReceiptLine extends Equatable {
  const PurchaseReceiptLine({
    required this.poLineId,
    required this.productId,
    required this.variantId,
    required this.quantityReceived,
    required this.unitCost,
  });

  final String poLineId;
  final String productId;
  final String variantId;
  final double quantityReceived;
  final double unitCost;

  Map<String, dynamic> toJson() => {
        'po_line_id': poLineId,
        'product_id': productId,
        'variant_id': variantId,
        'quantity_received': quantityReceived,
        'unit_cost': unitCost,
      };

  factory PurchaseReceiptLine.fromJson(Map<String, dynamic> json) {
    return PurchaseReceiptLine(
      poLineId: json['po_line_id'] as String? ?? '',
      productId: json['product_id'] as String? ?? '',
      variantId: json['variant_id'] as String? ?? '',
      quantityReceived: (json['quantity_received'] as num?)?.toDouble() ?? 0,
      unitCost: (json['unit_cost'] as num?)?.toDouble() ?? 0,
    );
  }

  @override
  List<Object?> get props => [poLineId, variantId, quantityReceived];
}

class PurchaseReceipt extends Equatable implements SyncableEntity {
  const PurchaseReceipt({
    required this.id,
    required this.tenantId,
    required this.purchaseOrderId,
    required this.warehouseId,
    required this.receiptNumber,
    required this.lines,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.receivedAt,
    this.notes,
    this.receivedBy,
    this.deletedAt,
  });

  static const entityTypeName = 'purchase_receipt';

  @override
  final String id;
  @override
  final String tenantId;
  final String purchaseOrderId;
  final String warehouseId;
  final String receiptNumber;
  final List<PurchaseReceiptLine> lines;
  final DateTime? receivedAt;
  final String? notes;
  final String? receivedBy;
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
        'purchase_order_id': purchaseOrderId,
        'warehouse_id': warehouseId,
        'receipt_number': receiptNumber,
        'lines': lines.map((l) => l.toJson()).toList(),
        'received_at': receivedAt?.toIso8601String(),
        'notes': notes,
        'received_by': receivedBy,
        'version': version,
      };

  factory PurchaseReceipt.fromPayload(Map<String, dynamic> json, LocalRecord record) {
    final rawLines = json['lines'] as List<dynamic>? ?? const [];
    return PurchaseReceipt(
      id: record.id,
      tenantId: record.tenantId,
      purchaseOrderId: json['purchase_order_id'] as String? ?? '',
      warehouseId: json['warehouse_id'] as String? ?? record.storeId ?? '',
      receiptNumber: json['receipt_number'] as String? ?? record.searchName ?? '',
      lines: rawLines.map((e) => PurchaseReceiptLine.fromJson(Map<String, dynamic>.from(e as Map))).toList(),
      receivedAt: json['received_at'] != null ? DateTime.tryParse(json['received_at'] as String) : null,
      notes: json['notes'] as String?,
      receivedBy: json['received_by'] as String?,
      version: record.version,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
      deletedAt: record.deletedAt,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  @override
  List<Object?> get props => [id, receiptNumber, purchaseOrderId];
}
