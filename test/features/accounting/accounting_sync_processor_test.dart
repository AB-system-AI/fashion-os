import 'package:flutter_test/flutter_test.dart';

import 'package:fashion_pos_enterprise/features/accounting/data/datasources/accounting_remote_datasource.dart';
import 'package:fashion_pos_enterprise/features/accounting/data/sync/accounting_sync_processor.dart';
import 'package:fashion_pos_enterprise/features/accounting/domain/entities/account.dart';
import 'package:fashion_pos_enterprise/features/accounting/domain/entities/bank_account.dart';
import 'package:fashion_pos_enterprise/features/accounting/domain/entities/currency.dart';
import 'package:fashion_pos_enterprise/features/accounting/domain/entities/fiscal_year.dart';
import 'package:fashion_pos_enterprise/features/accounting/domain/entities/journal_entry.dart';
import 'package:fashion_pos_enterprise/features/accounting/domain/entities/ledger_transaction.dart';

void main() {
  test('accounting sync processors map entity types to remote tables', () {
    final remote = AccountingRemoteDataSource();
    final accounts = AccountingSyncProcessor(
      remote: remote,
      entityTypeName: Account.entityTypeName,
      remoteTable: 'chart_of_accounts',
    );
    final journals = AccountingSyncProcessor(
      remote: remote,
      entityTypeName: JournalEntry.entityTypeName,
      remoteTable: 'journal_entries',
    );
    final ledger = AccountingSyncProcessor(
      remote: remote,
      entityTypeName: LedgerTransaction.entityTypeName,
      remoteTable: 'ledger_transactions',
    );
    final bank = AccountingSyncProcessor(
      remote: remote,
      entityTypeName: BankAccount.entityTypeName,
      remoteTable: 'bank_accounts',
    );
    final rates = AccountingSyncProcessor(
      remote: remote,
      entityTypeName: ExchangeRate.entityTypeName,
      remoteTable: 'exchange_rates',
    );
    final fiscal = AccountingSyncProcessor(
      remote: remote,
      entityTypeName: FiscalYear.entityTypeName,
      remoteTable: 'fiscal_years',
    );

    expect(accounts.entityType, 'chart_of_account');
    expect(journals.entityType, 'journal_entry');
    expect(ledger.entityType, 'ledger_transaction');
    expect(bank.entityType, 'bank_account');
    expect(rates.entityType, 'exchange_rate');
    expect(fiscal.entityType, 'fiscal_year');
  });
}
