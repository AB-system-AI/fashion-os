import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/business/domain/entities/inventory_models.dart';
import 'package:fashion_pos_enterprise/core/business/engines/inventory_rules_engine.dart';
import 'package:fashion_pos_enterprise/features/products/domain/entities/product.dart';

/// Read-only inventory summary for catalog detail — no stock mutations.
class InventoryPreviewSummary extends Equatable {
  const InventoryPreviewSummary({
    required this.available,
    required this.reserved,
    required this.incoming,
    required this.damaged,
    required this.returned,
    required this.soldToday,
    this.alerts = const [],
  });

  final double available;
  final double reserved;
  final double incoming;
  final double damaged;
  final double returned;
  final double soldToday;
  final List<InventoryAlert> alerts;

  @override
  List<Object?> get props => [available, reserved, incoming, damaged, returned, soldToday];
}

/// Builds inventory preview from product variant stock via [InventoryRulesEngine].
class ProductInventoryPreviewService {
  const ProductInventoryPreviewService({InventoryRulesEngine? rulesEngine})
      : _rules = rulesEngine ?? InventoryRulesEngine();

  final InventoryRulesEngine _rules;

  InventoryPreviewSummary summarize(Product product, {String warehouseId = 'default'}) {
    if (product.variants.isEmpty) {
      final snapshot = _rules.classify(
        variantId: product.id,
        warehouseId: warehouseId,
        onHand: product.totalStock,
      );
      final evaluation = _rules.evaluate(snapshot);
      return InventoryPreviewSummary(
        available: snapshot.available,
        reserved: snapshot.reserved,
        incoming: snapshot.incoming,
        damaged: snapshot.damaged,
        returned: snapshot.returned,
        soldToday: 0,
        alerts: evaluation.alerts,
      );
    }

    double available = 0;
    double reserved = 0;
    double incoming = 0;
    double damaged = 0;
    double returned = 0;
    final alerts = <InventoryAlert>[];

    for (final variant in product.variants) {
      if (!variant.isActive) continue;
      final snapshot = _rules.classify(
        variantId: variant.id,
        warehouseId: warehouseId,
        onHand: variant.stockQuantity,
      );
      available += snapshot.available;
      reserved += snapshot.reserved;
      incoming += snapshot.incoming;
      damaged += snapshot.damaged;
      returned += snapshot.returned;
      alerts.addAll(_rules.evaluate(snapshot).alerts);
    }

    return InventoryPreviewSummary(
      available: available,
      reserved: reserved,
      incoming: incoming,
      damaged: damaged,
      returned: returned,
      soldToday: 0,
      alerts: alerts,
    );
  }
}
