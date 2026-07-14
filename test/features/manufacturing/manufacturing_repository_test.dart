import 'package:flutter_test/flutter_test.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/database/app_database.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/sync/sync_queue_writer.dart';
import 'package:fashion_pos_enterprise/features/manufacturing/data/repositories/manufacturing_repository_impl.dart';
import 'package:fashion_pos_enterprise/features/manufacturing/domain/entities/bom.dart';

void main() {
  late AppDatabase db;
  late BomLocalRepository repository;

  setUp(() async {
    db = AppDatabase.inMemory();
    await db.executor.ensureOpen(db);
    repository = BomLocalRepository(database: db, syncQueue: SyncQueueWriter(db));
  });

  tearDown(() async {
    await db.close();
  });

  test('create BOM persists offline with sync queue', () async {
    final now = DateTime.now().toUtc();
    final created = await repository.create(
      BillOfMaterial(
        id: 'b1',
        tenantId: 't1',
        code: 'BOM-00001',
        name: 'Standard Shirt',
        finishedProductId: 'p1',
        version: 1,
        createdAt: now,
        updatedAt: now,
        syncStatus: LocalSyncStatus.pending,
        isDirty: true,
      ),
    );
    expect(created.code, 'BOM-00001');

    final loaded = await repository.findByCode('t1', 'BOM-00001');
    expect(loaded?.name, 'Standard Shirt');

    final pending = await db.syncQueueDao.getPending();
    expect(pending.any((e) => e.entityType == BillOfMaterial.entityTypeName), isTrue);
  });
}
