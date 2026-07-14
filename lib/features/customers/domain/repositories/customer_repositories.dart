import 'package:fashion_pos_enterprise/core/infrastructure/repository/base_local_repository.dart';
import 'package:fashion_pos_enterprise/features/customers/domain/entities/customer.dart';
import 'package:fashion_pos_enterprise/features/customers/domain/entities/customer_activity.dart';
import 'package:fashion_pos_enterprise/features/customers/domain/entities/customer_credit.dart';
import 'package:fashion_pos_enterprise/features/customers/domain/entities/customer_group.dart';
import 'package:fashion_pos_enterprise/features/customers/domain/entities/customer_loyalty_account.dart';
import 'package:fashion_pos_enterprise/features/customers/domain/entities/customer_wallet.dart';
import 'package:fashion_pos_enterprise/features/customers/domain/entities/loyalty_point_transaction.dart';

abstract class CustomerRepository implements IRepository<Customer> {
  Future<Customer?> findByCode(String tenantId, String code);
  Future<Customer?> findByPhone(String tenantId, String phone);
  Future<Customer?> findByMembershipBarcode(String tenantId, String barcode);
}

abstract class CustomerGroupRepository implements IRepository<CustomerGroup> {}

abstract class CustomerLoyaltyAccountRepository implements IRepository<CustomerLoyaltyAccount> {
  Future<CustomerLoyaltyAccount?> findByCustomer(String tenantId, String customerId);
  Future<List<LoyaltyPointTransaction>> listTransactions(String tenantId, String accountId, {int limit = 100});
}

abstract class LoyaltyPointTransactionRepository implements IRepository<LoyaltyPointTransaction> {
  Future<List<LoyaltyPointTransaction>> listByCustomer(String tenantId, String customerId, {int limit = 100});
}

abstract class CustomerWalletRepository implements IRepository<CustomerWallet> {
  Future<CustomerWallet?> findByCustomer(String tenantId, String customerId);
}

abstract class CustomerCreditRepository implements IRepository<CustomerCreditAccount> {
  Future<CustomerCreditAccount?> findByCustomer(String tenantId, String customerId);
}

abstract class CustomerActivityRepository implements IRepository<CustomerActivity> {
  Future<List<CustomerActivity>> listByCustomer(String tenantId, String customerId, {int limit = 100});
}
