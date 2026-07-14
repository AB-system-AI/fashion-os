import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_app_bar.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_scaffold.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/states/app_state_widgets.dart';
import 'package:fashion_pos_enterprise/features/auth/presentation/providers/auth_controller.dart';
import 'package:fashion_pos_enterprise/features/sales/domain/enums/sales_enums.dart';
import 'package:fashion_pos_enterprise/features/sales/presentation/providers/sales_providers.dart';

class SalesOrderDetailPage extends ConsumerStatefulWidget {
  const SalesOrderDetailPage({required this.orderId, super.key});

  final String orderId;

  @override
  ConsumerState<SalesOrderDetailPage> createState() => _SalesOrderDetailPageState();
}

class _SalesOrderDetailPageState extends ConsumerState<SalesOrderDetailPage> {
  dynamic _order;
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
    final order = await ref.read(salesOrderServiceProvider).getById(widget.orderId, user!.tenantId!);
    if (!mounted) return;
    setState(() {
      _order = order;
      _loading = false;
    });
  }

  Future<void> _confirm() async {
    final user = ref.read(authControllerProvider).user;
    if (user == null || _order == null) return;
    await ref.read(salesOrderServiceProvider).confirm(user: user, order: _order);
    await _load();
  }

  Future<void> _approve() async {
    final user = ref.read(authControllerProvider).user;
    if (user == null || _order == null) return;
    final settings = await ref.read(salesSettingsRepositoryProvider).getSettings(user.tenantId!);
    await ref.read(salesOrderServiceProvider).approve(user: user, order: _order, settings: settings);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final allowed = ref.watch(permissionCheckProvider(SalesOmsPermissions.view));
    if (!allowed) return const AppScaffold(body: PermissionDeniedWidget(permission: SalesOmsPermissions.view));
    return AppScaffold(
      appBar: AppAppBar(title: Text(_order?.orderNumber ?? 'Order')),
      body: _loading
          ? const AppLoadingWidget()
          : _order == null
              ? const AppErrorWidget(message: 'Not found')
              : ListView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  children: [
                    ListTile(title: const Text('Status'), trailing: Text(_order.status.value)),
                    ListTile(title: const Text('Total'), trailing: Text(_order.grandTotal.toStringAsFixed(2))),
                    if (_order.status == SalesOrderStatus.draft)
                      FilledButton(onPressed: _confirm, child: const Text('Confirm order')),
                    if (_order.status == SalesOrderStatus.confirmed)
                      FilledButton(onPressed: _approve, child: const Text('Approve order')),
                  ],
                ),
    );
  }
}
