import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fashion_pos_enterprise/core/audit/audit_providers.dart';
import 'package:fashion_pos_enterprise/core/business/di/business_providers.dart';
import 'package:fashion_pos_enterprise/core/di/enterprise_providers.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/features/accounting/data/datasources/accounting_remote_datasource.dart';
import 'package:fashion_pos_enterprise/features/accounting/data/repositories/accounting_repository_impl.dart';
import 'package:fashion_pos_enterprise/features/accounting/data/sync/accounting_sync_processor.dart';
import 'package:fashion_pos_enterprise/features/accounting/domain/entities/account.dart';
import 'package:fashion_pos_enterprise/features/accounting/domain/entities/bank_account.dart';
import 'package:fashion_pos_enterprise/features/accounting/domain/entities/currency.dart';
import 'package:fashion_pos_enterprise/features/accounting/domain/entities/fiscal_year.dart';
import 'package:fashion_pos_enterprise/features/accounting/domain/entities/journal_entry.dart';
import 'package:fashion_pos_enterprise/features/accounting/domain/entities/ledger_transaction.dart';
import 'package:fashion_pos_enterprise/features/accounting/domain/repositories/accounting_repositories.dart';
import 'package:fashion_pos_enterprise/features/accounting/domain/services/accounting_integration_service.dart';
import 'package:fashion_pos_enterprise/features/accounting/domain/services/accounting_services.dart';

final accountingRemoteDataSourceProvider = Provider<AccountingRemoteDataSource>((ref) {
  return AccountingRemoteDataSource();
});

final accountingRepositoryProvider = Provider<AccountingRepository>((ref) {
  return AccountLocalRepository(
    database: ref.watch(appDatabaseProvider),
    syncQueue: ref.watch(syncQueueWriterProvider),
  );
});

final journalRepositoryProvider = Provider<JournalRepository>((ref) {
  return JournalLocalRepository(
    database: ref.watch(appDatabaseProvider),
    syncQueue: ref.watch(syncQueueWriterProvider),
  );
});

final ledgerRepositoryProvider = Provider<LedgerRepository>((ref) {
  return LedgerLocalRepository(
    database: ref.watch(appDatabaseProvider),
    syncQueue: ref.watch(syncQueueWriterProvider),
  );
});

final bankRepositoryProvider = Provider<BankRepository>((ref) {
  return BankLocalRepository(
    database: ref.watch(appDatabaseProvider),
    syncQueue: ref.watch(syncQueueWriterProvider),
  );
});

final currencyRepositoryProvider = Provider<CurrencyRepository>((ref) {
  return CurrencyLocalRepository(
    database: ref.watch(appDatabaseProvider),
    syncQueue: ref.watch(syncQueueWriterProvider),
  );
});

final postingServiceProvider = Provider<PostingService>((ref) {
  return PostingService(
    journalRepository: ref.watch(journalRepositoryProvider),
    ledgerRepository: ref.watch(ledgerRepositoryProvider),
    accountingRepository: ref.watch(accountingRepositoryProvider),
    accountingEngine: ref.watch(accountingEngineProvider),
    auditService: ref.watch(auditServiceProvider),
    permissionEngine: ref.watch(permissionEngineProvider),
    numberGenerator: ref.watch(numberGeneratorEngineProvider),
  );
});

final journalServiceProvider = Provider<JournalService>((ref) {
  return JournalService(
    repository: ref.watch(journalRepositoryProvider),
    engine: ref.watch(accountingEngineProvider),
    audit: ref.watch(auditServiceProvider),
    permissions: ref.watch(permissionEngineProvider),
  );
});

final ledgerServiceProvider = Provider<LedgerService>((ref) {
  return LedgerService(
    repository: ref.watch(ledgerRepositoryProvider),
    permissions: ref.watch(permissionEngineProvider),
  );
});

final trialBalanceServiceProvider = Provider<TrialBalanceService>((ref) {
  return TrialBalanceService(
    accounts: ref.watch(accountingRepositoryProvider),
    ledger: ref.watch(ledgerRepositoryProvider),
    engine: ref.watch(accountingEngineProvider),
    permissions: ref.watch(permissionEngineProvider),
  );
});

