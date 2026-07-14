import 'package:flutter_test/flutter_test.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/database/app_database.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/sync/sync_queue_writer.dart';
import 'package:fashion_pos_enterprise/features/inventory/data/repositories/inventory_repository_impl.dart';
import 'package:fashion_pos_enterprise/features/inventory/domain/entities/warehouse.dart';

void main() {
  late AppDatabase db;
  late WarehouseRepositoryImpl repository;

  setUp(() async {
    db = AppDatabase.inMemory();
    await db.executor.ensureOpen(db);
    repository = WarehouseRepositoryImpl(database: db, syncQueue: SyncQueueWriter(db));
  });

  tearDown(() async {
    await db.close();
  });

  test('create warehouse persists offline with sync queue', () async {
    final now = DateTime.now().toUtc();
    final created = await repository.create(
      Warehouse(
        id: 'wh1',
        tenantId: 't1',
        name: 'Main Warehouse',
        version: 1,
        createdAt: now,
        updatedAt: now,
        syncStatus: LocalSyncStatus.pending,
        isDirty: true,
      ),
    );
    expect(created.name, 'Main Warehouse');

    final loaded = await repository.getById('wh1', tenantId: 't1');
    expect(loaded?.name, 'Main Warehouse');

    final otherTenant = await repository.getById('wh1', tenantId: 't-other');
    expect(otherTenant, isNull);

    final pending = await db.syncQueueDao.getPending();
    expect(pending.any((e) => e.entityType == Warehouse.entityTypeName), isTrue);
  });
}
