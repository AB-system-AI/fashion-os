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
import 'package:fashion_pos_enterprise/features/customers/routing/customer_route_paths.dart';

class CrmDashboardPage extends ConsumerWidget {
  const CrmDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canView = ref.watch(permissionCheckProvider(CustomerPermissions.view));
    if (!canView) {
      return const AppScaffold(
        body: PermissionDeniedWidget(permission: CustomerPermissions.view),
      );
    }

    return AppScaffold(
      appBar: const AppAppBar(title: Text('CRM')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          _NavTile(icon: Icons.people_outline, title: 'Customers', subtitle: 'Search and manage customers', onTap: () => context.push(CustomerRoutePaths.list)),
          _NavTile(icon: Icons.card_giftcard_outlined, title: 'Loyalty', subtitle: 'Points, tiers, and rewards', onTap: () => context.push(CustomerRoutePaths.loyalty)),
          _NavTile(icon: Icons.account_balance_wallet_outlined, title: 'Wallet', subtitle: 'Deposits, payments, refunds', onTap: () => context.push(CustomerRoutePaths.wallet)),
          _NavTile(icon: Icons.credit_score_outlined, title: 'Credit', subtitle: 'Limits and outstanding balances', onTap: () => context.push(CustomerRoutePaths.credit)),
          _NavTile(icon: Icons.assessment_outlined, title: 'Reports', subtitle: 'Top customers, birthdays, loyalty', onTap: () => context.push(CustomerRoutePaths.reports)),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({required this.icon, required this.title, required this.subtitle, required this.onTap});
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
