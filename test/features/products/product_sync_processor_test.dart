import 'package:flutter_test/flutter_test.dart';

import 'package:fashion_pos_enterprise/features/products/data/datasources/product_remote_datasource.dart';
import 'package:fashion_pos_enterprise/features/products/data/sync/product_sync_processor.dart';
import 'package:fashion_pos_enterprise/features/products/domain/entities/product.dart';

void main() {
  test('ProductSyncProcessor registers product entity type', () {
    final processor = ProductSyncProcessor(ProductRemoteDataSource());
    expect(processor.entityType, Product.entityTypeName);
  });
}
