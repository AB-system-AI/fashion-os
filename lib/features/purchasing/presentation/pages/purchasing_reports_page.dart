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
import 'package:fashion_pos_enterprise/features/purchasing/domain/services/purchasing_report_service.dart';
import 'package:fashion_pos_enterprise/features/purchasing/presentation/providers/purchasing_providers.dart';

class PurchasingReportsPage extends ConsumerStatefulWidget {
  const PurchasingReportsPage({super.key});

  @override
  ConsumerState<PurchasingReportsPage> createState() => _PurchasingReportsPageState();
}

class _PurchasingReportsPageState extends ConsumerState<PurchasingReportsPage> {
  List<SupplierPurchaseSummary> _topSuppliers = [];
  int _outstandingCount = 0;
  int _receivingCount = 0;
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
    final reports = ref.read(purchasingReportServiceProvider);
    final top = await reports.topSuppliers(user!.tenantId!);
    final outstanding = await reports.outstandingOrders(user.tenantId!);
    final receiving = await reports.receivingCount(user.tenantId!);
    if (!mounted) return;
    setState(() {
      _loading = false;
      _topSuppliers = top;
      _outstandingCount = outstanding.length;
      _receivingCount = receiving;
    });
  }

  @override
  Widget build(BuildContext context) {
    final canView = ref.watch(permissionCheckProvider(PurchasePermissions.report));
    if (!canView) {
      return const AppScaffold(
        body: PermissionDeniedWidget(permission: PurchasePermissions.report),
      );
    }

    return AppScaffold(
      appBar: const AppAppBar(title: Text('Purchasing Reports')),
      body: _loading
          ? const AppLoadingWidget()
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  Card(
                    child: ListTile(
                      title: const Text('Outstanding Orders'),
                      trailing: Text('$_outstandingCount'),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      title: const Text('Receipts'),
                      trailing: Text('$_receivingCount'),
                    ),
                  ),
                  const Gap(AppSpacing.lg),
                  Text('Top Suppliers', style: Theme.of(context).textTheme.titleMedium),
                  ..._topSuppliers.map(
                    (s) => ListTile(
                      title: Text(s.supplier.companyName),
                      subtitle: Text('${s.orderCount} orders'),
                      trailing: Text(s.totalPurchases.toStringAsFixed(2)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
