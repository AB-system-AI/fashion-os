import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_app_bar.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_scaffold.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/states/app_state_widgets.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/empty/app_empty_state.dart';
import 'package:fashion_pos_enterprise/features/auth/presentation/providers/auth_controller.dart';
import 'package:fashion_pos_enterprise/features/assets/domain/value_objects/assets_value_objects.dart';
import 'package:fashion_pos_enterprise/features/assets/presentation/providers/assets_providers.dart';

class AssetReportsPage extends ConsumerStatefulWidget {
  const AssetReportsPage({super.key});

  @override
  ConsumerState<AssetReportsPage> createState() => _AssetReportsPageState();
}

class _AssetReportsPageState extends ConsumerState<AssetReportsPage> {
  UtilizationKpis? _kpis;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  Future<void> _load() async {
    final user = ref.read(authControllerProvider).user;
    if (user == null) return;
    setState(() => _loading = true);
    final result = await ref.read(assetServiceProvider).dashboard(user: user);
    if (!mounted) return;
    setState(() {
      _kpis = result.dataOrNull;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final allowed = ref.watch(permissionCheckProvider(AssetsPermissions.view));
    if (!allowed) return const AppScaffold(body: PermissionDeniedWidget(permission: AssetsPermissions.view));
    final kpis = _kpis;
    return AppScaffold(
      appBar: const AppAppBar(title: Text('Asset Reports')),
      body: _loading
          ? const AppLoadingWidget()
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  if (kpis == null) const AppEmptyState(message: 'No report data'),
                  if (kpis != null) ...[
                    _KpiCard('Total Assets', '${kpis.totalAssets}'),
                    _KpiCard('Active Assets', '${kpis.activeAssets}'),
                    _KpiCard('In Maintenance', '${kpis.inMaintenance}'),
                    _KpiCard('Utilization Rate', '${(kpis.utilizationRate * 100).toStringAsFixed(1)}%'),
                    _KpiCard('Average Age', '${kpis.averageAgeMonths.toStringAsFixed(1)} months'),
                    _KpiCard('Total Book Value', kpis.totalBookValue.toStringAsFixed(2)),
                  ],
                ],
              ),
            ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Expanded(child: Text(label, style: Theme.of(context).textTheme.titleMedium)),
            Text(value, style: Theme.of(context).textTheme.headlineSmall),
          ],
        ),
      ),
    );
  }
}
