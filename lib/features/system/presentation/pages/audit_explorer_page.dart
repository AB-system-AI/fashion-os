import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_app_bar.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_scaffold.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/states/app_state_widgets.dart';
import 'package:fashion_pos_enterprise/features/system/domain/value_objects/system_value_objects.dart';
import 'package:fashion_pos_enterprise/features/system/presentation/providers/system_providers.dart';

class AuditExplorerPage extends ConsumerWidget {
  const AuditExplorerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canExplore = ref.watch(permissionCheckProvider(AuditExplorerPermissions.explore));
    if (!canExplore) {
      return const AppScaffold(body: PermissionDeniedWidget(permission: AuditExplorerPermissions.explore));
    }
    final user = ref.watch(currentUserProvider);
    if (user == null) return const AppScaffold(body: Center(child: Text('Not signed in')));

    return AppScaffold(
      appBar: const AppAppBar(title: Text('Audit Explorer')),
      body: FutureBuilder(
        future: ref.read(auditExplorerServiceProvider).search(user, const AuditExplorerFilter()),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final result = snapshot.data!;
          if (result.isFailure) return Center(child: Text(result.failureOrNull?.message ?? 'Error'));
          final entries = result.dataOrNull?.items ?? [];
          if (entries.isEmpty) return const Center(child: Text('No audit entries found'));
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: entries.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final e = entries[i];
              return ListTile(
                title: Text('${e.action} · ${e.entityType}'),
                subtitle: Text('${e.entityId ?? '—'} · ${e.createdAt.toLocal()}'),
                leading: const Icon(Icons.history),
              );
            },
          );
        },
      ),
    );
  }
}
