import 'package:go_router/go_router.dart';

import 'package:fashion_pos_enterprise/features/customers/presentation/pages/credit_page.dart';
import 'package:fashion_pos_enterprise/features/customers/presentation/pages/crm_dashboard_page.dart';
import 'package:fashion_pos_enterprise/features/customers/presentation/pages/customer_detail_page.dart';
import 'package:fashion_pos_enterprise/features/customers/presentation/pages/customer_form_page.dart';
import 'package:fashion_pos_enterprise/features/customers/presentation/pages/customer_list_page.dart';
import 'package:fashion_pos_enterprise/features/customers/presentation/pages/customer_reports_page.dart';
import 'package:fashion_pos_enterprise/features/customers/presentation/pages/loyalty_page.dart';
import 'package:fashion_pos_enterprise/features/customers/presentation/pages/wallet_page.dart';
import 'package:fashion_pos_enterprise/features/customers/routing/customer_route_paths.dart';

List<RouteBase> buildCustomerRoutes() {
  return [
    GoRoute(
      path: CustomerRoutePaths.dashboard,
      name: CustomerRouteNames.dashboard,
      builder: (context, state) => const CrmDashboardPage(),
      routes: [
        GoRoute(path: 'list', name: CustomerRouteNames.list, builder: (_, __) => const CustomerListPage()),
        GoRoute(path: 'new', name: CustomerRouteNames.create, builder: (_, __) => const CustomerFormPage()),
        GoRoute(path: 'loyalty', name: CustomerRouteNames.loyalty, builder: (_, __) => const LoyaltyPage()),
        GoRoute(path: 'wallet', name: CustomerRouteNames.wallet, builder: (_, __) => const WalletPage()),
        GoRoute(path: 'credit', name: CustomerRouteNames.credit, builder: (_, __) => const CreditPage()),
        GoRoute(path: 'reports', name: CustomerRouteNames.reports, builder: (_, __) => const CustomerReportsPage()),
      ],
    ),
    GoRoute(
      path: '/customers/:id',
      name: CustomerRouteNames.detail,
      builder: (context, state) => CustomerDetailPage(customerId: state.pathParameters['id']!),
    ),
  ];
}
