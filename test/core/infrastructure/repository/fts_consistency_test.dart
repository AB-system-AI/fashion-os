import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/database/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase.inMemory();
    await db.executor.ensureOpen(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('insert updates FTS and search returns new record', () async {
    final now = DateTime.now().toUtc();
    await db.syncableRecordDao.insertRecord(
      SyncableRecordsCompanion.insert(
        id: 'fts-1',
        tenantId: 't1',
        entityType: 'product',
        payload: '{"name":"Silk Scarf"}',
        createdAt: now,
        updatedAt: now,
        searchName: const Value('Silk Scarf'),
        searchSku: const Value('SCF-01'),
      ),
    );

    final hits = await db.syncableRecordDao.searchFts(
      tenantId: 't1',
      entityType: 'product',
      ftsQuery: 'Silk',
      limit: 10,
    );
    expect(hits.map((e) => e.id), contains('fts-1'));
  });

  test('soft delete removes record from FTS search', () async {
    final now = DateTime.now().toUtc();
    await db.syncableRecordDao.insertRecord(
      SyncableRecordsCompanion.insert(
        id: 'fts-2',
        tenantId: 't1',
        entityType: 'product',
        payload: '{"name":"Wool Coat"}',
        createdAt: now,
        updatedAt: now,
        searchName: const Value('Wool Coat'),
      ),
    );

    await db.syncableRecordDao.softDelete('fts-2', now, tenantId: 't1');
    final hits = await db.syncableRecordDao.searchFts(
      tenantId: 't1',
      entityType: 'product',
      ftsQuery: 'Wool',
      limit: 10,
    );
    expect(hits.map((e) => e.id), isNot(contains('fts-2')));
  });
}
