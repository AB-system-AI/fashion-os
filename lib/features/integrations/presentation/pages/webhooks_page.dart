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

class WebhooksPage extends ConsumerWidget {
  const WebhooksPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canManage = ref.watch(permissionCheckProvider(WebhookPermissions.manage));
    if (!canManage) {
      return const AppScaffold(body: PermissionDeniedWidget(permission: WebhookPermissions.manage));
    }
    final tenantId = ref.watch(authControllerProvider).user?.tenantId;
    return AppScaffold(
      appBar: const AppAppBar(title: Text('Webhooks')),
      body: tenantId == null
          ? const Center(child: Text('Sign in to manage webhooks'))
          : FutureBuilder(
              future: ref.read(webhookServiceProvider).list(tenantId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final items = snapshot.data!.items;
                if (items.isEmpty) return const Center(child: Text('No webhooks configured'));
                return ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, i) {
                    final w = items[i];
                    return ListTile(
                      leading: const Icon(Icons.webhook_outlined),
                      title: Text(w.name),
                      subtitle: Text(w.url),
                      trailing: Text(w.status.value),
                    );
                  },
                );
              },
            ),
    );
  }
}
