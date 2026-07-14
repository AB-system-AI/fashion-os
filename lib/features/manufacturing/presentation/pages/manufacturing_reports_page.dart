import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_app_bar.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_scaffold.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/states/app_state_widgets.dart';
import 'package:fashion_pos_enterprise/features/auth/presentation/providers/auth_controller.dart';
import 'package:fashion_pos_enterprise/features/manufacturing/presentation/providers/manufacturing_providers.dart';

class ManufacturingReportsPage extends ConsumerStatefulWidget {
  const ManufacturingReportsPage({super.key});

  @override
  ConsumerState<ManufacturingReportsPage> createState() => _ManufacturingReportsPageState();
}

class _ManufacturingReportsPageState extends ConsumerState<ManufacturingReportsPage> {
  dynamic _report;
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
    final report = await ref.read(manufacturingReportServiceProvider).generate(user: user!, tenantId: user.tenantId!);
    if (!mounted) return;
    setState(() {
      _report = report;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final allowed = ref.watch(permissionCheckProvider(ManufacturingPermissions.view));
    if (!allowed) return const AppScaffold(body: PermissionDeniedWidget(permission: ManufacturingPermissions.view));

    return AppScaffold(
      appBar: const AppAppBar(title: Text('Manufacturing Reports')),
      body: _loading
          ? const AppLoadingWidget()
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  _tile('Production efficiency', '${_report.productionEfficiencyPercent.toStringAsFixed(1)}%'),
                  _tile('Orders in progress', '${_report.ordersInProgress}'),
                  _tile('Orders completed', '${_report.ordersCompleted}'),
                  _tile('Yield', '${_report.yieldPercent.toStringAsFixed(1)}%'),
                  _tile('Scrap', '${_report.scrapPercent.toStringAsFixed(1)}%'),
                  _tile('Total planned qty', '${_report.totalPlannedQty}'),
                  _tile('Total completed qty', '${_report.totalCompletedQty}'),
                  _tile('Total scrapped qty', '${_report.totalScrappedQty}'),
                ],
              ),
            ),
    );
  }

  Widget _tile(String label, String value) => Card(
        child: ListTile(title: Text(label), trailing: Text(value, style: Theme.of(context).textTheme.titleMedium)),
      );
}
