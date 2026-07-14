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
import 'package:fashion_pos_enterprise/features/inventory/domain/entities/stock_level.dart';
import 'package:fashion_pos_enterprise/features/inventory/presentation/providers/inventory_providers.dart';

class StockListPage extends ConsumerStatefulWidget {
  const StockListPage({super.key});

  @override
  ConsumerState<StockListPage> createState() => _StockListPageState();
}

class _StockListPageState extends ConsumerState<StockListPage> {
  List<StockLevel> _levels = [];
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
    final page = await ref.read(stockMovementServiceProvider).listStock(
          user: user,
          tenantId: user.tenantId!,
        );
    if (!mounted) return;
    setState(() {
      _loading = false;
      _levels = page.items;
    });
  }

  @override
  Widget build(BuildContext context) {
    final canRead = ref.watch(permissionCheckProvider(InventoryPermissions.read));
    if (!canRead) {
      return const AppScaffold(body: PermissionDeniedWidget(permission: InventoryPermissions.read));
    }

    return AppScaffold(
      appBar: const AppAppBar(title: Text('Stock Levels')),
      body: _loading
          ? const AppLoadingWidget()
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: _levels.length,
                separatorBuilder: (_, __) => const Gap(AppSpacing.sm),
                itemBuilder: (context, index) {
                  final level = _levels[index];
                  return ListTile(
                    title: Text(level.productId),
                    subtitle: Text('Warehouse ${level.warehouseId}'),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('On hand: ${level.onHand}'),
                        Text('Available: ${level.available}', style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }
}
