import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fashion_pos_enterprise/core/audit/audit_providers.dart';
import 'package:fashion_pos_enterprise/core/business/di/business_providers.dart';
import 'package:fashion_pos_enterprise/core/di/enterprise_providers.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/features/customers/data/datasources/customer_remote_datasource.dart';
import 'package:fashion_pos_enterprise/features/customers/data/repositories/customer_repository_impl.dart';
import 'package:fashion_pos_enterprise/features/customers/data/sync/customer_sync_processor.dart';
import 'package:fashion_pos_enterprise/features/customers/domain/entities/customer.dart';
import 'package:fashion_pos_enterprise/features/customers/domain/entities/customer_activity.dart';
import 'package:fashion_pos_enterprise/features/customers/domain/entities/customer_credit.dart';
import 'package:fashion_pos_enterprise/features/customers/domain/entities/customer_group.dart';
import 'package:fashion_pos_enterprise/features/customers/domain/entities/customer_loyalty_account.dart';
import 'package:fashion_pos_enterprise/features/customers/domain/entities/customer_wallet.dart';
import 'package:fashion_pos_enterprise/features/customers/domain/entities/loyalty_point_transaction.dart';
import 'package:fashion_pos_enterprise/features/customers/domain/repositories/customer_repositories.dart';
import 'package:fashion_pos_enterprise/features/customers/domain/services/customer_analytics_service.dart';
import 'package:fashion_pos_enterprise/features/customers/domain/services/customer_credit_service.dart';
import 'package:fashion_pos_enterprise/features/customers/domain/services/customer_group_service.dart';
import 'package:fashion_pos_enterprise/features/customers/domain/services/customer_history_service.dart';
import 'package:fashion_pos_enterprise/features/customers/domain/services/customer_lookup_service.dart';
import 'package:fashion_pos_enterprise/features/customers/domain/services/customer_service.dart';
import 'package:fashion_pos_enterprise/features/customers/domain/services/customer_statistics_service.dart';
import 'package:fashion_pos_enterprise/features/customers/domain/services/loyalty_service.dart';
import 'package:fashion_pos_enterprise/features/customers/domain/services/wallet_service.dart';

final customerRemoteDataSourceProvider = Provider<CustomerRemoteDataSource>((ref) => CustomerRemoteDataSource());

final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  return CustomerLocalRepository(
    database: ref.watch(appDatabaseProvider),
    syncQueue: ref.watch(syncQueueWriterProvider),
  );
});

final customerGroupRepositoryProvider = Provider<CustomerGroupRepository>((ref) {
  return CustomerGroupRepositoryImpl(
    database: ref.watch(appDatabaseProvider),
    syncQueue: ref.watch(syncQueueWriterProvider),
  );
});

final customerLoyaltyAccountRepositoryProvider = Provider<CustomerLoyaltyAccountRepository>((ref) {
  return CustomerLoyaltyAccountRepositoryImpl(
    database: ref.watch(appDatabaseProvider),
    syncQueue: ref.watch(syncQueueWriterProvider),
  );
});

final loyaltyPointTransactionRepositoryProvider = Provider<LoyaltyPointTransactionRepository>((ref) {
  return LoyaltyPointTransactionRepositoryImpl(
    database: ref.watch(appDatabaseProvider),
    syncQueue: ref.watch(syncQueueWriterProvider),
  );
});

final customerWalletRepositoryProvider = Provider<CustomerWalletRepository>((ref) {
  return CustomerWalletRepositoryImpl(
    database: ref.watch(appDatabaseProvider),
    syncQueue: ref.watch(syncQueueWriterProvider),
  );
});

final customerCreditRepositoryProvider = Provider<CustomerCreditRepository>((ref) {
  return CustomerCreditRepositoryImpl(
    database: ref.watch(appDatabaseProvider),
    syncQueue: ref.watch(syncQueueWriterProvider),
  );
});

final customerActivityRepositoryProvider = Provider<CustomerActivityRepository>((ref) {
  return CustomerActivityRepositoryImpl(
    database: ref.watch(appDatabaseProvider),
    syncQueue: ref.watch(syncQueueWriterProvider),
  );
});

final customerServiceProvider = Provider<CustomerService>((ref) {
  return CustomerService(
    repository: ref.watch(customerRepositoryProvider),
    auditService: ref.watch(auditServiceProvider),
    permissionEngine: ref.watch(permissionEngineProvider),
    numberGenerator: ref.watch(numberGeneratorEngineProvider),
    barcodeEngine: ref.watch(barcodeEngineProvider),
    eventBus: ref.watch(domainEventBusProvider),
  );
});

