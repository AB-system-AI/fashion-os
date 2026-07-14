import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_app_bar.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_scaffold.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/states/app_state_widgets.dart';
import 'package:fashion_pos_enterprise/features/system/presentation/providers/system_providers.dart';

class DiagnosticsPage extends ConsumerWidget {
  const DiagnosticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canManage = ref.watch(permissionCheckProvider(SystemPermissions.manage));
    if (!canManage) {
      return const AppScaffold(body: PermissionDeniedWidget(permission: SystemPermissions.manage));
    }
    final user = ref.watch(currentUserProvider);
    if (user == null) return const AppScaffold(body: Center(child: Text('Not signed in')));

    return AppScaffold(
      appBar: const AppAppBar(title: Text('Diagnostics')),
      body: FutureBuilder(
        future: ref.read(diagnosticsServiceProvider).run(user),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final result = snapshot.data!;
          if (result.isFailure) return Center(child: Text(result.failureOrNull?.message ?? 'Error'));
          final report = result.dataOrNull!;
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              ListTile(title: const Text('App'), trailing: Text(report.appVersion)),
              ListTile(title: const Text('Flavor'), trailing: Text(report.flavor)),
              ListTile(title: const Text('Database'), trailing: Icon(report.databaseOk ? Icons.check : Icons.close)),
              ListTile(title: const Text('Sync state'), trailing: Text(report.syncState)),
              ListTile(title: const Text('Pending queue'), trailing: Text('${report.pendingQueue}')),
              ListTile(title: const Text('Network'), trailing: Text(report.networkOnline ? 'Online' : 'Offline')),
              ListTile(title: const Text('Generated'), trailing: Text(report.generatedAt.toLocal().toString())),
            ],
          );
        },
      ),
    );
  }
}
