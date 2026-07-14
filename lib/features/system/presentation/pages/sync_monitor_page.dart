import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_app_bar.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_scaffold.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/states/app_state_widgets.dart';
import 'package:fashion_pos_enterprise/features/system/presentation/providers/system_providers.dart';

class SyncMonitorPage extends ConsumerWidget {
  const SyncMonitorPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canView = ref.watch(permissionCheckProvider(SystemPermissions.view));
    if (!canView) {
      return const AppScaffold(body: PermissionDeniedWidget(permission: SystemPermissions.view));
    }
    final user = ref.watch(currentUserProvider);
    if (user == null) return const AppScaffold(body: Center(child: Text('Not signed in')));

    return AppScaffold(
      appBar: const AppAppBar(title: Text('Sync Monitor')),
      body: FutureBuilder(
        future: ref.read(syncMonitorServiceProvider).latest(user),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final result = snapshot.data!;
          if (result.isFailure) return Center(child: Text(result.failureOrNull?.message ?? 'Error'));
          final sync = result.dataOrNull;
          if (sync == null) {
            return Center(
              child: ElevatedButton(
                onPressed: () => ref.read(syncMonitorServiceProvider).capture(user),
                child: const Text('Capture snapshot'),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              ListTile(title: const Text('Engine'), trailing: Text(sync.engineState)),
              ListTile(title: const Text('Pending'), trailing: Text('${sync.pendingCount}')),
              ListTile(title: const Text('Failed'), trailing: Text('${sync.failedCount}')),
              ListTile(title: const Text('Captured'), trailing: Text(sync.capturedAt.toLocal().toString())),
            ],
          );
        },
      ),
    );
  }
}
