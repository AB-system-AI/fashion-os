import 'package:flutter_test/flutter_test.dart';

import 'package:fashion_pos_enterprise/core/business/engines/inventory/inventory_engine.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/features/inventory/domain/entities/stock_level.dart';
import 'package:fashion_pos_enterprise/features/inventory/domain/enums/inventory_enums.dart';
import 'package:fashion_pos_enterprise/features/inventory/domain/value_objects/quantity.dart';

void main() {
  group('InventoryEngine', () {
    late InventoryEngine engine;
    late StockLevel level;

    setUp(() {
      engine = InventoryEngine();
      final now = DateTime.now().toUtc();
      level = StockLevel(
        id: 'l1',
        tenantId: 't1',
        warehouseId: 'w1',
        productId: 'p1',
        onHand: 10,
        reserved: 2,
        version: 1,
        createdAt: now,
        updatedAt: now,
        syncStatus: LocalSyncStatus.synced,
        isDirty: false,
      );
    });

    test('available stock subtracts reserved', () {
      expect(engine.availableStock(level).value, 8);
    });

    test('decreaseStock fails when insufficient', () {
      final result = engine.decreaseStock(
        level: level,
        quantity: const Quantity(20),
        movementType: MovementType.sale,
      );
      expect(result.isFailure, isTrue);
    });

    test('reserveStock reduces available capacity', () {
      final result = engine.reserveStock(level: level, quantity: const Quantity(5));
      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull!.reserved, 7);
    });

    test('releaseReservation restores reserved qty', () {
      final reserved = engine.reserveStock(level: level, quantity: const Quantity(2));
      final released = engine.releaseReservation(level: reserved.dataOrNull!, quantity: const Quantity(2));
      expect(released.isSuccess, isTrue);
      expect(released.dataOrNull!.reserved, 2);
    });
  });
}
