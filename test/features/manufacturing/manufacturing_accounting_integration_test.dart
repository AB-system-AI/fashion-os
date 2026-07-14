import 'package:flutter_test/flutter_test.dart';

import 'package:fashion_pos_enterprise/core/business/engines/accounting/accounting_engine.dart';
import 'package:fashion_pos_enterprise/features/accounting/domain/entities/account.dart';
import 'package:fashion_pos_enterprise/features/accounting/domain/enums/accounting_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';

void main() {
  test('materialIssueLines debits WIP and credits inventory', () {
    final engine = AccountingEngine();
    final accounts = _accounts();
    final lines = engine.materialIssueLines(amount: 100, accountsByCode: accounts);
    expect(lines.length, 2);
    expect(lines.first.debit, 100);
    expect(lines.last.credit, 100);
  });

  test('finishedGoodsReceiptLines debits inventory and credits WIP', () {
    final engine = AccountingEngine();
    final accounts = _accounts();
    final lines = engine.finishedGoodsReceiptLines(amount: 250, accountsByCode: accounts);
    expect(lines.first.accountCode, SystemAccounts.inventory);
    expect(lines.last.accountCode, SystemAccounts.wip);
  });
}

Map<String, Account> _accounts() {
  Account a(String code, AccountType type) => Account(
        id: code,
        tenantId: 't1',
        code: code,
        name: code,
        accountType: type,
        normalBalance: type == AccountType.liability || type == AccountType.revenue
            ? AccountNormalBalance.credit
            : AccountNormalBalance.debit,
        version: 1,
        createdAt: DateTime.utc(2025),
        updatedAt: DateTime.utc(2025),
        syncStatus: LocalSyncStatus.synced,
        isDirty: false,
      );
  return {
    SystemAccounts.inventory: a(SystemAccounts.inventory, AccountType.asset),
    SystemAccounts.wip: a(SystemAccounts.wip, AccountType.asset),
    SystemAccounts.manufacturingVariance: a(SystemAccounts.manufacturingVariance, AccountType.expense),
    SystemAccounts.scrapExpense: a(SystemAccounts.scrapExpense, AccountType.expense),
    SystemAccounts.manufacturingOverhead: a(SystemAccounts.manufacturingOverhead, AccountType.expense),
    SystemAccounts.salariesExpense: a(SystemAccounts.salariesExpense, AccountType.expense),
    SystemAccounts.cogs: a(SystemAccounts.cogs, AccountType.cogs),
  };
}
