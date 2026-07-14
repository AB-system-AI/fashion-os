import 'package:flutter_test/flutter_test.dart';

import 'package:fashion_pos_enterprise/core/business/engines/manufacturing/manufacturing_engine.dart';

void main() {
  test('purchase suggestions respect MOQ and supplier priority', () {
    final engine = ManufacturingEngine();
    final shortages = [
      const MaterialRequirement(productId: 'p1', requiredQty: 10, shortage: 3),
    ];
    final suggestions = engine.suggestPurchases(
      shortages,
      supplierByProduct: {'p1': 'sup1'},
      minimumOrderQtyByProduct: {'p1': 10},
      supplierPriorityByProduct: {'p1': 1},
    );
    expect(suggestions.first.orderQty, 10);
    expect(suggestions.first.supplierId, 'sup1');
  });
}
