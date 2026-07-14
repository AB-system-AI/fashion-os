import 'package:flutter_test/flutter_test.dart';

import 'package:fashion_pos_enterprise/features/purchasing/data/sync/purchase_sync_processor.dart';
import 'package:fashion_pos_enterprise/features/purchasing/domain/entities/purchase_order.dart';
import 'package:fashion_pos_enterprise/features/purchasing/domain/entities/supplier.dart';

void main() {
  test('supplier sync processor entity type mapping', () {
  expect(Supplier.entityTypeName, 'supplier');
  expect(PurchaseOrder.entityTypeName, 'purchase_order');
  expect(PurchaseSyncProcessor, isNotNull);
  });
}
