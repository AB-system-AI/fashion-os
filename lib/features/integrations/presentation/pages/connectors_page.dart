import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_app_bar.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_scaffold.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/states/app_state_widgets.dart';
import 'package:fashion_pos_enterprise/features/auth/presentation/providers/auth_controller.dart';
import 'package:fashion_pos_enterprise/features/integrations/presentation/providers/integrations_providers.dart';

class ConnectorsPage extends ConsumerWidget {
  const ConnectorsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canManage = ref.watch(permissionCheckProvider(ConnectorPermissions.manage));
    if (!canManage) {
      return const AppScaffold(body: PermissionDeniedWidget(permission: ConnectorPermissions.manage));
    }
    final tenantId = ref.watch(authControllerProvider).user?.tenantId;
    return AppScaffold(
      appBar: const AppAppBar(title: Text('Connectors')),
      body: tenantId == null
          ? const Center(child: Text('Sign in to manage connectors'))
          : FutureBuilder(
              future: ref.read(connectorServiceProvider).list(tenantId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final items = snapshot.data!.items;
                if (items.isEmpty) {
                  return const Center(child: Text('No connectors configured'));
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, i) {
                    final c = items[i];
                    return ListTile(
                      leading: const Icon(Icons.hub_outlined),
                      title: Text(c.name),
                      subtitle: Text('${c.connectorType.value} · ${c.status.value}'),
                      trailing: Icon(c.isEnabled ? Icons.check_circle_outline : Icons.pause_circle_outline),
                    );
                  },
                );
              },
            ),
    );
  }
}
