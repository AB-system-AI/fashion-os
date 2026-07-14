import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/features/inventory/domain/enums/inventory_enums.dart';

class InventoryTransferLine extends Equatable {
  const InventoryTransferLine({
    required this.productId,
    required this.quantity,
    this.variantId,
    this.shippedQuantity = 0,
    this.receivedQuantity = 0,
  });

  final String productId;
  final String? variantId;
  final double quantity;
  final double shippedQuantity;
  final double receivedQuantity;

  Map<String, dynamic> toJson() => {
        'product_id': productId,
        'variant_id': variantId,
        'quantity': quantity,
        'shipped_quantity': shippedQuantity,
        'received_quantity': receivedQuantity,
      };

  factory InventoryTransferLine.fromJson(Map<String, dynamic> json) {
    return InventoryTransferLine(
      productId: json['product_id'] as String,
      variantId: json['variant_id'] as String?,
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0,
      shippedQuantity: (json['shipped_quantity'] as num?)?.toDouble() ?? 0,
      receivedQuantity: (json['received_quantity'] as num?)?.toDouble() ?? 0,
    );
  }

  InventoryTransferLine copyWith({double? shippedQuantity, double? receivedQuantity}) {
    return InventoryTransferLine(
      productId: productId,
      variantId: variantId,
      quantity: quantity,
      shippedQuantity: shippedQuantity ?? this.shippedQuantity,
      receivedQuantity: receivedQuantity ?? this.receivedQuantity,
    );
  }

  @override
  List<Object?> get props => [productId, variantId, quantity];
}

class InventoryTransfer extends Equatable implements SyncableEntity {
  const InventoryTransfer({
    required this.id,
    required this.tenantId,
    required this.fromWarehouseId,
    required this.toWarehouseId,
    required this.status,
    required this.lines,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.reference,
    this.notes,
    this.approvedBy,
    this.shippedAt,
    this.receivedAt,
    this.completedAt,
    this.deletedAt,
  });

  static const entityTypeName = 'inventory_transfer';

  @override
  final String id;
  @override
  final String tenantId;
  final String fromWarehouseId;
  final String toWarehouseId;
  final TransferStatus status;
  final List<InventoryTransferLine> lines;
  final String? reference;
  final String? notes;
  final String? approvedBy;
  final DateTime? shippedAt;
  final DateTime? receivedAt;
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
        'from_warehouse_id': fromWarehouseId,
        'to_warehouse_id': toWarehouseId,
        'status': status.value,
        'lines': lines.map((l) => l.toJson()).toList(),
        'reference': reference,
        'notes': notes,
        'approved_by': approvedBy,
        'shipped_at': shippedAt?.toIso8601String(),
        'received_at': receivedAt?.toIso8601String(),
        'completed_at': completedAt?.toIso8601String(),
        'version': version,
      };

  factory InventoryTransfer.fromPayload(Map<String, dynamic> json, LocalRecord record) {
    final rawLines = json['lines'] as List<dynamic>? ?? const [];
    return InventoryTransfer(
      id: record.id,
      tenantId: record.tenantId,
      fromWarehouseId: json['from_warehouse_id'] as String? ?? '',
      toWarehouseId: json['to_warehouse_id'] as String? ?? '',
      status: TransferStatus.fromValue(json['status'] as String? ?? 'DRAFT'),
      lines: rawLines.map((e) => InventoryTransferLine.fromJson(Map<String, dynamic>.from(e as Map))).toList(),
      reference: json['reference'] as String? ?? record.searchName,
      notes: json['notes'] as String?,
      approvedBy: json['approved_by'] as String?,
      shippedAt: json['shipped_at'] != null ? DateTime.tryParse(json['shipped_at'] as String) : null,
      receivedAt: json['received_at'] != null ? DateTime.tryParse(json['received_at'] as String) : null,
      completedAt: json['completed_at'] != null ? DateTime.tryParse(json['completed_at'] as String) : null,
      version: record.version,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
      deletedAt: record.deletedAt,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  InventoryTransfer copyWith({
    TransferStatus? status,
    List<InventoryTransferLine>? lines,
    String? approvedBy,
    DateTime? shippedAt,
    DateTime? receivedAt,
    DateTime? completedAt,
    int? version,
    DateTime? updatedAt,
    LocalSyncStatus? syncStatus,
    bool? isDirty,
  }) {
    return InventoryTransfer(
      id: id,
      tenantId: tenantId,
      fromWarehouseId: fromWarehouseId,
      toWarehouseId: toWarehouseId,
      status: status ?? this.status,
      lines: lines ?? this.lines,
      reference: reference,
      notes: notes,
      approvedBy: approvedBy ?? this.approvedBy,
      shippedAt: shippedAt ?? this.shippedAt,
      receivedAt: receivedAt ?? this.receivedAt,
      completedAt: completedAt ?? this.completedAt,
      version: version ?? this.version,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      isDirty: isDirty ?? this.isDirty,
    );
  }

  @override
  List<Object?> get props => [id, status, fromWarehouseId, toWarehouseId];
}
