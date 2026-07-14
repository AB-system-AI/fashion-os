import 'package:flutter_test/flutter_test.dart';

import 'package:fashion_pos_enterprise/features/products/data/datasources/category_remote_datasource.dart';
import 'package:fashion_pos_enterprise/features/products/data/sync/category_sync_processor.dart';
import 'package:fashion_pos_enterprise/features/products/domain/entities/category.dart';

void main() {
  test('CategorySyncProcessor registers category entity type', () {
    final processor = CategorySyncProcessor(CategoryRemoteDataSource());
    expect(processor.entityType, Category.entityTypeName);
  });
}
