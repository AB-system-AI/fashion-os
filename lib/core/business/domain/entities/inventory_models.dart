import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/business/domain/enums/business_enums.dart';

/// Inventory stock snapshot for a variant at a warehouse.
class StockSnapshot extends Equatable {
  const StockSnapshot({
    required this.variantId,
    required this.warehouseId,
    required this.onHand,
    this.reserved = 0,
    this.incoming = 0,
    this.damaged = 0,
    this.returned = 0,
    this.minimumLevel,
    this.maximumLevel,
    this.reorderPoint,
    this.reorderQuantity,
  });

  final String variantId;
  final String warehouseId;
  final double onHand;
  final double reserved;
  final double incoming;
  final double damaged;
  final double returned;
  final double? minimumLevel;
  final double? maximumLevel;
  final double? reorderPoint;
  final double? reorderQuantity;

  double get available => onHand - reserved - damaged;
  double get effectiveStock => onHand + incoming - reserved;

  bool get isBelowMinimum => minimumLevel != null && available < minimumLevel!;
  bool get isAboveMaximum => maximumLevel != null && onHand > maximumLevel!;
  bool get needsReorder => reorderPoint != null && available <= reorderPoint!;

  StockSnapshot copyWith({
    double? onHand,
    double? reserved,
    double? incoming,
    double? damaged,
    double? returned,
  }) {
    return StockSnapshot(
      variantId: variantId,
      warehouseId: warehouseId,
      onHand: onHand ?? this.onHand,
      reserved: reserved ?? this.reserved,
      incoming: incoming ?? this.incoming,
      damaged: damaged ?? this.damaged,
      returned: returned ?? this.returned,
      minimumLevel: minimumLevel,
      maximumLevel: maximumLevel,
      reorderPoint: reorderPoint,
      reorderQuantity: reorderQuantity,
    );
  }

  @override
  List<Object?> get props => [variantId, warehouseId, onHand, reserved];
}

/// Inventory rule evaluation result.
class InventoryRuleResult extends Equatable {
  const InventoryRuleResult({
    required this.snapshot,
    required this.alerts,
    this.suggestedReorderQuantity,
  });

  final StockSnapshot snapshot;
  final List<InventoryAlert> alerts;
  final double? suggestedReorderQuantity;

  @override
  List<Object?> get props => [snapshot, alerts];
}

class InventoryAlert extends Equatable {
  const InventoryAlert({
    required this.code,
    required this.message,
    required this.severity,
  });

  final String code;
  final String message;
  final String severity;

  @override
  List<Object?> get props => [code, message];
}

/// Auto-reorder rule.
class ReorderRule extends Equatable {
  const ReorderRule({
    required this.id,
    required this.variantId,
    required this.warehouseId,
    required this.reorderPoint,
    required this.reorderQuantity,
    this.supplierId,
    this.isActive = true,
  });

  final String id;
  final String variantId;
  final String warehouseId;
  final double reorderPoint;
  final double reorderQuantity;
  final String? supplierId;
  final bool isActive;

  @override
  List<Object?> get props => [id, variantId, warehouseId];
}
