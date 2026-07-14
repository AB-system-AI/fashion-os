import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_app_bar.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_scaffold.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/states/app_state_widgets.dart';
import 'package:fashion_pos_enterprise/features/auth/presentation/providers/auth_controller.dart';
import 'package:fashion_pos_enterprise/features/inventory/domain/entities/stock_count.dart';
import 'package:fashion_pos_enterprise/features/inventory/presentation/providers/inventory_providers.dart';

class StockCountPage extends ConsumerStatefulWidget {
  const StockCountPage({super.key});

  @override
  ConsumerState<StockCountPage> createState() => _StockCountPageState();
}

class _StockCountPageState extends ConsumerState<StockCountPage> {
  List<StockCount> _counts = [];
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
    final page = await ref.read(stockCountServiceProvider).list(user: user, tenantId: user.tenantId!);
    if (!mounted) return;
    setState(() {
      _loading = false;
      _counts = page.items;
    });
  }

  @override
  Widget build(BuildContext context) {
    final canCount = ref.watch(permissionCheckProvider(InventoryPermissions.count));
    if (!canCount) {
      return const AppScaffold(body: PermissionDeniedWidget(permission: InventoryPermissions.count));
    }

    return AppScaffold(
      appBar: const AppAppBar(title: Text('Stock Counts')),
      body: _loading
          ? const AppLoadingWidget()
          : _counts.isEmpty
              ? const AppEmptyWidget(message: 'No count sessions')
              : ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  itemCount: _counts.length,
                  itemBuilder: (context, index) {
                    final c = _counts[index];
                    return ListTile(
                      title: Text(c.name ?? c.id.substring(0, 8)),
                      subtitle: Text('Warehouse ${c.warehouseId} • ${c.lines.length} lines'),
                      trailing: Text(c.status.value),
                    );
                  },
                ),
    );
  }
}
