import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_app_bar.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_scaffold.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/states/app_state_widgets.dart';
import 'package:fashion_pos_enterprise/features/system/routing/system_route_paths.dart';

class SystemDashboardPage extends ConsumerWidget {
  const SystemDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canView = ref.watch(permissionCheckProvider(SystemPermissions.view));
    if (!canView) {
      return const AppScaffold(body: PermissionDeniedWidget(permission: SystemPermissions.view));
    }
    final width = MediaQuery.sizeOf(context).width;
    final crossAxisCount = width >= 900 ? 3 : width >= 600 ? 2 : 1;
    final tiles = [
      ('Feature Flags', Icons.flag_outlined, SystemRoutePaths.featureFlags),
      ('Audit Explorer', Icons.manage_search_outlined, SystemRoutePaths.auditExplorer),
      ('Permissions', Icons.admin_panel_settings_outlined, SystemRoutePaths.permissionManager),
      ('Roles', Icons.groups_outlined, SystemRoutePaths.roleManager),
      ('Health Monitor', Icons.monitor_heart_outlined, SystemRoutePaths.healthMonitor),
      ('Sync Monitor', Icons.sync_outlined, SystemRoutePaths.syncMonitor),
      ('Error Logs', Icons.bug_report_outlined, SystemRoutePaths.errorLogs),
      ('Security Center', Icons.security_outlined, SystemRoutePaths.securityCenter),
      ('Maintenance Mode', Icons.build_circle_outlined, SystemRoutePaths.maintenanceMode),
      ('Environment', Icons.settings_suggest_outlined, SystemRoutePaths.environmentSettings),
      ('Diagnostics', Icons.medical_services_outlined, SystemRoutePaths.diagnostics),
      ('Release Notes', Icons.new_releases_outlined, SystemRoutePaths.releaseNotes),
    ];
    return AppScaffold(
      appBar: const AppAppBar(title: Text('System Administration')),
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
