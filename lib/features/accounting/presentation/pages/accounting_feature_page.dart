import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/repository/repository_query.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_app_bar.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_scaffold.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/empty/app_empty_state.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/states/app_state_widgets.dart';
import 'package:fashion_pos_enterprise/features/accounting/presentation/providers/accounting_providers.dart';
import 'package:fashion_pos_enterprise/features/auth/presentation/providers/auth_controller.dart';

class AccountingFeaturePage extends ConsumerStatefulWidget {
  const AccountingFeaturePage({
    super.key,
    required this.title,
    required this.description,
    required this.permission,
    this.showTrialBalance = false,
    this.showBalanceSheet = false,
    this.showIncomeStatement = false,
    this.showAccounts = false,
    this.showJournals = false,
  });

  final String title;
  final String description;
  final String permission;
  final bool showTrialBalance;
  final bool showBalanceSheet;
  final bool showIncomeStatement;
  final bool showAccounts;
  final bool showJournals;

  @override
  ConsumerState<AccountingFeaturePage> createState() => _AccountingFeaturePageState();
}

class _AccountingFeaturePageState extends ConsumerState<AccountingFeaturePage> {
  String? _summary;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final user = ref.read(authControllerProvider).user;
    if (user?.tenantId == null) return;
    setState(() => _loading = true);

    if (widget.showTrialBalance) {
      final result = await ref.read(trialBalanceServiceProvider).generate(user: user!, tenantId: user.tenantId!);
      if (mounted && result.isSuccess) {
        final report = result.dataOrNull!;
        setState(() => _summary = 'Trial Balance — Debit: ${report.totalDebit.toStringAsFixed(2)} / Credit: ${report.totalCredit.toStringAsFixed(2)} (${report.isBalanced ? 'Balanced' : 'Out of balance'})');
      }
    } else if (widget.showBalanceSheet) {
      final result = await ref.read(financialReportServiceProvider).balanceSheet(user: user!, tenantId: user.tenantId!);
      if (mounted && result.isSuccess) {
        final r = result.dataOrNull!;
        setState(() => _summary = 'Assets: ${r.totalAssets.toStringAsFixed(2)} | Liab+Equity: ${r.totalLiabilitiesAndEquity.toStringAsFixed(2)}');
      }
    } else if (widget.showIncomeStatement) {
      final result = await ref.read(financialReportServiceProvider).incomeStatement(user: user!, tenantId: user.tenantId!);
      if (mounted && result.isSuccess) {
        setState(() => _summary = 'Net Income: ${result.dataOrNull!.netIncome.toStringAsFixed(2)}');
      }
    } else if (widget.showAccounts) {
      final page = await ref.read(accountingRepositoryProvider).getPage(
            RepositoryQuery(tenantId: user.tenantId!, pageSize: 100),
          );
      if (mounted) setState(() => _summary = '${page.items.length} accounts loaded offline');
    } else if (widget.showJournals) {
      final journals = await ref.read(journalServiceProvider).listPosted(user.tenantId!);
      if (mounted) setState(() => _summary = '${journals.length} posted journal entries');
    }

    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final allowed = ref.watch(permissionCheckProvider(widget.permission));
    if (!allowed) {
      return AppScaffold(body: PermissionDeniedWidget(permission: widget.permission));
    }

    return AppScaffold(
      appBar: AppAppBar(title: Text(widget.title)),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.description, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: AppSpacing.xl),
            if (_loading) const LinearProgressIndicator(),
            if (_summary != null) Text(_summary!, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.lg),
            const AppEmptyState(message: 'Offline-first GL data syncs automatically when online.'),
          ],
        ),
      ),
    );
  }
}
