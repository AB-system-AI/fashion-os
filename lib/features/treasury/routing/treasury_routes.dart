import 'package:go_router/go_router.dart';

import 'package:fashion_pos_enterprise/features/treasury/presentation/pages/bank_accounts_page.dart';
import 'package:fashion_pos_enterprise/features/treasury/presentation/pages/bank_management_page.dart';
import 'package:fashion_pos_enterprise/features/treasury/presentation/pages/cash_management_page.dart';
import 'package:fashion_pos_enterprise/features/treasury/presentation/pages/cheques_page.dart';
import 'package:fashion_pos_enterprise/features/treasury/presentation/pages/expenses_page.dart';
import 'package:fashion_pos_enterprise/features/treasury/presentation/pages/forecast_page.dart';
import 'package:fashion_pos_enterprise/features/treasury/presentation/pages/payments_page.dart';
import 'package:fashion_pos_enterprise/features/treasury/presentation/pages/receipts_page.dart';
import 'package:fashion_pos_enterprise/features/treasury/presentation/pages/reconciliation_page.dart';
import 'package:fashion_pos_enterprise/features/treasury/presentation/pages/transfers_page.dart';
import 'package:fashion_pos_enterprise/features/treasury/presentation/pages/treasury_dashboard_page.dart';
import 'package:fashion_pos_enterprise/features/treasury/presentation/pages/treasury_reports_page.dart';
import 'package:fashion_pos_enterprise/features/treasury/routing/treasury_route_paths.dart';

List<RouteBase> buildTreasuryRoutes() {
  return [
    GoRoute(
      path: TreasuryRoutePaths.dashboard,
      name: TreasuryRouteNames.dashboard,
      builder: (_, __) => const TreasuryDashboardPage(),
      routes: [
        GoRoute(path: 'cash', name: TreasuryRouteNames.cash, builder: (_, __) => const CashManagementPage()),
        GoRoute(path: 'banks', name: TreasuryRouteNames.banks, builder: (_, __) => const BankManagementPage()),
        GoRoute(path: 'bank-accounts', name: TreasuryRouteNames.bankAccounts, builder: (_, __) => const BankAccountsPage()),
        GoRoute(path: 'transfers', name: TreasuryRouteNames.transfers, builder: (_, __) => const TransfersPage()),
        GoRoute(path: 'payments', name: TreasuryRouteNames.payments, builder: (_, __) => const PaymentsPage()),
        GoRoute(path: 'receipts', name: TreasuryRouteNames.receipts, builder: (_, __) => const ReceiptsPage()),
        GoRoute(path: 'expenses', name: TreasuryRouteNames.expenses, builder: (_, __) => const ExpensesPage()),
        GoRoute(path: 'cheques', name: TreasuryRouteNames.cheques, builder: (_, __) => const ChequesPage()),
        GoRoute(path: 'reconciliation', name: TreasuryRouteNames.reconciliation, builder: (_, __) => const ReconciliationPage()),
        GoRoute(path: 'forecast', name: TreasuryRouteNames.forecast, builder: (_, __) => const ForecastPage()),
        GoRoute(path: 'reports', name: TreasuryRouteNames.reports, builder: (_, __) => const TreasuryReportsPage()),
      ],
    ),
  ];
}
