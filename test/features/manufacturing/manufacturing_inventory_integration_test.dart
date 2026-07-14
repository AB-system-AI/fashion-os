import 'package:flutter_test/flutter_test.dart';

import 'package:fashion_pos_enterprise/core/business/engines/inventory/inventory_engine.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/features/inventory/domain/entities/stock_level.dart';
import 'package:fashion_pos_enterprise/features/inventory/domain/value_objects/quantity.dart';

void main() {
  test('reserveStock reduces available for production release', () {
    final engine = InventoryEngine();
    final level = StockLevel(
      id: 'sl1',
      tenantId: 't1',
      warehouseId: 'w1',
      productId: 'p1',
      onHand: 100,
      reserved: 0,
      version: 1,
      createdAt: DateTime.utc(2025),
      updatedAt: DateTime.utc(2025),
      syncStatus: LocalSyncStatus.synced,
      isDirty: false,
    );
    final result = engine.reserveStock(level: level, quantity: const Quantity(25));
    expect(result.isSuccess, isTrue);
    expect(result.dataOrNull!.reserved, 25);
    expect(result.dataOrNull!.available, 75);
  });
}
