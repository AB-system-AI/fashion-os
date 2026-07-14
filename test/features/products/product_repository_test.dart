import 'package:flutter_test/flutter_test.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/database/app_database.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/repository/repository_query.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/sync/sync_queue_writer.dart';
import 'package:fashion_pos_enterprise/features/products/data/repositories/product_repository_impl.dart';
import 'package:fashion_pos_enterprise/features/products/domain/entities/product.dart';
import 'package:fashion_pos_enterprise/features/products/domain/enums/product_enums.dart';

void main() {
  late AppDatabase db;
  late ProductRepositoryImpl repository;

  setUp(() async {
    db = AppDatabase.inMemory();
    await db.executor.ensureOpen(db);
    repository = ProductRepositoryImpl(database: db, syncQueue: SyncQueueWriter(db));
  });

  tearDown(() async {
    await db.close();
  });

  Product _product({String id = 'p1', String sku = 'SKU-1'}) {
    final now = DateTime.now().toUtc();
    return Product(
      id: id,
      tenantId: 'tenant-1',
      name: 'Silk Blouse',
      sku: sku,
      retailPrice: 49.99,
      cost: 20,
      status: ProductStatus.active,
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    );
  }

  test('create and getById persists product offline', () async {
    final created = await repository.create(_product());
    final loaded = await repository.getById(created.id);
    expect(loaded, isNotNull);
    expect(loaded!.name, 'Silk Blouse');
    expect(loaded.sku, 'SKU-1');
  });

  test('findBySku returns matching product', () async {
    await repository.create(_product(sku: 'ABC-123'));
    final found = await repository.findBySku('tenant-1', 'ABC-123');
    expect(found, isNotNull);
    expect(found!.sku, 'ABC-123');
  });

  test('getPage returns paginated tenant products', () async {
    await repository.create(_product(id: 'p1'));
    await repository.create(_product(id: 'p2', sku: 'SKU-2'));
    final page = await repository.getPage(
      const RepositoryQuery(tenantId: 'tenant-1', page: 1, pageSize: 10),
    );
    expect(page.items.length, 2);
    expect(page.totalCount, 2);
  });

  test('soft delete excludes product from default list', () async {
    final created = await repository.create(_product());
    await repository.delete(created.id);
    final loaded = await repository.getById(created.id);
    expect(loaded, isNotNull);
    expect(loaded!.deletedAt, isNotNull);
    final page = await repository.getPage(
      const RepositoryQuery(tenantId: 'tenant-1', pageSize: 10),
    );
    expect(page.items, isEmpty);
  });
}
