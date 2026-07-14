import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_app_bar.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_scaffold.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/states/app_state_widgets.dart';

typedef AdminListLoader = Future<List<String>> Function(WidgetRef ref);

class AdminListPage extends ConsumerWidget {
  const AdminListPage({
    super.key,
    required this.title,
    required this.permission,
    required this.loadItems,
    this.emptyMessage = 'No records found',
  });

  final String title;
  final String permission;
  final AdminListLoader loadItems;
  final String emptyMessage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canView = ref.watch(permissionCheckProvider(permission));
    if (!canView) {
      return AppScaffold(body: PermissionDeniedWidget(permission: permission));
    }
    return AppScaffold(
      appBar: AppAppBar(title: Text(title)),
      body: FutureBuilder<List<String>>(
        future: loadItems(ref),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snapshot.data ?? [];
          if (items.isEmpty) return Center(child: Text(emptyMessage));
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) => ListTile(title: Text(items[i]), leading: const Icon(Icons.circle_outlined, size: 12)),
          );
        },
      ),
    );
  }
}
