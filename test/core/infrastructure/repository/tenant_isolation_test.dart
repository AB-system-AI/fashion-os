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

  test('getById returns null when tenant does not match', () async {
    final now = DateTime.now().toUtc();
    await db.syncableRecordDao.insertRecord(
      SyncableRecordsCompanion.insert(
        id: 'shared-id',
        tenantId: 'tenant-a',
        entityType: 'product',
        payload: '{"name":"A"}',
        createdAt: now,
        updatedAt: now,
        searchName: const Value('A'),
      ),
    );

    final wrongTenant = await db.syncableRecordDao.getById('shared-id', tenantId: 'tenant-b');
    expect(wrongTenant, isNull);

    final correctTenant = await db.syncableRecordDao.getById('shared-id', tenantId: 'tenant-a');
    expect(correctTenant, isNotNull);
  });
}
