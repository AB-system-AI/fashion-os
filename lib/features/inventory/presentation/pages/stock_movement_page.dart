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
import 'package:fashion_pos_enterprise/features/inventory/domain/entities/stock_movement.dart';
import 'package:fashion_pos_enterprise/features/inventory/presentation/providers/inventory_providers.dart';

class StockMovementPage extends ConsumerStatefulWidget {
  const StockMovementPage({super.key});

  @override
  ConsumerState<StockMovementPage> createState() => _StockMovementPageState();
}

class _StockMovementPageState extends ConsumerState<StockMovementPage> {
  List<StockMovement> _movements = [];
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
    final page = await ref.read(stockMovementServiceProvider).listStock(user: user!, tenantId: user.tenantId!);
    final warehouseId = page.items.isNotEmpty ? page.items.first.warehouseId : '';
    if (warehouseId.isEmpty) {
      setState(() {
        _loading = false;
        _movements = [];
      });
      return;
    }
    final ledger = await ref.read(stockMovementServiceProvider).ledger(
          user: user,
          tenantId: user.tenantId!,
          warehouseId: warehouseId,
        );
    if (!mounted) return;
    setState(() {
      _loading = false;
      _movements = ledger.dataOrNull ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final canRead = ref.watch(permissionCheckProvider(InventoryPermissions.read));
    if (!canRead) {
      return const AppScaffold(body: PermissionDeniedWidget(permission: InventoryPermissions.read));
    }

    return AppScaffold(
      appBar: const AppAppBar(title: Text('Stock Movements')),
      body: _loading
          ? const AppLoadingWidget()
          : _movements.isEmpty
              ? const AppEmptyWidget(message: 'No movements yet')
              : ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  itemCount: _movements.length,
                  separatorBuilder: (_, __) => const Gap(AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final m = _movements[index];
                    return ListTile(
                      title: Text('${m.movementType.value} • ${m.quantity}'),
                      subtitle: Text('Product ${m.productId} • After ${m.quantityAfter}'),
                      trailing: Text(m.createdAt.toLocal().toString().substring(0, 16)),
                    );
                  },
                ),
    );
  }
}
