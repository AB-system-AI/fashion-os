import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/database/app_database.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/sync/remote_sync_record.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/sync/sync_pull_applier.dart';

void main() {
  late AppDatabase db;
  late SyncPullApplier applier;

  setUp(() async {
    db = AppDatabase.inMemory();
    await db.executor.ensureOpen(db);
    applier = SyncPullApplier(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('applyOne upserts remote record for tenant', () async {
    final now = DateTime.now().toUtc();
    final applied = await applier.applyOne(
      tenantId: 't1',
      remote: RemoteSyncRecord(
        id: 'p1',
        tenantId: 't1',
        entityType: 'product',
        payload: {'name': 'Jacket', 'sku': 'J-1'},
        version: 2,
        updatedAt: now,
        searchName: 'Jacket',
        searchSku: 'J-1',
      ),
    );

    expect(applied, isTrue);
    final local = await db.syncableRecordDao.getById('p1', tenantId: 't1');
    expect(local, isNotNull);
    expect(local!.version, 2);
    expect(local.syncStatus, 'synced');
    expect(jsonDecode(local.payload)['name'], 'Jacket');
  });

  test('applyOne skips tenant mismatch', () async {
    final now = DateTime.now().toUtc();
    final applied = await applier.applyOne(
      tenantId: 't1',
      remote: RemoteSyncRecord(
        id: 'p2',
        tenantId: 't-other',
        entityType: 'product',
        payload: {'name': 'Other'},
        version: 1,
        updatedAt: now,
      ),
    );

    expect(applied, isFalse);
    expect(await db.syncableRecordDao.getById('p2', tenantId: 't1'), isNull);
  });

  test('applyOne soft deletes when remote is deleted', () async {
    final now = DateTime.now().toUtc();
    await db.syncableRecordDao.insertRecord(
      SyncableRecordsCompanion.insert(
        id: 'p3',
        tenantId: 't1',
        entityType: 'product',
        payload: '{"name":"Hat"}',
        createdAt: now,
        updatedAt: now,
        searchName: const Value('Hat'),
      ),
    );

    final applied = await applier.applyOne(
      tenantId: 't1',
      remote: RemoteSyncRecord(
        id: 'p3',
        tenantId: 't1',
        entityType: 'product',
        payload: {},
        version: 3,
        updatedAt: now,
        deletedAt: now,
      ),
    );

    expect(applied, isTrue);
    final local = await db.syncableRecordDao.getById('p3', tenantId: 't1');
    expect(local?.deletedAt, isNotNull);
  });
}
