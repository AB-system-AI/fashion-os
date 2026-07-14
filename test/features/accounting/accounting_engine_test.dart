import 'package:flutter_test/flutter_test.dart';

import 'package:fashion_pos_enterprise/core/business/engines/accounting/accounting_engine.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/features/accounting/domain/entities/account.dart';
import 'package:fashion_pos_enterprise/features/accounting/domain/entities/journal_entry.dart';
import 'package:fashion_pos_enterprise/features/accounting/domain/entities/journal_line.dart';
import 'package:fashion_pos_enterprise/features/accounting/domain/enums/accounting_enums.dart';

void main() {
  late AccountingEngine engine;

  setUp(() {
    engine = AccountingEngine();
  });

  test('validateJournalLines rejects unbalanced entry', () {
    final result = engine.validateJournalLines([
      const JournalLine(id: '1', accountId: 'a1', accountCode: '1000', debit: 100),
      const JournalLine(id: '2', accountId: 'a2', accountCode: '4000', credit: 50),
    ]);
    expect(result.isFailure, isTrue);
  });

  test('validateJournalLines accepts balanced entry', () {
    final result = engine.validateJournalLines([
      const JournalLine(id: '1', accountId: 'a1', accountCode: '1000', debit: 100),
      const JournalLine(id: '2', accountId: 'a2', accountCode: '4000', credit: 100),
    ]);
    expect(result.isSuccess, isTrue);
  });

  test('buildTrialBalance totals debits and credits', () {
    final accounts = [
      Account(
        id: 'a1',
        tenantId: 't1',
        code: '1000',
        name: 'Cash',
        accountType: AccountType.asset,
        normalBalance: AccountNormalBalance.debit,
        version: 1,
        createdAt: DateTime.utc(2025),
        updatedAt: DateTime.utc(2025),
        syncStatus: LocalSyncStatus.synced,
        isDirty: false,
      ),
    ];
    final txs = engine.buildLedgerTransactions(
      entry: JournalEntry(
        id: 'j1',
        tenantId: 't1',
        entryNumber: 'JE-1',
        entryDate: DateTime.utc(2025),
        lines: const [
          JournalLine(id: 'l1', accountId: 'a1', accountCode: '1000', debit: 50),
          JournalLine(id: 'l2', accountId: 'a2', accountCode: '4000', credit: 50),
        ],
        version: 1,
        createdAt: DateTime.utc(2025),
        updatedAt: DateTime.utc(2025),
        syncStatus: LocalSyncStatus.synced,
        isDirty: false,
      ),
      accounts: {'a1': accounts.first},
    );
    final report = engine.buildTrialBalance(accounts, txs);
    expect(report.totalDebit, 50);
    expect(report.isBalanced, isFalse);
  });

  test('saleJournalLines balances debits and credits', () {
    final map = {
      SystemAccounts.cash: Account(
        id: '1',
        tenantId: 't1',
        code: SystemAccounts.cash,
        name: 'Cash',
        accountType: AccountType.asset,
        normalBalance: AccountNormalBalance.debit,
        version: 1,
        createdAt: DateTime.utc(2025),
        updatedAt: DateTime.utc(2025),
        syncStatus: LocalSyncStatus.synced,
        isDirty: false,
      ),
      SystemAccounts.salesRevenue: Account(
        id: '2',
        tenantId: 't1',
        code: SystemAccounts.salesRevenue,
        name: 'Revenue',
        accountType: AccountType.revenue,
        normalBalance: AccountNormalBalance.credit,
        version: 1,
        createdAt: DateTime.utc(2025),
        updatedAt: DateTime.utc(2025),
        syncStatus: LocalSyncStatus.synced,
        isDirty: false,
      ),
      SystemAccounts.taxPayable: Account(
        id: '3',
        tenantId: 't1',
        code: SystemAccounts.taxPayable,
        name: 'Tax',
        accountType: AccountType.liability,
        normalBalance: AccountNormalBalance.credit,
        version: 1,
        createdAt: DateTime.utc(2025),
        updatedAt: DateTime.utc(2025),
        syncStatus: LocalSyncStatus.synced,
        isDirty: false,
      ),
    };
    final lines = engine.saleJournalLines(grandTotal: 115, taxTotal: 15, accountsByCode: map);
    final validation = engine.validateJournalLines(lines);
    expect(validation.isSuccess, isTrue);
  });

  test('buildBalanceSheet aggregates account types', () {
    final accounts = [
      Account(
        id: 'a1',
        tenantId: 't1',
        code: '1000',
        name: 'Cash',
        accountType: AccountType.asset,
        normalBalance: AccountNormalBalance.debit,
        balance: 100,
        version: 1,
        createdAt: DateTime.utc(2025),
        updatedAt: DateTime.utc(2025),
        syncStatus: LocalSyncStatus.synced,
        isDirty: false,
      ),
      Account(
        id: 'a2',
        tenantId: 't1',
        code: '2000',
        name: 'AP',
        accountType: AccountType.liability,
        normalBalance: AccountNormalBalance.credit,
        balance: 40,
        version: 1,
        createdAt: DateTime.utc(2025),
        updatedAt: DateTime.utc(2025),
        syncStatus: LocalSyncStatus.synced,
        isDirty: false,
      ),
    ];
    final report = engine.buildBalanceSheet(accounts);
    expect(report.totalAssets, 100);
    expect(report.totalLiabilitiesAndEquity, 40);
  });

  test('buildIncomeStatement computes net income', () {
    final accounts = [
      Account(
        id: 'r1',
        tenantId: 't1',
        code: '4000',
        name: 'Revenue',
        accountType: AccountType.revenue,
        normalBalance: AccountNormalBalance.credit,
        balance: 1000,
        version: 1,
        createdAt: DateTime.utc(2025),
        updatedAt: DateTime.utc(2025),
        syncStatus: LocalSyncStatus.synced,
        isDirty: false,
      ),
      Account(
        id: 'c1',
        tenantId: 't1',
        code: '5000',
        name: 'COGS',
        accountType: AccountType.cogs,
        normalBalance: AccountNormalBalance.debit,
        balance: 400,
        version: 1,
        createdAt: DateTime.utc(2025),
        updatedAt: DateTime.utc(2025),
        syncStatus: LocalSyncStatus.synced,
        isDirty: false,
      ),
    ];
    final report = engine.buildIncomeStatement(accounts);
    expect(report.netIncome, 600);
  });
}
