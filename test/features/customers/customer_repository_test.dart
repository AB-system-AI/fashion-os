import 'package:flutter_test/flutter_test.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/database/app_database.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/sync/sync_queue_writer.dart';
import 'package:fashion_pos_enterprise/features/customers/data/repositories/customer_repository_impl.dart';
import 'package:fashion_pos_enterprise/features/customers/domain/entities/customer.dart';

void main() {
  late AppDatabase db;
  late CustomerLocalRepository repository;

  setUp(() async {
    db = AppDatabase.inMemory();
    await db.executor.ensureOpen(db);
    repository = CustomerLocalRepository(database: db, syncQueue: SyncQueueWriter(db));
  });

  tearDown(() async {
    await db.close();
  });

  test('create customer persists offline with sync queue', () async {
    final now = DateTime.now().toUtc();
    final created = await repository.create(
      Customer(
        id: 'c1',
        tenantId: 't1',
        customerCode: 'CUS-00001',
        firstName: 'Jane',
        lastName: 'Doe',
        version: 1,
        createdAt: now,
        updatedAt: now,
        syncStatus: LocalSyncStatus.pending,
        isDirty: true,
      ),
    );
    expect(created.fullName, 'Jane Doe');

    final loaded = await repository.getById('c1', tenantId: 't1');
    expect(loaded?.customerCode, 'CUS-00001');

    final pending = await db.syncQueueDao.getPending();
    expect(pending.any((e) => e.entityType == Customer.entityTypeName), isTrue);
  });
}
