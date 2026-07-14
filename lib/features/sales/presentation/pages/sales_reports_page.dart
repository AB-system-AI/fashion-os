import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_app_bar.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_scaffold.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/states/app_state_widgets.dart';
import 'package:fashion_pos_enterprise/features/auth/presentation/providers/auth_controller.dart';
import 'package:fashion_pos_enterprise/features/sales/presentation/providers/sales_providers.dart';

class SalesReportsPage extends ConsumerStatefulWidget {
  const SalesReportsPage({super.key});

  @override
  ConsumerState<SalesReportsPage> createState() => _SalesReportsPageState();
}

class _SalesReportsPageState extends ConsumerState<SalesReportsPage> {
  dynamic _report;
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
    final result = await ref.read(salesReportServiceProvider).generate(user: user);
    if (!mounted) return;
    setState(() {
      _report = result.dataOrNull;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final allowed = ref.watch(permissionCheckProvider(SalesOmsPermissions.view));
    if (!allowed) return const AppScaffold(body: PermissionDeniedWidget(permission: SalesOmsPermissions.view));
    return AppScaffold(
      appBar: const AppAppBar(title: Text('Sales Reports')),
      body: _loading
          ? const AppLoadingWidget()
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  _tile('Open orders', '${_report?.openOrders ?? 0}'),
                  _tile('Quotations sent', '${_report?.quotationsSent ?? 0}'),
                  _tile('Conversion rate', '${_report?.conversionRate?.toStringAsFixed(1) ?? 0}%'),
                  _tile('Fulfillment rate', '${_report?.fulfillmentRate?.toStringAsFixed(1) ?? 0}%'),
                  _tile('Open backorders', '${_report?.openBackorders ?? 0}'),
                  _tile('Pending shipments', '${_report?.pendingShipments ?? 0}'),
                ],
              ),
            ),
    );
  }

  Widget _tile(String label, String value) => Card(
        child: ListTile(title: Text(label), trailing: Text(value, style: Theme.of(context).textTheme.titleMedium)),
      );
}

class PickingPage extends ConsumerWidget {
  const PickingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allowed = ref.watch(permissionCheckProvider(ShipmentPermissions.manage));
    if (!allowed) return const AppScaffold(body: PermissionDeniedWidget(permission: ShipmentPermissions.manage));
    return const AppScaffold(
      appBar: AppAppBar(title: Text('Picking')),
      body: Center(child: Text('Barcode picking for shipments in picking status')),
    );
  }
}

class PackingPage extends ConsumerWidget {
  const PackingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allowed = ref.watch(permissionCheckProvider(ShipmentPermissions.manage));
    if (!allowed) return const AppScaffold(body: PermissionDeniedWidget(permission: ShipmentPermissions.manage));
    return const AppScaffold(
      appBar: AppAppBar(title: Text('Packing')),
      body: Center(child: Text('Pack confirmed pick lists before dispatch')),
    );
  }
}
