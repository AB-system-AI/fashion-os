import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fashion_pos_enterprise/core/audit/audit_providers.dart';
import 'package:fashion_pos_enterprise/core/business/di/business_providers.dart';
import 'package:fashion_pos_enterprise/core/di/enterprise_providers.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/features/treasury/data/datasources/treasury_remote_datasource.dart';
import 'package:fashion_pos_enterprise/features/treasury/data/repositories/treasury_repository_impl.dart';
import 'package:fashion_pos_enterprise/features/treasury/data/sync/treasury_sync_processor.dart';
import 'package:fashion_pos_enterprise/features/treasury/domain/entities/accounts.dart';
import 'package:fashion_pos_enterprise/features/treasury/domain/entities/cheques.dart';
import 'package:fashion_pos_enterprise/features/treasury/domain/entities/expenses.dart';
import 'package:fashion_pos_enterprise/features/treasury/domain/entities/forecast.dart';
import 'package:fashion_pos_enterprise/features/treasury/domain/entities/movements.dart';
import 'package:fashion_pos_enterprise/features/treasury/domain/entities/vouchers.dart';
import 'package:fashion_pos_enterprise/features/treasury/domain/repositories/treasury_repositories.dart';
import 'package:fashion_pos_enterprise/features/treasury/domain/services/treasury_integration_service.dart';
import 'package:fashion_pos_enterprise/features/treasury/domain/services/treasury_services.dart';

final treasuryRemoteDataSourceProvider = Provider<TreasuryRemoteDataSource>((ref) => TreasuryRemoteDataSource());

