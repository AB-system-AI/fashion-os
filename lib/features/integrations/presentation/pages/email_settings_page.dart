import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_app_bar.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_scaffold.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/states/app_state_widgets.dart';
import 'package:fashion_pos_enterprise/features/integrations/domain/enums/integration_enums.dart';
import 'package:fashion_pos_enterprise/features/integrations/presentation/providers/integrations_providers.dart';

class EmailSettingsPage extends ConsumerWidget {
  const EmailSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canManage = ref.watch(permissionCheckProvider(IntegrationPermissions.manage));
    if (!canManage) {
      return const AppScaffold(body: PermissionDeniedWidget(permission: IntegrationPermissions.manage));
    }
    final provider = ref.watch(emailProviderProvider);
    return AppScaffold(
      appBar: const AppAppBar(title: Text('Email Settings')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Active provider', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            ListTile(
              leading: const Icon(Icons.email_outlined),
              title: Text(provider.providerKey),
              subtitle: const Text('NoOp provider — replace with SendGrid, SES, etc.'),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Connector type', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            Text(ConnectorType.email.value),
          ],
        ),
      ),
    );
  }
}
