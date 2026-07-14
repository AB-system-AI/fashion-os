import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fashion_pos_enterprise/core/business/engines/integration/integration_connector_engine.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_app_bar.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_scaffold.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/states/app_state_widgets.dart';
import 'package:fashion_pos_enterprise/features/auth/presentation/providers/auth_controller.dart';
import 'package:fashion_pos_enterprise/features/integrations/presentation/providers/integrations_providers.dart';

class HealthStatusPage extends ConsumerWidget {
  const HealthStatusPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canView = ref.watch(permissionCheckProvider(IntegrationPermissions.view));
    if (!canView) {
      return const AppScaffold(body: PermissionDeniedWidget(permission: IntegrationPermissions.view));
    }
    final tenantId = ref.watch(authControllerProvider).user?.tenantId;
    return AppScaffold(
      appBar: const AppAppBar(title: Text('Integration Health')),
      body: tenantId == null
          ? const Center(child: Text('Sign in to view health status'))
          : FutureBuilder<Map<String, HealthCheckResult>>(
              future: ref.read(healthCheckServiceProvider).checkAll(tenantId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final results = snapshot.data!;
                if (results.isEmpty) return const Center(child: Text('No connectors to check'));
                return ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  itemCount: results.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, i) {
                    final entry = results.entries.elementAt(i);
                    final status = entry.value.status;
                    final icon = switch (status) {
                      ConnectorHealthStatus.healthy => Icons.check_circle,
                      ConnectorHealthStatus.degraded => Icons.warning_amber,
                      ConnectorHealthStatus.unhealthy => Icons.error_outline,
                      ConnectorHealthStatus.disabled => Icons.pause_circle_outline,
                    };
                    return ListTile(
                      leading: Icon(icon),
                      title: Text(entry.key),
                      subtitle: Text(entry.value.message ?? status.value),
                    );
                  },
                );
              },
            ),
    );
  }
}
