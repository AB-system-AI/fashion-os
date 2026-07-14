import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_app_bar.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_scaffold.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/states/app_state_widgets.dart';
import 'package:fashion_pos_enterprise/features/accounting/routing/accounting_route_paths.dart';

class AccountingDashboardPage extends ConsumerWidget {
  const AccountingDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canView = ref.watch(permissionCheckProvider(AccountingPermissions.view));
    if (!canView) {
      return const AppScaffold(body: PermissionDeniedWidget(permission: AccountingPermissions.view));
    }

    final width = MediaQuery.sizeOf(context).width;
    final crossAxisCount = width >= 900 ? 3 : width >= 600 ? 2 : 1;

    final tiles = [
      ('Chart of Accounts', Icons.account_tree_outlined, AccountingRoutePaths.chartOfAccounts),
      ('Journal Entries', Icons.book_outlined, AccountingRoutePaths.journals),
      ('Manual Journal', Icons.edit_note, AccountingRoutePaths.manualJournal),
      ('General Ledger', Icons.list_alt, AccountingRoutePaths.ledger),
      ('Trial Balance', Icons.balance, AccountingRoutePaths.trialBalance),
      ('Balance Sheet', Icons.assessment_outlined, AccountingRoutePaths.balanceSheet),
      ('Income Statement', Icons.trending_up, AccountingRoutePaths.incomeStatement),
      ('Cash Flow', Icons.water_drop_outlined, AccountingRoutePaths.cashFlow),
      ('Cost Centers', Icons.hub_outlined, AccountingRoutePaths.costCenters),
      ('Fiscal Years', Icons.calendar_today_outlined, AccountingRoutePaths.fiscalYears),
      ('Exchange Rates', Icons.currency_exchange, AccountingRoutePaths.exchangeRates),
      ('Banks', Icons.account_balance_outlined, AccountingRoutePaths.banks),
      ('Bank Reconciliation', Icons.fact_check_outlined, AccountingRoutePaths.bankReconciliation),
      ('Taxes', Icons.receipt_long_outlined, AccountingRoutePaths.taxes),
      ('Reports', Icons.summarize_outlined, AccountingRoutePaths.reports),
    ];

    return AppScaffold(
      appBar: const AppAppBar(title: Text('Accounting')),
      body: GridView.builder(
        padding: const EdgeInsets.all(AppSpacing.lg),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: AppSpacing.md,
          crossAxisSpacing: AppSpacing.md,
          childAspectRatio: width >= 600 ? 2.2 : 2.8,
        ),
        itemCount: tiles.length,
        itemBuilder: (context, i) {
          final t = tiles[i];
          return Card(
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => context.push(t.$3),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    Icon(t.$2, size: 32),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(child: Text(t.$1, style: Theme.of(context).textTheme.titleMedium)),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
