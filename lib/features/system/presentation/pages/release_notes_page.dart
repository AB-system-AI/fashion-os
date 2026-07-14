import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_app_bar.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_scaffold.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/states/app_state_widgets.dart';
import 'package:fashion_pos_enterprise/features/system/presentation/providers/system_providers.dart';

class ReleaseNotesPage extends ConsumerWidget {
  const ReleaseNotesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canView = ref.watch(permissionCheckProvider(SystemPermissions.view));
    if (!canView) {
      return const AppScaffold(body: PermissionDeniedWidget(permission: SystemPermissions.view));
    }
    final user = ref.watch(currentUserProvider);
    if (user == null) return const AppScaffold(body: Center(child: Text('Not signed in')));

    return AppScaffold(
      appBar: const AppAppBar(title: Text('Release Notes')),
      body: FutureBuilder(
        future: ref.read(releaseNotesServiceProvider).list(user),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final result = snapshot.data!;
          if (result.isFailure) return Center(child: Text(result.failureOrNull?.message ?? 'Error'));
          final notes = result.dataOrNull ?? [];
          if (notes.isEmpty) return const Center(child: Text('No release notes'));
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: notes.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final n = notes[i];
              return ListTile(
                title: Text('${n.appVersion} — ${n.title}'),
                subtitle: Text(n.publishedAt.toLocal().toString()),
                isThreeLine: true,
              );
            },
          );
        },
      ),
    );
  }
}
