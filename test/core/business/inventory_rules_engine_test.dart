import 'package:fashion_pos_enterprise/core/business/domain/entities/inventory_models.dart';
import 'package:fashion_pos_enterprise/core/business/engines/inventory_rules_engine.dart';
import 'package:fashion_pos_enterprise/core/result/result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InventoryRulesEngine', () {
    late InventoryRulesEngine engine;

    setUp(() {
      engine = InventoryRulesEngine();
    });

    test('alerts when below minimum stock', () {
      final snapshot = engine.classify(
        variantId: 'v1',
        warehouseId: 'w1',
        onHand: 5,
        minimumLevel: 10,
      );
      final result = engine.evaluate(snapshot);
      expect(result.alerts.any((a) => a.code == 'below_minimum'), isTrue);
    });

    test('suggests reorder when at reorder point', () {
      final snapshot = engine.classify(
        variantId: 'v1',
        warehouseId: 'w1',
        onHand: 8,
        reorderPoint: 10,
        reorderQuantity: 50,
      );
      final result = engine.evaluate(snapshot);
      expect(result.suggestedReorderQuantity, 50);
      expect(result.alerts.any((a) => a.code == 'reorder_suggested'), isTrue);
    });

    test('reserves available stock', () {
      final snapshot = engine.classify(
        variantId: 'v1',
        warehouseId: 'w1',
        onHand: 20,
        reserved: 5,
      );
      final result = engine.reserveStock(snapshot, 10);
      expect((result as Success<StockSnapshot>).data.reserved, 15);
    });

    test('rejects reservation exceeding available', () {
      final snapshot = engine.classify(
        variantId: 'v1',
        warehouseId: 'w1',
        onHand: 10,
        reserved: 8,
      );
      expect(engine.reserveStock(snapshot, 5).isFailure, isTrue);
    });
  });
}
