import 'package:flutter_test/flutter_test.dart';

import 'package:fashion_pos_enterprise/features/products/data/datasources/brand_remote_datasource.dart';
import 'package:fashion_pos_enterprise/features/products/data/sync/brand_sync_processor.dart';
import 'package:fashion_pos_enterprise/features/products/domain/entities/brand.dart';

void main() {
  test('BrandSyncProcessor registers brand entity type', () {
    final processor = BrandSyncProcessor(BrandRemoteDataSource());
    expect(processor.entityType, Brand.entityTypeName);
  });
}
