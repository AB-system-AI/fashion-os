import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_app_bar.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_scaffold.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/states/app_state_widgets.dart';
import 'package:fashion_pos_enterprise/features/system/presentation/providers/system_providers.dart';

class HealthMonitorPage extends ConsumerWidget {
  const HealthMonitorPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canView = ref.watch(permissionCheckProvider(SystemPermissions.view));
    if (!canView) {
      return const AppScaffold(body: PermissionDeniedWidget(permission: SystemPermissions.view));
    }
    final user = ref.watch(currentUserProvider);
    if (user == null) return const AppScaffold(body: Center(child: Text('Not signed in')));

    return AppScaffold(
      appBar: const AppAppBar(title: Text('Health Monitor')),
      body: FutureBuilder(
        future: ref.read(healthMonitorServiceProvider).latest(user),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final result = snapshot.data!;
          if (result.isFailure) return Center(child: Text(result.failureOrNull?.message ?? 'Error'));
          final health = result.dataOrNull;
          if (health == null) return const Center(child: Text('No health snapshots'));
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              ListTile(title: const Text('Status'), trailing: Text(health.status.value)),
              ListTile(title: const Text('CPU'), trailing: Text('${health.cpuPercent.toStringAsFixed(1)}%')),
              ListTile(title: const Text('Memory'), trailing: Text('${health.memoryMb.toStringAsFixed(0)} MB')),
              ListTile(title: const Text('Captured'), trailing: Text(health.capturedAt.toLocal().toString())),
            ],
          );
        },
      ),
    );
  }
}
