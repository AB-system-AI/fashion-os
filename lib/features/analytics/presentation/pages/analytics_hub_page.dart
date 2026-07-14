import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_app_bar.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_scaffold.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/states/app_state_widgets.dart';
import 'package:fashion_pos_enterprise/features/analytics/routing/analytics_route_paths.dart';

class AnalyticsHubPage extends ConsumerWidget {
  const AnalyticsHubPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canView = ref.watch(permissionCheckProvider(AnalyticsPermissions.view));
    if (!canView) {
      return const AppScaffold(body: PermissionDeniedWidget(permission: AnalyticsPermissions.view));
    }

    final width = MediaQuery.sizeOf(context).width;
    final crossAxisCount = width >= 900 ? 3 : width >= 600 ? 2 : 1;
    final canExecutive = ref.watch(permissionCheckProvider(ExecutiveDashboardPermissions.view));

    final tiles = <(String, IconData, String, String?)>[
      if (canExecutive) ('Executive', Icons.leaderboard_outlined, AnalyticsRoutePaths.executive, ExecutiveDashboardPermissions.view),
      ('Sales', Icons.point_of_sale_outlined, AnalyticsRoutePaths.sales, null),
      ('Inventory', Icons.inventory_2_outlined, AnalyticsRoutePaths.inventory, null),
      ('Purchasing', Icons.local_shipping_outlined, AnalyticsRoutePaths.purchasing, null),
      ('CRM', Icons.people_outline, AnalyticsRoutePaths.crm, null),
      ('Accounting', Icons.account_balance_outlined, AnalyticsRoutePaths.accounting, null),
      ('HR', Icons.badge_outlined, AnalyticsRoutePaths.hr, null),
      ('Manufacturing', Icons.precision_manufacturing_outlined, AnalyticsRoutePaths.manufacturing, null),
      ('Reports', Icons.summarize_outlined, AnalyticsRoutePaths.reports, ReportPermissions.view),
    ];

    return AppScaffold(
      appBar: const AppAppBar(title: Text('Analytics & BI')),
      body: GridView.builder(
        padding: const EdgeInsets.all(AppSpacing.lg),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: AppSpacing.md,
          crossAxisSpacing: AppSpacing.md,
          childAspectRatio: width >= 600 ? 2.2 : 2.8,
        ),
        itemCount: tiles.length,
        itemBuilder: (context, i) {
          final t = tiles[i];
          final perm = t.$4;
          if (perm != null && !ref.watch(permissionCheckProvider(perm))) {
            return const SizedBox.shrink();
          }
          return Card(
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => context.push(t.$3),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    Icon(t.$2, size: 32),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(child: Text(t.$1, style: Theme.of(context).textTheme.titleMedium)),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
