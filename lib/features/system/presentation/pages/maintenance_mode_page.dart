import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_app_bar.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_scaffold.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/states/app_state_widgets.dart';
import 'package:fashion_pos_enterprise/features/system/presentation/providers/system_providers.dart';

class MaintenanceModePage extends ConsumerWidget {
  const MaintenanceModePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canManage = ref.watch(permissionCheckProvider(SystemMaintenancePermissions.manage));
    if (!canManage) {
      return const AppScaffold(body: PermissionDeniedWidget(permission: SystemMaintenancePermissions.manage));
    }
    final user = ref.watch(currentUserProvider);
    if (user == null) return const AppScaffold(body: Center(child: Text('Not signed in')));

    return AppScaffold(
      appBar: const AppAppBar(title: Text('Maintenance Mode')),
      body: FutureBuilder(
        future: ref.read(maintenanceServiceProvider).current(user),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final result = snapshot.data!;
          if (result.isFailure) return Center(child: Text(result.failureOrNull?.message ?? 'Error'));
          final mode = result.dataOrNull;
          final active = mode?.active ?? false;
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile(
                  title: const Text('Maintenance active'),
                  subtitle: Text(mode?.message ?? 'Toggle tenant maintenance mode'),
                  value: active,
                  onChanged: (v) => ref.read(maintenanceServiceProvider).setActive(user, active: v),
                ),
                if (mode != null) ...[
                  const SizedBox(height: 16),
                  Text('Scope: ${mode.scope.value}'),
                  if (mode.scheduledStart != null) Text('Starts: ${mode.scheduledStart!.toLocal()}'),
                  if (mode.scheduledEnd != null) Text('Ends: ${mode.scheduledEnd!.toLocal()}'),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
