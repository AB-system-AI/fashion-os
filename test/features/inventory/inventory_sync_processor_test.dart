import 'package:flutter_test/flutter_test.dart';

import 'package:fashion_pos_enterprise/features/inventory/data/sync/inventory_sync_processor.dart';
import 'package:fashion_pos_enterprise/features/inventory/domain/entities/stock_level.dart';
import 'package:fashion_pos_enterprise/features/inventory/domain/entities/stock_movement.dart';
import 'package:fashion_pos_enterprise/features/inventory/domain/entities/warehouse.dart';

void main() {
  test('inventory sync processors expose entity types', () {
    expect(
      InventorySyncProcessor(
        remote: throw UnimplementedError(),
        entityTypeName: Warehouse.entityTypeName,
        remoteTable: 'warehouses',
      ).entityType,
      'warehouse',
    );
    expect(StockLevel.entityTypeName, 'stock_level');
    expect(StockMovement.entityTypeName, 'stock_movement');
  });
}
