import 'package:fashion_pos_enterprise/features/customers/domain/entities/customer.dart';
import 'package:fashion_pos_enterprise/features/customers/domain/repositories/customer_repositories.dart';

class CustomerStatistics {
  const CustomerStatistics({
    required this.totalOrders,
    required this.totalPurchases,
    required this.loyaltyPoints,
    required this.walletBalance,
    required this.outstandingCredit,
    required this.remainingCredit,
    this.lastPurchaseAt,
  });

  final int totalOrders;
  final double totalPurchases;
  final int loyaltyPoints;
  final double walletBalance;
  final double outstandingCredit;
  final double remainingCredit;
  final DateTime? lastPurchaseAt;
}

class CustomerStatisticsService {
  CustomerStatisticsService({
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

  Future<CustomerStatistics?> forCustomer(String tenantId, String customerId) async {
    final customer = await _customers.getById(customerId, tenantId: tenantId);
    if (customer == null) return null;

    final loyalty = await _loyalty.findByCustomer(tenantId, customerId);
    final wallet = await _wallets.findByCustomer(tenantId, customerId);
    final credit = await _credits.findByCustomer(tenantId, customerId);

    return CustomerStatistics(
      totalOrders: customer.totalOrders,
      totalPurchases: customer.totalPurchases,
      loyaltyPoints: loyalty?.pointsBalance ?? customer.loyaltyPoints,
      walletBalance: wallet?.balance ?? customer.walletBalance,
      outstandingCredit: credit?.outstandingBalance ?? customer.outstandingCredit,
      remainingCredit: credit?.remainingCredit ?? customer.remainingCredit,
      lastPurchaseAt: customer.lastPurchaseAt,
    );
  }
}