final financialReportServiceProvider = Provider<FinancialReportService>((ref) {
  return FinancialReportService(
    accounts: ref.watch(accountingRepositoryProvider),
    engine: ref.watch(accountingEngineProvider),
    permissions: ref.watch(permissionEngineProvider),
  );
});

final closingServiceProvider = Provider<ClosingService>((ref) {
  return ClosingService(
    currencyRepository: ref.watch(currencyRepositoryProvider),
    engine: ref.watch(accountingEngineProvider),
    audit: ref.watch(auditServiceProvider),
    permissions: ref.watch(permissionEngineProvider),
  );
});

final fiscalYearServiceProvider = Provider<FiscalYearService>((ref) {
  return FiscalYearService(repository: ref.watch(currencyRepositoryProvider));
});

final exchangeRateServiceProvider = Provider<ExchangeRateService>((ref) {
  return ExchangeRateService(
    repository: ref.watch(currencyRepositoryProvider),
    engine: ref.watch(accountingEngineProvider),
  );
});

final bankServiceProvider = Provider<BankService>((ref) {
  return BankService(
    repository: ref.watch(bankRepositoryProvider),
    audit: ref.watch(auditServiceProvider),
    permissions: ref.watch(permissionEngineProvider),
  );
});

final reconciliationServiceProvider = Provider<ReconciliationService>((ref) {
  return ReconciliationService(
    repository: ref.watch(bankRepositoryProvider),
    engine: ref.watch(accountingEngineProvider),
    audit: ref.watch(auditServiceProvider),
    permissions: ref.watch(permissionEngineProvider),
  );
});

final paymentTermServiceProvider = Provider<PaymentTermService>((ref) {
  return PaymentTermService(repository: ref.watch(currencyRepositoryProvider));
});

import 'package:fashion_pos_enterprise/features/manufacturing/presentation/providers/manufacturing_providers.dart';
import 'package:fashion_pos_enterprise/features/products/presentation/providers/product_providers.dart';

final accountingIntegrationServiceProvider = Provider<AccountingIntegrationService>((ref) {
  return AccountingIntegrationService(
    eventBus: ref.watch(domainEventBusProvider),
    postingService: ref.watch(postingServiceProvider),
    accountingRepository: ref.watch(accountingRepositoryProvider),
    accountingEngine: ref.watch(accountingEngineProvider),
    productionRepository: ref.watch(productionRepositoryProvider),
    productRepository: ref.watch(productRepositoryProvider),
  );
});

AccountingSyncProcessor _processor(Ref ref, String entityType, String table) => AccountingSyncProcessor(
      remote: ref.watch(accountingRemoteDataSourceProvider),
      entityTypeName: entityType,
      remoteTable: table,
    );

final accountingSyncProcessorProvider = Provider<AccountingSyncProcessor>(
  (ref) => _processor(ref, Account.entityTypeName, 'chart_of_accounts'),
);

final journalSyncProcessorProvider = Provider<JournalSyncProcessor>(
  (ref) => _processor(ref, JournalEntry.entityTypeName, 'journal_entries'),
);

final ledgerSyncProcessorProvider = Provider<LedgerSyncProcessor>(
  (ref) => _processor(ref, LedgerTransaction.entityTypeName, 'ledger_transactions'),
);

final bankSyncProcessorProvider = Provider<BankSyncProcessor>(
  (ref) => _processor(ref, BankAccount.entityTypeName, 'bank_accounts'),
);

final exchangeRateSyncProcessorProvider = Provider<ExchangeRateSyncProcessor>(
  (ref) => _processor(ref, ExchangeRate.entityTypeName, 'exchange_rates'),
);

final fiscalYearSyncProcessorProvider = Provider<AccountingSyncProcessor>(
  (ref) => _processor(ref, FiscalYear.entityTypeName, 'fiscal_years'),
);
