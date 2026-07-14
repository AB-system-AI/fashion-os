import 'package:flutter_test/flutter_test.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/database/app_database.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/sync/sync_queue_writer.dart';
import 'package:fashion_pos_enterprise/features/purchasing/data/repositories/purchasing_repository_impl.dart';
import 'package:fashion_pos_enterprise/features/purchasing/domain/entities/supplier.dart';

void main() {
  late AppDatabase db;
  late SupplierRepositoryImpl repository;

  setUp(() async {
    db = AppDatabase.inMemory();
    await db.executor.ensureOpen(db);
    repository = SupplierRepositoryImpl(database: db, syncQueue: SyncQueueWriter(db));
  });

  tearDown(() async {
    await db.close();
  });

  test('create supplier persists offline with sync queue', () async {
    final now = DateTime.now().toUtc();
    final created = await repository.create(
      Supplier(
        id: 's1',
        tenantId: 't1',
        supplierCode: 'SUP-001',
        companyName: 'Acme Supplies',
        version: 1,
        createdAt: now,
        updatedAt: now,
        syncStatus: LocalSyncStatus.pending,
        isDirty: true,
      ),
    );
    expect(created.companyName, 'Acme Supplies');

    final loaded = await repository.getById('s1', tenantId: 't1');
    expect(loaded?.supplierCode, 'SUP-001');

    final pending = await db.syncQueueDao.getPending();
    expect(pending.any((e) => e.entityType == Supplier.entityTypeName), isTrue);
  });
}
