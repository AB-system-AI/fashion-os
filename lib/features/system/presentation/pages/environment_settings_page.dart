import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_app_bar.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_scaffold.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/states/app_state_widgets.dart';
import 'package:fashion_pos_enterprise/features/system/presentation/providers/system_providers.dart';

class EnvironmentSettingsPage extends ConsumerWidget {
  const EnvironmentSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canManage = ref.watch(permissionCheckProvider(SystemPermissions.manage));
    if (!canManage) {
      return const AppScaffold(body: PermissionDeniedWidget(permission: SystemPermissions.manage));
    }
    final user = ref.watch(currentUserProvider);
    if (user == null) return const AppScaffold(body: Center(child: Text('Not signed in')));

    return AppScaffold(
      appBar: const AppAppBar(title: Text('Environment Settings')),
      body: FutureBuilder(
        future: ref.read(environmentSettingsServiceProvider).list(user),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final result = snapshot.data!;
          if (result.isFailure) return Center(child: Text(result.failureOrNull?.message ?? 'Error'));
          final settings = result.dataOrNull ?? [];
          if (settings.isEmpty) return const Center(child: Text('No environment settings'));
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: settings.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final s = settings[i];
              return ListTile(
                title: Text(s.key),
                subtitle: Text(s.environment.value),
                trailing: s.isSecret ? const Icon(Icons.lock_outline) : Text(s.value),
              );
            },
          );
        },
      ),
    );
  }
}
