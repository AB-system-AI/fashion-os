import 'package:flutter_test/flutter_test.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/database/app_database.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/sync/sync_queue_writer.dart';
import 'package:fashion_pos_enterprise/features/accounting/data/repositories/accounting_repository_impl.dart';
import 'package:fashion_pos_enterprise/features/accounting/domain/entities/account.dart';
import 'package:fashion_pos_enterprise/features/accounting/domain/enums/accounting_enums.dart';

void main() {
  late AppDatabase db;
  late AccountLocalRepository repository;

  setUp(() async {
    db = AppDatabase.inMemory();
    await db.executor.ensureOpen(db);
    repository = AccountLocalRepository(database: db, syncQueue: SyncQueueWriter(db));
  });

  tearDown(() async {
    await db.close();
  });

  test('create account persists offline with sync queue', () async {
    final now = DateTime.now().toUtc();
    final created = await repository.create(
      Account(
        id: 'a1',
        tenantId: 't1',
        code: '1000',
        name: 'Cash',
        accountType: AccountType.asset,
        normalBalance: AccountNormalBalance.debit,
        version: 1,
        createdAt: now,
        updatedAt: now,
        syncStatus: LocalSyncStatus.pending,
        isDirty: true,
      ),
    );
    expect(created.code, '1000');

    final loaded = await repository.findByCode('t1', '1000');
    expect(loaded?.name, 'Cash');

    final pending = await db.syncQueueDao.getPending();
    expect(pending.any((e) => e.entityType == Account.entityTypeName), isTrue);
  });
}
