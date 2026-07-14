import 'package:fashion_pos_enterprise/core/business/domain/entities/inventory_models.dart';
import 'package:fashion_pos_enterprise/core/business/domain/enums/business_enums.dart';
import 'package:fashion_pos_enterprise/core/result/result.dart';
import 'package:fashion_pos_enterprise/core/errors/failure.dart';

/// Evaluates inventory thresholds, reorder rules, and stock classifications.
class InventoryRulesEngine {
  InventoryRuleResult evaluate(StockSnapshot snapshot) {
    final alerts = <InventoryAlert>[];

    if (snapshot.isBelowMinimum) {
      alerts.add(
        InventoryAlert(
          code: 'below_minimum',
          message: 'Stock below minimum level for ${snapshot.variantId}',
          severity: 'warning',
        ),
      );
    }

    if (snapshot.isAboveMaximum) {
      alerts.add(
        InventoryAlert(
          code: 'above_maximum',
          message: 'Stock above maximum level for ${snapshot.variantId}',
          severity: 'info',
        ),
      );
    }

    if (snapshot.available < 0) {
      alerts.add(
        const InventoryAlert(
          code: 'negative_available',
          message: 'Available stock is negative',
          severity: 'critical',
        ),
      );
    }

    double? suggestedReorder;
    if (snapshot.needsReorder && snapshot.reorderQuantity != null) {
      suggestedReorder = snapshot.reorderQuantity;
      alerts.add(
        InventoryAlert(
          code: 'reorder_suggested',
          message: 'Reorder ${snapshot.reorderQuantity} units',
          severity: 'action',
        ),
      );
    }

    return InventoryRuleResult(
      snapshot: snapshot,
      alerts: alerts,
      suggestedReorderQuantity: suggestedReorder,
    );
  }

  Result<StockSnapshot> reserveStock(StockSnapshot snapshot, double quantity) {
    if (quantity <= 0) {
      return const Error(ValidationFailure(message: 'Reserve quantity must be positive', code: 'invalid_quantity'));
    }
    if (snapshot.available < quantity) {
      return const Error(ValidationFailure(message: 'Insufficient available stock', code: 'negative_stock'));
    }
    return Success(snapshot.copyWith(reserved: snapshot.reserved + quantity));
  }

  Result<StockSnapshot> releaseReservation(StockSnapshot snapshot, double quantity) {
    if (quantity <= 0 || snapshot.reserved < quantity) {
      return const Error(ValidationFailure(message: 'Invalid reservation release', code: 'invalid_quantity'));
    }
    return Success(snapshot.copyWith(reserved: snapshot.reserved - quantity));
  }

  StockSnapshot classify({
    required String variantId,
    required String warehouseId,
    required double onHand,
    double reserved = 0,
    double incoming = 0,
    double damaged = 0,
    double returned = 0,
    double? minimumLevel,
    double? maximumLevel,
    double? reorderPoint,
    double? reorderQuantity,
  }) {
    return StockSnapshot(
      variantId: variantId,
      warehouseId: warehouseId,
      onHand: onHand,
      reserved: reserved,
      incoming: incoming,
      damaged: damaged,
      returned: returned,
      minimumLevel: minimumLevel,
      maximumLevel: maximumLevel,
      reorderPoint: reorderPoint,
      reorderQuantity: reorderQuantity,
    );
  }

  bool shouldAutoReorder(ReorderRule rule, StockSnapshot snapshot) {
    return rule.isActive && rule.variantId == snapshot.variantId && snapshot.needsReorder;
  }
}
