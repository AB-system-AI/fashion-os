import 'package:go_router/go_router.dart';

import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/features/accounting/presentation/pages/accounting_dashboard_page.dart';
import 'package:fashion_pos_enterprise/features/accounting/presentation/pages/accounting_feature_page.dart';
import 'package:fashion_pos_enterprise/features/accounting/routing/accounting_route_paths.dart';

List<RouteBase> buildAccountingRoutes() {
  return [
    GoRoute(
      path: AccountingRoutePaths.dashboard,
      name: AccountingRouteNames.dashboard,
      builder: (_, __) => const AccountingDashboardPage(),
      routes: [
        GoRoute(
          path: 'chart-of-accounts',
          name: AccountingRouteNames.chartOfAccounts,
          builder: (_, __) => const AccountingFeaturePage(
            title: 'Chart of Accounts',
            description: 'Manage GL accounts and groups.',
            permission: AccountingPermissions.manage,
            showAccounts: true,
          ),
        ),
        GoRoute(
          path: 'journals',
          name: AccountingRouteNames.journals,
          builder: (_, __) => const AccountingFeaturePage(
            title: 'Journal Entries',
            description: 'Posted and draft journals.',
            permission: JournalPermissions.create,
            showJournals: true,
          ),
        ),
        GoRoute(
          path: 'journals/new',
          name: AccountingRouteNames.manualJournal,
          builder: (_, __) => const AccountingFeaturePage(
            title: 'Manual Journal',
            description: 'Create balanced manual journal entries.',
            permission: JournalPermissions.create,
          ),
        ),
        GoRoute(
          path: 'ledger',
          name: AccountingRouteNames.ledger,
          builder: (_, __) => const AccountingFeaturePage(
            title: 'General Ledger',
            description: 'Immutable ledger transactions.',
            permission: LedgerPermissions.view,
          ),
        ),
        GoRoute(
          path: 'trial-balance',
          name: AccountingRouteNames.trialBalance,
          builder: (_, __) => const AccountingFeaturePage(
            title: 'Trial Balance',
            description: 'Debit/credit balance verification.',
            permission: FinancialReportPermissions.financial,
            showTrialBalance: true,
          ),
        ),
        GoRoute(
          path: 'balance-sheet',
          name: AccountingRouteNames.balanceSheet,
          builder: (_, __) => const AccountingFeaturePage(
            title: 'Balance Sheet',
            description: 'Assets, liabilities, and equity.',
            permission: FinancialReportPermissions.financial,
            showBalanceSheet: true,
          ),
        ),
        GoRoute(
          path: 'income-statement',
          name: AccountingRouteNames.incomeStatement,
          builder: (_, __) => const AccountingFeaturePage(
            title: 'Income Statement',
            description: 'Revenue, COGS, and expenses.',
            permission: FinancialReportPermissions.financial,
            showIncomeStatement: true,
          ),
        ),
        GoRoute(
          path: 'cash-flow',
          name: AccountingRouteNames.cashFlow,
          builder: (_, __) => const AccountingFeaturePage(
            title: 'Cash Flow',
            description: 'Operating, investing, and financing flows.',
            permission: FinancialReportPermissions.financial,
          ),
        ),
        GoRoute(
          path: 'cost-centers',
          name: AccountingRouteNames.costCenters,
          builder: (_, __) => const AccountingFeaturePage(
            title: 'Cost Centers',
            description: 'Allocate expenses by department or store.',
            permission: AccountingPermissions.manage,
          ),
        ),
        GoRoute(
          path: 'fiscal-years',
          name: AccountingRouteNames.fiscalYears,
          builder: (_, __) => const AccountingFeaturePage(
            title: 'Fiscal Years',
            description: 'Open and close fiscal periods.',
            permission: FiscalPermissions.close,
          ),
        ),
        GoRoute(
          path: 'exchange-rates',
          name: AccountingRouteNames.exchangeRates,
          builder: (_, __) => const AccountingFeaturePage(
            title: 'Exchange Rates',
            description: 'Multi-currency conversion rates.',
            permission: AccountingPermissions.manage,
          ),
        ),
        GoRoute(
          path: 'banks',
          name: AccountingRouteNames.banks,
          builder: (_, __) => const AccountingFeaturePage(
            title: 'Bank Accounts',
            description: 'Bank ledger and transactions.',
            permission: BankPermissions.manage,
          ),
        ),
        GoRoute(
          path: 'bank-reconciliation',
          name: AccountingRouteNames.bankReconciliation,
          builder: (_, __) => const AccountingFeaturePage(
            title: 'Bank Reconciliation',
            description: 'Match statement to book balance.',
            permission: BankPermissions.reconcile,
          ),
        ),
        GoRoute(
          path: 'taxes',
          name: AccountingRouteNames.taxes,
          builder: (_, __) => const AccountingFeaturePage(
            title: 'Tax Codes',
            description: 'VAT and sales tax configuration.',
            permission: FinancialReportPermissions.tax,
          ),
        ),
        GoRoute(
          path: 'reports',
          name: AccountingRouteNames.reports,
          builder: (_, __) => const AccountingFeaturePage(
            title: 'Financial Reports',
            description: 'Export PDF, Excel, and CSV reports.',
            permission: FinancialReportPermissions.financial,
          ),
        ),
      ],
    ),
  ];
}
