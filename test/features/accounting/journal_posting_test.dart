import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:fashion_pos_enterprise/core/audit/audit_action.dart';
import 'package:fashion_pos_enterprise/core/audit/audit_service.dart';
import 'package:fashion_pos_enterprise/core/business/contracts/sequence_store.dart';
import 'package:fashion_pos_enterprise/core/business/engines/accounting/accounting_engine.dart';
import 'package:fashion_pos_enterprise/core/business/engines/number_generator_engine.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/database/app_database.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/repository/repository_query.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/sync/sync_queue_writer.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_engine.dart';
import 'package:fashion_pos_enterprise/features/accounting/data/repositories/accounting_repository_impl.dart';
import 'package:fashion_pos_enterprise/features/accounting/domain/entities/account.dart';
import 'package:fashion_pos_enterprise/features/accounting/domain/entities/journal_entry.dart';
import 'package:fashion_pos_enterprise/features/accounting/domain/entities/journal_line.dart';
import 'package:fashion_pos_enterprise/features/accounting/domain/entities/ledger_transaction.dart';
import 'package:fashion_pos_enterprise/features/accounting/domain/enums/accounting_enums.dart';
import 'package:fashion_pos_enterprise/features/accounting/domain/services/accounting_services.dart';
import 'package:fashion_pos_enterprise/features/auth/domain/entities/auth_user.dart';

class _MockAuditService extends Mock implements AuditService {}

void main() {
  late AppDatabase db;
  late AccountLocalRepository accounts;
  late JournalLocalRepository journals;
  late LedgerLocalRepository ledger;
  late PostingService posting;
  late _MockAuditService audit;

  const user = AuthUser(
    userId: 'u1',
    employeeId: 'e1',
    email: 'a@b.com',
    emailVerified: true,
    tenantId: 't1',
    permissions: {'journal.post'},
  );

  setUp(() async {
    db = AppDatabase.inMemory();
    await db.executor.ensureOpen(db);
    final syncQueue = SyncQueueWriter(db);
    accounts = AccountLocalRepository(database: db, syncQueue: syncQueue);
    journals = JournalLocalRepository(database: db, syncQueue: syncQueue);
    ledger = LedgerLocalRepository(database: db, syncQueue: syncQueue);
    audit = _MockAuditService();
    when(() => audit.log(
          action: any(named: 'action'),
          entityType: any(named: 'entityType'),
          tenantId: any(named: 'tenantId'),
          employeeId: any(named: 'employeeId'),
          entityId: any(named: 'entityId'),
          metadata: any(named: 'metadata'),
        )).thenAnswer((_) async {});

    posting = PostingService(
      journalRepository: journals,
      ledgerRepository: ledger,
      accountingRepository: accounts,
      accountingEngine: AccountingEngine(),
      auditService: audit,
      permissionEngine: const PermissionEngine(),
      numberGenerator: NumberGeneratorEngine(InMemorySequenceStore()),
    );

    final now = DateTime.now().toUtc();
    for (final seed in [
      ('a-cash', '1000', AccountType.asset, AccountNormalBalance.debit),
      ('a-rev', '4000', AccountType.revenue, AccountNormalBalance.credit),
    ]) {
      await accounts.create(
        Account(
          id: seed.$1,
          tenantId: 't1',
          code: seed.$2,
          name: seed.$2,
          accountType: seed.$3,
          normalBalance: seed.$4,
          version: 1,
          createdAt: now,
          updatedAt: now,
          syncStatus: LocalSyncStatus.pending,
          isDirty: true,
        ),
      );
    }
  });

  tearDown(() async {
    await db.close();
  });

  test('postJournal creates ledger transactions and updates balances', () async {
    final now = DateTime.now().toUtc();
    final draft = JournalEntry(
      id: 'j1',
      tenantId: 't1',
      entryNumber: '',
      entryDate: now,
      lines: const [
        JournalLine(id: 'l1', accountId: 'a-cash', accountCode: '1000', debit: 100),
        JournalLine(id: 'l2', accountId: 'a-rev', accountCode: '4000', credit: 100),
      ],
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    );

    final result = await posting.postJournal(user: user, draft: draft);
    expect(result.isSuccess, isTrue);

    final cash = await accounts.getById('a-cash', tenantId: 't1');
    expect(cash?.balance, 100);

    final txs = await ledger.getPage(
      RepositoryQuery(tenantId: 't1', entityType: LedgerTransaction.entityTypeName, pageSize: 10),
    );
    expect(txs.items.length, 2);

    final pending = await db.syncQueueDao.getPending();
    expect(pending.any((e) => e.entityType == JournalEntry.entityTypeName), isTrue);
    expect(pending.any((e) => e.entityType == LedgerTransaction.entityTypeName), isTrue);

    verify(() => audit.log(
          action: AuditAction.create,
          entityType: JournalEntry.entityTypeName,
          tenantId: 't1',
          employeeId: user.employeeId,
          entityId: any(named: 'entityId'),
          metadata: any(named: 'metadata'),
        )).called(1);
  });
}
