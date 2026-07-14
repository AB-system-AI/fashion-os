import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/features/purchasing/domain/enums/purchasing_enums.dart';

class PurchaseReturnLine extends Equatable {
  const PurchaseReturnLine({
    required this.productId,
    required this.variantId,
    required this.quantity,
    required this.unitCost,
    this.poLineId,
  });

  final String? poLineId;
  final String productId;
  final String variantId;
  final double quantity;
  final double unitCost;

  Map<String, dynamic> toJson() => {
        'po_line_id': poLineId,
        'product_id': productId,
        'variant_id': variantId,
        'quantity': quantity,
        'unit_cost': unitCost,
      };

  factory PurchaseReturnLine.fromJson(Map<String, dynamic> json) {
    return PurchaseReturnLine(
      poLineId: json['po_line_id'] as String?,
      productId: json['product_id'] as String? ?? '',
      variantId: json['variant_id'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0,
      unitCost: (json['unit_cost'] as num?)?.toDouble() ?? 0,
    );
  }

  @override
  List<Object?> get props => [productId, variantId, quantity];
}

class PurchaseReturn extends Equatable implements SyncableEntity {
  const PurchaseReturn({
    required this.id,
    required this.tenantId,
    required this.supplierId,
    required this.warehouseId,
    required this.returnNumber,
    required this.status,
    required this.lines,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.purchaseOrderId,
    this.notes,
    this.totalAmount = 0,
    this.approvedBy,
    this.completedAt,
    this.deletedAt,
  });

  static const entityTypeName = 'purchase_return';

  @override
  final String id;
  @override
  final String tenantId;
  final String supplierId;
  final String warehouseId;
  final String? purchaseOrderId;
  final String returnNumber;
  final PurchaseReturnStatus status;
  final List<PurchaseReturnLine> lines;
  final double totalAmount;
  final String? notes;
  final String? approvedBy;
  final DateTime? completedAt;
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
        'supplier_id': supplierId,
        'warehouse_id': warehouseId,
        'purchase_order_id': purchaseOrderId,
        'return_number': returnNumber,
        'status': status.value,
        'lines': lines.map((l) => l.toJson()).toList(),
        'total_amount': totalAmount,
        'notes': notes,
        'approved_by': approvedBy,
        'completed_at': completedAt?.toIso8601String(),
        'version': version,
      };

  factory PurchaseReturn.fromPayload(Map<String, dynamic> json, LocalRecord record) {
    final rawLines = json['lines'] as List<dynamic>? ?? const [];
    return PurchaseReturn(
      id: record.id,
      tenantId: record.tenantId,
      supplierId: json['supplier_id'] as String? ?? '',
      warehouseId: json['warehouse_id'] as String? ?? record.storeId ?? '',
      purchaseOrderId: json['purchase_order_id'] as String?,
      returnNumber: json['return_number'] as String? ?? record.searchName ?? '',
      status: PurchaseReturnStatus.fromValue(json['status'] as String?),
      lines: rawLines.map((e) => PurchaseReturnLine.fromJson(Map<String, dynamic>.from(e as Map))).toList(),
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0,
      notes: json['notes'] as String?,
      approvedBy: json['approved_by'] as String?,
      completedAt: json['completed_at'] != null ? DateTime.tryParse(json['completed_at'] as String) : null,
      version: record.version,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
      deletedAt: record.deletedAt,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  PurchaseReturn copyWith({
    PurchaseReturnStatus? status,
    List<PurchaseReturnLine>? lines,
    double? totalAmount,
    String? approvedBy,
    DateTime? completedAt,
    int? version,
    DateTime? updatedAt,
    LocalSyncStatus? syncStatus,
    bool? isDirty,
  }) {
    return PurchaseReturn(
      id: id,
      tenantId: tenantId,
      supplierId: supplierId,
      warehouseId: warehouseId,
      purchaseOrderId: purchaseOrderId,
      returnNumber: returnNumber,
      status: status ?? this.status,
      lines: lines ?? this.lines,
      totalAmount: totalAmount ?? this.totalAmount,
      notes: notes,
      approvedBy: approvedBy ?? this.approvedBy,
      completedAt: completedAt ?? this.completedAt,
      version: version ?? this.version,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      isDirty: isDirty ?? this.isDirty,
    );
  }

  @override
  List<Object?> get props => [id, returnNumber, status];
}
