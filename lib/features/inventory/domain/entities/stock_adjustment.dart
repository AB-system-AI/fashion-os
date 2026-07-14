import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/features/inventory/domain/enums/inventory_enums.dart';

class StockAdjustmentLine extends Equatable {
  const StockAdjustmentLine({
    required this.productId,
    required this.expectedQuantity,
    required this.adjustedQuantity,
    this.variantId,
    this.notes,
  });

  final String productId;
  final String? variantId;
  final double expectedQuantity;
  final double adjustedQuantity;
  final String? notes;

  double get variance => adjustedQuantity - expectedQuantity;

  Map<String, dynamic> toJson() => {
        'product_id': productId,
        'variant_id': variantId,
        'expected_quantity': expectedQuantity,
        'adjusted_quantity': adjustedQuantity,
        'notes': notes,
      };

  factory StockAdjustmentLine.fromJson(Map<String, dynamic> json) {
    return StockAdjustmentLine(
      productId: json['product_id'] as String,
      variantId: json['variant_id'] as String?,
      expectedQuantity: (json['expected_quantity'] as num?)?.toDouble() ?? 0,
      adjustedQuantity: (json['adjusted_quantity'] as num?)?.toDouble() ?? 0,
      notes: json['notes'] as String?,
    );
  }

  @override
  List<Object?> get props => [productId, variantId, adjustedQuantity];
}

class StockAdjustment extends Equatable implements SyncableEntity {
  const StockAdjustment({
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
    this.reason = MovementReason.correction,
    this.notes,
    this.employeeId,
    this.postedAt,
    this.deletedAt,
  });

  static const entityTypeName = 'stock_adjustment';

  @override
  final String id;
  @override
  final String tenantId;
  final String warehouseId;
  final AdjustmentStatus status;
  final MovementReason reason;
  final List<StockAdjustmentLine> lines;
  final String? notes;
  final String? employeeId;
  final DateTime? postedAt;
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
        'reason': reason.value,
        'lines': lines.map((l) => l.toJson()).toList(),
        'notes': notes,
        'employee_id': employeeId,
        'posted_at': postedAt?.toIso8601String(),
        'version': version,
      };

  factory StockAdjustment.fromPayload(Map<String, dynamic> json, LocalRecord record) {
    final rawLines = json['lines'] as List<dynamic>? ?? const [];
    return StockAdjustment(
      id: record.id,
      tenantId: record.tenantId,
      warehouseId: json['warehouse_id'] as String? ?? record.storeId ?? '',
      status: AdjustmentStatus.values.firstWhere(
        (e) => e.value == (json['status'] as String? ?? 'draft'),
        orElse: () => AdjustmentStatus.draft,
      ),
      reason: MovementReason.values.firstWhere(
        (e) => e.value == (json['reason'] as String? ?? 'correction'),
        orElse: () => MovementReason.correction,
      ),
      lines: rawLines.map((e) => StockAdjustmentLine.fromJson(Map<String, dynamic>.from(e as Map))).toList(),
      notes: json['notes'] as String?,
      employeeId: json['employee_id'] as String?,
      postedAt: json['posted_at'] != null ? DateTime.tryParse(json['posted_at'] as String) : null,
      version: record.version,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
      deletedAt: record.deletedAt,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  @override
  List<Object?> get props => [id, warehouseId, status];
}
