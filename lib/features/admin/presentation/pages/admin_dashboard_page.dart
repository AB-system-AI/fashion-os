import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_app_bar.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_scaffold.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/states/app_state_widgets.dart';
import 'package:fashion_pos_enterprise/features/admin/routing/admin_route_paths.dart';

class AdminDashboardPage extends ConsumerWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canView = ref.watch(permissionCheckProvider(EnterpriseAdminPermissions.view));
    if (!canView) {
      return const AppScaffold(body: PermissionDeniedWidget(permission: EnterpriseAdminPermissions.view));
    }
    final width = MediaQuery.sizeOf(context).width;
    final crossAxisCount = width >= 900 ? 3 : width >= 600 ? 2 : 1;
    final tiles = <(String, IconData, String)>[
      ('Organizations', Icons.corporate_fare_outlined, AdminRoutePaths.organizations),
      ('Companies', Icons.business_outlined, AdminRoutePaths.companies),
      ('Branches', Icons.account_tree_outlined, AdminRoutePaths.branches),
      ('Stores', Icons.storefront_outlined, AdminRoutePaths.stores),
      ('Departments', Icons.apartment_outlined, AdminRoutePaths.departments),
      ('Teams', Icons.groups_outlined, AdminRoutePaths.teams),
      ('Users', Icons.people_outline, AdminRoutePaths.users),
      ('Roles', Icons.badge_outlined, AdminRoutePaths.roles),
      ('Permissions', Icons.admin_panel_settings_outlined, AdminRoutePaths.permissions),
      ('Tenant Settings', Icons.tune_outlined, AdminRoutePaths.tenantSettings),
      ('Branding', Icons.palette_outlined, AdminRoutePaths.branding),
      ('Localization', Icons.language_outlined, AdminRoutePaths.localization),
      ('Currency', Icons.attach_money_outlined, AdminRoutePaths.currencySettings),
      ('Fiscal', Icons.calendar_month_outlined, AdminRoutePaths.fiscalSettings),
      ('Numbering', Icons.numbers_outlined, AdminRoutePaths.numberingSettings),
      ('Feature Flags', Icons.flag_outlined, AdminRoutePaths.featureFlags),
      ('License', Icons.verified_outlined, AdminRoutePaths.license),
      ('Usage', Icons.insights_outlined, AdminRoutePaths.usageDashboard),
      ('Storage', Icons.storage_outlined, AdminRoutePaths.storageDashboard),
      ('API Usage', Icons.api_outlined, AdminRoutePaths.apiUsage),
      ('Health', Icons.monitor_heart_outlined, AdminRoutePaths.healthDashboard),
      ('Audit Explorer', Icons.manage_search_outlined, AdminRoutePaths.auditExplorer),
      ('Jobs Monitor', Icons.work_history_outlined, AdminRoutePaths.jobsMonitor),
      ('Sync Monitor', Icons.sync_outlined, AdminRoutePaths.syncMonitor),
      ('Devices', Icons.devices_outlined, AdminRoutePaths.devices),
      ('Sessions', Icons.lock_clock_outlined, AdminRoutePaths.sessions),
      ('Login History', Icons.login_outlined, AdminRoutePaths.loginHistory),
      ('Maintenance', Icons.build_circle_outlined, AdminRoutePaths.maintenance),
      ('Release Manager', Icons.new_releases_outlined, AdminRoutePaths.releaseManager),
      ('Migration Manager', Icons.move_up_outlined, AdminRoutePaths.migrationManager),
      ('Diagnostics', Icons.medical_services_outlined, AdminRoutePaths.diagnostics),
      ('Developer Tools', Icons.code_outlined, AdminRoutePaths.developerTools),
      ('Reports', Icons.summarize_outlined, AdminRoutePaths.reports),
    ];
    return AppScaffold(
      appBar: const AppAppBar(title: Text('Enterprise Administration')),
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