final cashBoxRepositoryProvider = Provider<CashBoxRepository>((ref) {
  return CashBoxLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final bankRepositoryProvider = Provider<BankRepository>((ref) {
  return BankLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final bankAccountRepositoryProvider = Provider<BankAccountRepository>((ref) {
  return BankAccountLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final pettyCashRepositoryProvider = Provider<PettyCashRepository>((ref) {
  return PettyCashLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final transferRepositoryProvider = Provider<TransferRepository>((ref) {
  return TransferLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final chequeRepositoryProvider = Provider<ChequeRepository>((ref) {
  return ChequeLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final chequeBookRepositoryProvider = Provider<ChequeBookRepository>((ref) {
  return ChequeBookLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final paymentVoucherRepositoryProvider = Provider<PaymentVoucherRepository>((ref) {
  return PaymentVoucherLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final receiptVoucherRepositoryProvider = Provider<ReceiptVoucherRepository>((ref) {
  return ReceiptVoucherLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final expenseRequestRepositoryProvider = Provider<ExpenseRequestRepository>((ref) {
  return ExpenseRequestLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final expenseApprovalRepositoryProvider = Provider<ExpenseApprovalRepository>((ref) {
  return ExpenseApprovalLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final cashForecastRepositoryProvider = Provider<CashForecastRepository>((ref) {
  return CashForecastLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final bankReconciliationRepositoryProvider = Provider<BankReconciliationRepository>((ref) {
  return BankReconciliationLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final treasurySettingsRepositoryProvider = Provider<TreasurySettingsRepository>((ref) {
  return TreasurySettingsLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final cashMovementRepositoryProvider = Provider<CashMovementRepository>((ref) {
  return CashMovementLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final bankMovementRepositoryProvider = Provider<BankMovementRepository>((ref) {
  return BankMovementLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final cashServiceProvider = Provider<CashService>((ref) => CashService(
      repository: ref.watch(cashBoxRepositoryProvider),
      movements: ref.watch(cashMovementRepositoryProvider),
      engine: ref.watch(treasuryEngineProvider),
      audit: ref.watch(auditServiceProvider),
      permissions: ref.watch(permissionEngineProvider),
    ));

final bankServiceProvider = Provider<BankService>((ref) => BankService(
      banks: ref.watch(bankRepositoryProvider),
      accounts: ref.watch(bankAccountRepositoryProvider),
      movements: ref.watch(bankMovementRepositoryProvider),
      engine: ref.watch(treasuryEngineProvider),
      audit: ref.watch(auditServiceProvider),
      permissions: ref.watch(permissionEngineProvider),
    ));

final transferServiceProvider = Provider<TransferService>((ref) => TransferService(
      repository: ref.watch(transferRepositoryProvider),
      engine: ref.watch(treasuryEngineProvider),
      audit: ref.watch(auditServiceProvider),
      permissions: ref.watch(permissionEngineProvider),
      numberGenerator: ref.watch(numberGeneratorEngineProvider),
    ));

final chequeServiceProvider = Provider<ChequeService>((ref) => ChequeService(
      repository: ref.watch(chequeRepositoryProvider),
      engine: ref.watch(treasuryEngineProvider),
      audit: ref.watch(auditServiceProvider),
      permissions: ref.watch(permissionEngineProvider),
      numberGenerator: ref.watch(numberGeneratorEngineProvider),
    ));

final paymentServiceProvider = Provider<PaymentService>((ref) => PaymentService(
      repository: ref.watch(paymentVoucherRepositoryProvider),
      engine: ref.watch(treasuryEngineProvider),
      audit: ref.watch(auditServiceProvider),
      permissions: ref.watch(permissionEngineProvider),
      numberGenerator: ref.watch(numberGeneratorEngineProvider),
    ));

final receiptServiceProvider = Provider<ReceiptService>((ref) => ReceiptService(
      repository: ref.watch(receiptVoucherRepositoryProvider),
      engine: ref.watch(treasuryEngineProvider),
      audit: ref.watch(auditServiceProvider),
      permissions: ref.watch(permissionEngineProvider),
      numberGenerator: ref.watch(numberGeneratorEngineProvider),
    ));

final expenseServiceProvider = Provider<ExpenseService>((ref) => ExpenseService(
      repository: ref.watch(expenseRequestRepositoryProvider),
      approvals: ref.watch(expenseApprovalRepositoryProvider),
      settings: ref.watch(treasurySettingsRepositoryProvider),
      engine: ref.watch(treasuryEngineProvider),
      audit: ref.watch(auditServiceProvider),
      permissions: ref.watch(permissionEngineProvider),
      numberGenerator: ref.watch(numberGeneratorEngineProvider),
    ));

final reconciliationServiceProvider = Provider<ReconciliationService>((ref) => ReconciliationService(
      repository: ref.watch(bankReconciliationRepositoryProvider),
      accounts: ref.watch(bankAccountRepositoryProvider),
      engine: ref.watch(treasuryEngineProvider),
      audit: ref.watch(auditServiceProvider),
      permissions: ref.watch(permissionEngineProvider),
    ));

final forecastServiceProvider = Provider<ForecastService>((ref) => ForecastService(
      repository: ref.watch(cashForecastRepositoryProvider),
      cashBoxes: ref.watch(cashBoxRepositoryProvider),
      bankAccounts: ref.watch(bankAccountRepositoryProvider),
      pettyCash: ref.watch(pettyCashRepositoryProvider),
      engine: ref.watch(treasuryEngineProvider),
      permissions: ref.watch(permissionEngineProvider),
    ));

final treasuryDashboardServiceProvider = Provider<TreasuryDashboardService>((ref) => TreasuryDashboardService(
      cashBoxes: ref.watch(cashBoxRepositoryProvider),
      bankAccounts: ref.watch(bankAccountRepositoryProvider),
      payments: ref.watch(paymentVoucherRepositoryProvider),
      receipts: ref.watch(receiptVoucherRepositoryProvider),
      cheques: ref.watch(chequeRepositoryProvider),
      engine: ref.watch(treasuryEngineProvider),
      permissions: ref.watch(permissionEngineProvider),
    ));

final treasuryIntegrationServiceProvider = Provider<TreasuryIntegrationService>((ref) => TreasuryIntegrationService(
      eventBus: ref.watch(domainEventBusProvider),
      audit: ref.watch(auditServiceProvider),
    ));

TreasurySyncProcessor _processor(Ref ref, String entityType, String table) => TreasurySyncProcessor(
      remote: ref.watch(treasuryRemoteDataSourceProvider),
      entityTypeName: entityType,
      remoteTable: table,
    );

final cashBoxSyncProcessorProvider = Provider<CashSyncProcessor>((ref) => _processor(ref, CashBox.entityTypeName, 'cash_boxes'));
final bankSyncProcessorProvider = Provider<BankSyncProcessor>((ref) => _processor(ref, Bank.entityTypeName, 'banks'));
final bankAccountSyncProcessorProvider = Provider<BankAccountSyncProcessor>((ref) => _processor(ref, BankAccount.entityTypeName, 'bank_accounts'));
final pettyCashSyncProcessorProvider = Provider<PettyCashSyncProcessor>((ref) => _processor(ref, PettyCash.entityTypeName, 'petty_cash_funds'));
final transferSyncProcessorProvider = Provider<TransferSyncProcessor>((ref) => _processor(ref, Transfer.entityTypeName, 'treasury_transfers'));
final chequeSyncProcessorProvider = Provider<ChequeSyncProcessor>((ref) => _processor(ref, Cheque.entityTypeName, 'cheques'));
final chequeBookSyncProcessorProvider = Provider<ChequeBookSyncProcessor>((ref) => _processor(ref, ChequeBook.entityTypeName, 'cheque_books'));
final paymentVoucherSyncProcessorProvider = Provider<PaymentVoucherSyncProcessor>((ref) => _processor(ref, PaymentVoucher.entityTypeName, 'payment_vouchers'));
final receiptVoucherSyncProcessorProvider = Provider<ReceiptVoucherSyncProcessor>((ref) => _processor(ref, ReceiptVoucher.entityTypeName, 'receipt_vouchers'));
final expenseRequestSyncProcessorProvider = Provider<ExpenseRequestSyncProcessor>((ref) => _processor(ref, ExpenseRequest.entityTypeName, 'expense_requests'));
final cashForecastSyncProcessorProvider = Provider<CashForecastSyncProcessor>((ref) => _processor(ref, CashForecast.entityTypeName, 'cash_forecasts'));
final bankReconciliationSyncProcessorProvider = Provider<BankReconciliationSyncProcessor>((ref) => _processor(ref, BankReconciliation.entityTypeName, 'bank_reconciliations'));
final treasurySettingsSyncProcessorProvider = Provider<TreasurySettingsSyncProcessor>((ref) => _processor(ref, TreasurySettings.entityTypeName, 'treasury_settings'));
