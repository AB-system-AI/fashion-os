import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/features/inventory/domain/enums/inventory_enums.dart';

class StockCountLine extends Equatable {
  const StockCountLine({
    required this.productId,
    required this.expectedQuantity,
    required this.countedQuantity,
    this.variantId,
    this.barcode,
  });

  final String productId;
  final String? variantId;
  final String? barcode;
  final double expectedQuantity;
  final double countedQuantity;

  double get variance => countedQuantity - expectedQuantity;

  Map<String, dynamic> toJson() => {
        'product_id': productId,
        'variant_id': variantId,
        'barcode': barcode,
        'expected_quantity': expectedQuantity,
        'counted_quantity': countedQuantity,
      };

  factory StockCountLine.fromJson(Map<String, dynamic> json) {
    return StockCountLine(
      productId: json['product_id'] as String,
      variantId: json['variant_id'] as String?,
      barcode: json['barcode'] as String?,
      expectedQuantity: (json['expected_quantity'] as num?)?.toDouble() ?? 0,
      countedQuantity: (json['counted_quantity'] as num?)?.toDouble() ?? 0,
    );
  }

  StockCountLine copyWith({double? countedQuantity}) {
    return StockCountLine(
      productId: productId,
      variantId: variantId,
      barcode: barcode,
      expectedQuantity: expectedQuantity,
      countedQuantity: countedQuantity ?? this.countedQuantity,
    );
  }

  @override
  List<Object?> get props => [productId, variantId, countedQuantity];
}

class StockCount extends Equatable implements SyncableEntity {
  const StockCount({
    required this.id,
    required this.tenantId,
    required this.warehouseId,
    required this.status,
    required this.lines,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.name,
    this.notes,
    this.completedAt,
    this.adjustmentId,
    this.deletedAt,
  });

  static const entityTypeName = 'stock_count';

  @override
  final String id;
  @override
  final String tenantId;
  final String warehouseId;
  final StockCountStatus status;
  final List<StockCountLine> lines;
  final String? name;
  final String? notes;
  final DateTime? completedAt;
  final String? adjustmentId;
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
        'warehouse_id': warehouseId,
        'status': status.value,
        'name': name,
        'notes': notes,
        'lines': lines.map((l) => l.toJson()).toList(),
        'completed_at': completedAt?.toIso8601String(),
        'adjustment_id': adjustmentId,
        'version': version,
      };

  factory StockCount.fromPayload(Map<String, dynamic> json, LocalRecord record) {
    final rawLines = json['lines'] as List<dynamic>? ?? const [];
    return StockCount(
      id: record.id,
      tenantId: record.tenantId,
      warehouseId: json['warehouse_id'] as String? ?? record.storeId ?? '',
      status: StockCountStatus.fromValue(json['status'] as String? ?? 'DRAFT'),
      name: json['name'] as String? ?? record.searchName,
      notes: json['notes'] as String?,
      lines: rawLines.map((e) => StockCountLine.fromJson(Map<String, dynamic>.from(e as Map))).toList(),
      completedAt: json['completed_at'] != null ? DateTime.tryParse(json['completed_at'] as String) : null,
      adjustmentId: json['adjustment_id'] as String?,
      version: record.version,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
      deletedAt: record.deletedAt,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  StockCount copyWith({
    StockCountStatus? status,
    List<StockCountLine>? lines,
    DateTime? completedAt,
    String? adjustmentId,
    int? version,
    DateTime? updatedAt,
    LocalSyncStatus? syncStatus,
    bool? isDirty,
  }) {
    return StockCount(
      id: id,
      tenantId: tenantId,
      warehouseId: warehouseId,
      status: status ?? this.status,
      lines: lines ?? this.lines,
      name: name,
      notes: notes,
      completedAt: completedAt ?? this.completedAt,
      adjustmentId: adjustmentId ?? this.adjustmentId,
      version: version ?? this.version,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      isDirty: isDirty ?? this.isDirty,
    );
  }

  @override
  List<Object?> get props => [id, warehouseId, status];
}
