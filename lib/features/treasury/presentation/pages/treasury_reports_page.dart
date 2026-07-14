import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_app_bar.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_scaffold.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/states/app_state_widgets.dart';
import 'package:fashion_pos_enterprise/features/auth/presentation/providers/auth_controller.dart';
import 'package:fashion_pos_enterprise/features/treasury/domain/value_objects/treasury_value_objects.dart';
import 'package:fashion_pos_enterprise/features/treasury/presentation/providers/treasury_providers.dart';

class TreasuryReportsPage extends ConsumerStatefulWidget {
  const TreasuryReportsPage({super.key});

  @override
  ConsumerState<TreasuryReportsPage> createState() => _TreasuryReportsPageState();
}

class _TreasuryReportsPageState extends ConsumerState<TreasuryReportsPage> {
  TreasuryKpis? _kpis;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  Future<void> _load() async {
    final user = ref.read(authControllerProvider).user;
    if (user?.tenantId == null) return;
    setState(() => _loading = true);
    final kpis = await ref.read(treasuryDashboardServiceProvider).kpis(user!.tenantId!);
    if (!mounted) return;
    setState(() {
      _kpis = kpis;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final allowed = ref.watch(permissionCheckProvider(TreasuryPermissions.view));
    if (!allowed) return const AppScaffold(body: PermissionDeniedWidget(permission: TreasuryPermissions.view));
    return AppScaffold(
      appBar: const AppAppBar(title: Text('Treasury Reports')),
      body: _loading
          ? const AppLoadingWidget()
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  if (_kpis != null) ...[
                    _KpiCard(label: 'Cash on Hand', value: _kpis!.cashOnHand),
                    _KpiCard(label: 'Bank Balance', value: _kpis!.bankBalance),
                    _KpiCard(label: 'Pending Payments', value: _kpis!.pendingPayments),
                    _KpiCard(label: 'Pending Receipts', value: _kpis!.pendingReceipts),
                    _KpiCard(label: 'Uncleared Cheques', value: _kpis!.unclearedCheques),
                    _KpiCard(label: 'Liquidity Ratio', value: _kpis!.liquidityRatio),
                  ],
                ],
              ),
            ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({required this.label, required this.value});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(label),
        trailing: Text(value.toStringAsFixed(2), style: Theme.of(context).textTheme.titleMedium),
      ),
    );
  }
}
