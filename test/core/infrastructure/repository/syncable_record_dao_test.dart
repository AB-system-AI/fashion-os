import 'package:drift/drift.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/database/app_database.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/repository/repository_query.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase.inMemory();
    await db.executor.ensureOpen(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('syncable record soft delete sets deletedAt', () async {
    final now = DateTime.now().toUtc();
    await db.syncableRecordDao.insertRecord(
      SyncableRecordsCompanion.insert(
        id: 'r1',
        tenantId: 't1',
        entityType: 'product',
        payload: '{"name":"Hat"}',
        createdAt: now,
        updatedAt: now,
        searchName: const Value('Hat'),
      ),
    );

    await db.syncableRecordDao.softDelete('r1', now);
    final record = await db.syncableRecordDao.getById('r1');
    expect(record, isNotNull);
    expect(record!.deletedAt, isNotNull);
  });

  test('pagination query returns page of records', () async {
    final now = DateTime.now().toUtc();
    for (var i = 0; i < 5; i++) {
      await db.syncableRecordDao.insertRecord(
        SyncableRecordsCompanion.insert(
          id: 'r$i',
          tenantId: 't1',
          entityType: 'product',
          payload: '{"name":"Item $i"}',
          createdAt: now,
          updatedAt: now,
          searchName: Value('Item $i'),
        ),
      );
    }

    final page = await db.syncableRecordDao.getPage(
      const RepositoryQuery(tenantId: 't1', entityType: 'product', pageSize: 2),
    );
    expect(page.length, 2);
  });
}
