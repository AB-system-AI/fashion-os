import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_app_bar.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_scaffold.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/states/app_state_widgets.dart';
import 'package:fashion_pos_enterprise/features/purchasing/routing/purchasing_route_paths.dart';

class PurchasingDashboardPage extends ConsumerWidget {
  const PurchasingDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canView = ref.watch(permissionCheckProvider(PurchasePermissions.view));
    if (!canView) {
      return const AppScaffold(
        body: PermissionDeniedWidget(permission: PurchasePermissions.view),
      );
    }

    return AppScaffold(
      appBar: const AppAppBar(title: Text('Purchasing')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          _NavTile(
            icon: Icons.local_shipping_outlined,
            title: 'Suppliers',
            subtitle: 'Manage vendor master data',
            onTap: () => context.push(PurchasingRoutePaths.suppliers),
          ),
          _NavTile(
            icon: Icons.receipt_long_outlined,
            title: 'Purchase Orders',
            subtitle: 'Draft, approve, and track POs',
            onTap: () => context.push(PurchasingRoutePaths.orders),
          ),
          _NavTile(
            icon: Icons.inventory_outlined,
            title: 'Receive Goods',
            subtitle: 'Partial and full receiving',
            onTap: () => context.push(PurchasingRoutePaths.receive),
          ),
          _NavTile(
            icon: Icons.undo_outlined,
            title: 'Purchase Returns',
            subtitle: 'Supplier return workflow',
            onTap: () => context.push(PurchasingRoutePaths.returns),
          ),
          _NavTile(
            icon: Icons.assessment_outlined,
            title: 'Reports',
            subtitle: 'Purchases, balances, top suppliers',
            onTap: () => context.push(PurchasingRoutePaths.reports),
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