final customerGroupServiceProvider = Provider<CustomerGroupService>((ref) {
  return CustomerGroupService(
    repository: ref.watch(customerGroupRepositoryProvider),
    auditService: ref.watch(auditServiceProvider),
    permissionEngine: ref.watch(permissionEngineProvider),
  );
});

final loyaltyServiceProvider = Provider<LoyaltyService>((ref) {
  return LoyaltyService(
    customerRepository: ref.watch(customerRepositoryProvider),
    accountRepository: ref.watch(customerLoyaltyAccountRepositoryProvider),
    transactionRepository: ref.watch(loyaltyPointTransactionRepositoryProvider),
    loyaltyEngine: ref.watch(loyaltyEngineProvider),
    auditService: ref.watch(auditServiceProvider),
    permissionEngine: ref.watch(permissionEngineProvider),
  );
});

final walletServiceProvider = Provider<WalletService>((ref) {
  return WalletService(
    customerRepository: ref.watch(customerRepositoryProvider),
    walletRepository: ref.watch(customerWalletRepositoryProvider),
    auditService: ref.watch(auditServiceProvider),
    permissionEngine: ref.watch(permissionEngineProvider),
  );
});

final customerCreditServiceProvider = Provider<CustomerCreditService>((ref) {
  return CustomerCreditService(
    customerRepository: ref.watch(customerRepositoryProvider),
    creditRepository: ref.watch(customerCreditRepositoryProvider),
    auditService: ref.watch(auditServiceProvider),
    permissionEngine: ref.watch(permissionEngineProvider),
  );
});

final customerStatisticsServiceProvider = Provider<CustomerStatisticsService>((ref) {
  return CustomerStatisticsService(
    customerRepository: ref.watch(customerRepositoryProvider),
    loyaltyRepository: ref.watch(customerLoyaltyAccountRepositoryProvider),
    walletRepository: ref.watch(customerWalletRepositoryProvider),
    creditRepository: ref.watch(customerCreditRepositoryProvider),
  );
});

final customerHistoryServiceProvider = Provider<CustomerHistoryService>((ref) {
  return CustomerHistoryService(
    activityRepository: ref.watch(customerActivityRepositoryProvider),
    auditService: ref.watch(auditServiceProvider),
    permissionEngine: ref.watch(permissionEngineProvider),
  );
});

final customerAnalyticsServiceProvider = Provider<CustomerAnalyticsService>((ref) {
  return CustomerAnalyticsService(
    customerRepository: ref.watch(customerRepositoryProvider),
    loyaltyRepository: ref.watch(customerLoyaltyAccountRepositoryProvider),
    walletRepository: ref.watch(customerWalletRepositoryProvider),
    creditRepository: ref.watch(customerCreditRepositoryProvider),
  );
});

final customerLookupServiceProvider = Provider<CustomerLookupService>((ref) {
  return CustomerLookupService(
    customerRepository: ref.watch(customerRepositoryProvider),
    permissionEngine: ref.watch(permissionEngineProvider),
  );
});

CustomerSyncProcessor _processor(Ref ref, String entityType, String table) {
  return CustomerSyncProcessor(
    remote: ref.watch(customerRemoteDataSourceProvider),
    entityTypeName: entityType,
    remoteTable: table,
  );
}

final customerSyncProcessorProvider = Provider((ref) => _processor(ref, Customer.entityTypeName, 'customers'));
final customerGroupSyncProcessorProvider =
    Provider((ref) => _processor(ref, CustomerGroup.entityTypeName, 'customer_groups'));
final customerLoyaltyAccountSyncProcessorProvider = Provider(
  (ref) => _processor(ref, CustomerLoyaltyAccount.entityTypeName, 'customer_loyalty_accounts'),
);
final loyaltyPointTransactionSyncProcessorProvider = Provider(
  (ref) => _processor(ref, LoyaltyPointTransaction.entityTypeName, 'loyalty_point_transactions'),
);
final customerWalletSyncProcessorProvider =
    Provider((ref) => _processor(ref, CustomerWallet.entityTypeName, 'customer_wallets'));
final customerCreditSyncProcessorProvider =
    Provider((ref) => _processor(ref, CustomerCreditAccount.entityTypeName, 'customer_credit_accounts'));
final customerActivitySyncProcessorProvider =
    Provider((ref) => _processor(ref, CustomerActivity.entityTypeName, 'customer_activities'));
