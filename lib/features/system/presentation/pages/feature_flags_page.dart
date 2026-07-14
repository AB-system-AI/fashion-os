import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_app_bar.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_scaffold.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/states/app_state_widgets.dart';
import 'package:fashion_pos_enterprise/features/system/presentation/providers/system_providers.dart';

class FeatureFlagsPage extends ConsumerWidget {
  const FeatureFlagsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canManage = ref.watch(permissionCheckProvider(FeatureFlagPermissions.manage));
    if (!canManage) {
      return const AppScaffold(body: PermissionDeniedWidget(permission: FeatureFlagPermissions.manage));
    }
    final user = ref.watch(currentUserProvider);
    if (user == null) return const AppScaffold(body: Center(child: Text('Not signed in')));

    return AppScaffold(
      appBar: const AppAppBar(title: Text('Feature Flags')),
      body: FutureBuilder(
        future: ref.read(systemFeatureFlagServiceProvider).list(user),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final result = snapshot.data!;
          if (result.isFailure) return Center(child: Text(result.failureOrNull?.message ?? 'Error'));
          final flags = result.dataOrNull ?? [];
          if (flags.isEmpty) return const Center(child: Text('No feature flags configured'));
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: flags.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final f = flags[i];
              return ListTile(
                title: Text(f.key),
                subtitle: Text(f.description ?? f.scope.value),
                trailing: Switch(value: f.enabled, onChanged: null),
              );
            },
          );
        },
      ),
    );
  }
}
