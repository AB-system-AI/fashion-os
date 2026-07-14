import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_app_bar.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_scaffold.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/states/app_state_widgets.dart';
import 'package:fashion_pos_enterprise/features/integrations/routing/integrations_route_paths.dart';

class IntegrationsDashboardPage extends ConsumerWidget {
  const IntegrationsDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canView = ref.watch(permissionCheckProvider(IntegrationPermissions.view));
    if (!canView) {
      return const AppScaffold(body: PermissionDeniedWidget(permission: IntegrationPermissions.view));
    }
    final width = MediaQuery.sizeOf(context).width;
    final crossAxisCount = width >= 900 ? 3 : width >= 600 ? 2 : 1;
    final tiles = [
      ('Connectors', Icons.hub_outlined, IntegrationsRoutePaths.connectors),
      ('Webhooks', Icons.webhook_outlined, IntegrationsRoutePaths.webhooks),
      ('API Keys', Icons.vpn_key_outlined, IntegrationsRoutePaths.apiKeys),
      ('Email Settings', Icons.email_outlined, IntegrationsRoutePaths.emailSettings),
      ('Import / Export', Icons.import_export_outlined, IntegrationsRoutePaths.importExportHub),
      ('Printers', Icons.print_outlined, IntegrationsRoutePaths.printerManager),
      ('Health Status', Icons.monitor_heart_outlined, IntegrationsRoutePaths.healthStatus),
    ];
    return AppScaffold(
      appBar: const AppAppBar(title: Text('Integrations')),
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
