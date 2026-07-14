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

class ShipmentDetailPage extends ConsumerStatefulWidget {
  const ShipmentDetailPage({required this.shipmentId, super.key});

  final String shipmentId;

  @override
  ConsumerState<ShipmentDetailPage> createState() => _ShipmentDetailPageState();
}

class _ShipmentDetailPageState extends ConsumerState<ShipmentDetailPage> {
  dynamic _shipment;
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
    final s = await ref.read(shipmentRepositoryProvider).getById(widget.shipmentId, tenantId: user!.tenantId);
    if (!mounted) return;
    setState(() {
      _shipment = s;
      _loading = false;
    });
  }

  Future<void> _dispatch() async {
    final user = ref.read(authControllerProvider).user;
    if (user == null || _shipment == null) return;
    await ref.read(shipmentServiceProvider).dispatch(user: user, shipment: _shipment);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final allowed = ref.watch(permissionCheckProvider(ShipmentPermissions.manage));
    if (!allowed) return const AppScaffold(body: PermissionDeniedWidget(permission: ShipmentPermissions.manage));
    return AppScaffold(
      appBar: AppAppBar(title: Text(_shipment?.shipmentNumber ?? 'Shipment')),
      body: _loading
          ? const AppLoadingWidget()
          : _shipment == null
              ? const AppErrorWidget(message: 'Not found')
              : ListView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  children: [
                    ListTile(title: const Text('Status'), trailing: Text(_shipment.status.value)),
                    ListTile(title: const Text('Order'), trailing: Text(_shipment.orderId)),
                    FilledButton(onPressed: _dispatch, child: const Text('Dispatch shipment')),
                  ],
                ),
    );
  }
}
