import 'package:fashion_pos_enterprise/core/infrastructure/repository/repository_query.dart';
import 'package:fashion_pos_enterprise/features/customers/domain/entities/customer.dart';
import 'package:fashion_pos_enterprise/features/customers/domain/repositories/customer_repositories.dart';

class CustomerValueSummary {
  const CustomerValueSummary({
    required this.customer,
    required this.lifetimeValue,
    required this.orderCount,
  });

  final Customer customer;
  final double lifetimeValue;
  final int orderCount;
}

class CustomerAnalyticsService {
  CustomerAnalyticsService({
    required CustomerRepository customerRepository,
    required CustomerLoyaltyAccountRepository loyaltyRepository,
    required CustomerWalletRepository walletRepository,
    required CustomerCreditRepository creditRepository,
  })  : _customers = customerRepository,
        _loyalty = loyaltyRepository,
        _wallets = walletRepository,
        _credits = creditRepository;

  final CustomerRepository _customers;
  final CustomerLoyaltyAccountRepository _loyalty;
  final CustomerWalletRepository _wallets;
  final CustomerCreditRepository _credits;

  Future<List<CustomerValueSummary>> topCustomers(String tenantId, {int limit = 10}) async {
    final page = await _customers.getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    final summaries = page.items
        .map(
          (c) => CustomerValueSummary(
            customer: c,
            lifetimeValue: c.totalPurchases,
            orderCount: c.totalOrders,
          ),
        )
        .toList()
      ..sort((a, b) => b.lifetimeValue.compareTo(a.lifetimeValue));
    return summaries.take(limit).toList();
  }

  Future<List<Customer>> inactiveCustomers(String tenantId, {Duration inactiveFor = const Duration(days: 90)}) async {
    final cutoff = DateTime.now().toUtc().subtract(inactiveFor);
    final page = await _customers.getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    return page.items.where((c) {
      if (!c.active) return false;
      if (c.lastPurchaseAt == null) return true;
      return c.lastPurchaseAt!.isBefore(cutoff);
    }).toList();
  }

  Future<List<Customer>> birthdayCustomers(String tenantId) async {
    final now = DateTime.now().toUtc();
    final page = await _customers.getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    return page.items.where((c) {
      final dob = c.birthDate;
      return dob != null && dob.month == now.month && dob.day == now.day && c.active;
    }).toList();
  }

  Future<double> totalWalletBalances(String tenantId) async {
    final page = await _customers.getPage(RepositoryQuery(tenantId: tenantId, pageSize: 1000));
    return page.items.fold<double>(0, (sum, c) => sum + c.walletBalance);
  }

  Future<double> totalOutstandingCredit(String tenantId) async {
    final page = await _customers.getPage(RepositoryQuery(tenantId: tenantId, pageSize: 1000));
    return page.items.fold<double>(0, (sum, c) => sum + c.outstandingCredit);
  }

  Future<int> totalLoyaltyPoints(String tenantId) async {
    final page = await _customers.getPage(RepositoryQuery(tenantId: tenantId, pageSize: 1000));
    return page.items.fold<int>(0, (sum, c) => sum + c.loyaltyPoints);
  }
}
