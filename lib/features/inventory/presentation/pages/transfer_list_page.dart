import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_app_bar.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_scaffold.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/states/app_state_widgets.dart';
import 'package:fashion_pos_enterprise/features/auth/presentation/providers/auth_controller.dart';
import 'package:fashion_pos_enterprise/features/inventory/domain/entities/inventory_transfer.dart';
import 'package:fashion_pos_enterprise/features/inventory/presentation/providers/inventory_providers.dart';
import 'package:fashion_pos_enterprise/features/inventory/routing/inventory_route_paths.dart';

class TransferListPage extends ConsumerStatefulWidget {
  const TransferListPage({super.key});

  @override
  ConsumerState<TransferListPage> createState() => _TransferListPageState();
}

class _TransferListPageState extends ConsumerState<TransferListPage> {
  List<InventoryTransfer> _transfers = [];
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
    final page = await ref.read(inventoryTransferServiceProvider).list(user: user, tenantId: user.tenantId!);
    if (!mounted) return;
    setState(() {
      _loading = false;
      _transfers = page.items;
    });
  }

  @override
  Widget build(BuildContext context) {
    final canRead = ref.watch(permissionCheckProvider(InventoryPermissions.read));
    if (!canRead) {
      return const AppScaffold(body: PermissionDeniedWidget(permission: InventoryPermissions.read));
    }

    return AppScaffold(
      appBar: const AppAppBar(title: Text('Transfers')),
      body: _loading
          ? const AppLoadingWidget()
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: _transfers.length,
                itemBuilder: (context, index) {
                  final t = _transfers[index];
                  return ListTile(
                    title: Text(t.reference ?? t.id.substring(0, 8)),
                    subtitle: Text('${t.fromWarehouseId} → ${t.toWarehouseId}'),
                    trailing: Text(t.status.value),
                    onTap: () => context.push(InventoryRoutePaths.transferDetail(t.id)),
                  );
                },
              ),
            ),
    );
  }
}
