import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/design_system/components/semantic_button.dart';
import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_app_bar.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_scaffold.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/states/app_state_widgets.dart';
import 'package:fashion_pos_enterprise/features/inventory/routing/inventory_route_paths.dart';

class InventoryDashboardPage extends ConsumerWidget {
  const InventoryDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canRead = ref.watch(permissionCheckProvider(InventoryPermissions.read));
    if (!canRead) {
      return const AppScaffold(
        body: PermissionDeniedWidget(permission: InventoryPermissions.read),
      );
    }

    return AppScaffold(
      appBar: const AppAppBar(title: Text('Inventory')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          _NavTile(
            icon: Icons.warehouse_outlined,
            title: 'Warehouses',
            subtitle: 'Manage locations and stores',
            onTap: () => context.push(InventoryRoutePaths.warehouses),
          ),
          _NavTile(
            icon: Icons.inventory_2_outlined,
            title: 'Stock Levels',
            subtitle: 'On-hand and available quantities',
            onTap: () => context.push(InventoryRoutePaths.stock),
          ),
          _NavTile(
            icon: Icons.receipt_long_outlined,
            title: 'Movements',
            subtitle: 'Immutable stock ledger',
            onTap: () => context.push(InventoryRoutePaths.movements),
          ),
          _NavTile(
            icon: Icons.swap_horiz,
            title: 'Transfers',
            subtitle: 'Inter-warehouse workflow',
            onTap: () => context.push(InventoryRoutePaths.transfers),
          ),
          _NavTile(
            icon: Icons.fact_check_outlined,
            title: 'Stock Counts',
            subtitle: 'Physical inventory sessions',
            onTap: () => context.push(InventoryRoutePaths.counts),
          ),
          _NavTile(
            icon: Icons.qr_code_scanner,
            title: 'Barcode Actions',
            subtitle: 'Fast receive and issue',
            onTap: () => context.push(InventoryRoutePaths.barcode),
          ),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
