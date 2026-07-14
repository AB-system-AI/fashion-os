import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_app_bar.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_scaffold.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/states/app_state_widgets.dart';
import 'package:fashion_pos_enterprise/features/system/presentation/providers/system_providers.dart';

class PermissionManagerPage extends ConsumerWidget {
  const PermissionManagerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canManage = ref.watch(permissionCheckProvider(SystemPermissions.manage));
    if (!canManage) {
      return const AppScaffold(body: PermissionDeniedWidget(permission: SystemPermissions.manage));
    }
    final user = ref.watch(currentUserProvider);
    if (user == null) return const AppScaffold(body: Center(child: Text('Not signed in')));

    return AppScaffold(
      appBar: const AppAppBar(title: Text('Permission Manager')),
      body: FutureBuilder(
        future: ref.read(tenantAdminServiceProvider).listAssignments(user, 'employee', user.employeeId ?? ''),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final result = snapshot.data!;
          if (result.isFailure) return Center(child: Text(result.failureOrNull?.message ?? 'Error'));
          final items = result.dataOrNull ?? [];
          if (items.isEmpty) return const Center(child: Text('No permission assignments'));
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final p = items[i];
              return ListTile(
                title: Text(p.permissionCode),
                subtitle: Text('${p.subjectType} · ${p.subjectId}'),
                leading: const Icon(Icons.vpn_key_outlined),
              );
            },
          );
        },
      ),
    );
  }
}
