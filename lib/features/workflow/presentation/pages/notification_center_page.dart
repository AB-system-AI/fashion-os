import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_app_bar.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_scaffold.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/states/app_state_widgets.dart';
import 'package:fashion_pos_enterprise/features/auth/presentation/providers/auth_controller.dart';
import 'package:fashion_pos_enterprise/features/workflow/domain/entities/notification.dart';
import 'package:fashion_pos_enterprise/features/workflow/domain/enums/workflow_enums.dart';
import 'package:fashion_pos_enterprise/features/workflow/presentation/providers/workflow_providers.dart';

class NotificationCenterPage extends ConsumerWidget {
  const NotificationCenterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canView = ref.watch(permissionCheckProvider(NotificationCenterPermissions.view));
    if (!canView) {
      return const AppScaffold(body: PermissionDeniedWidget(permission: NotificationCenterPermissions.view));
    }
    final user = ref.watch(authControllerProvider).user;
    if (user == null) {
      return const AppScaffold(body: Center(child: Text('Not authenticated')));
    }
    return AppScaffold(
      appBar: const AppAppBar(title: Text('Notifications')),
      body: FutureBuilder(
        future: ref.read(notificationCenterServiceProvider).listUnread(user),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final result = snapshot.data;
          if (result == null || result.isFailure) {
            return Center(child: Text(result?.failureOrNull?.message ?? 'Failed to load notifications'));
          }
          final items = result.dataOrNull ?? [];
          if (items.isEmpty) {
            return const Center(child: Text('No unread notifications'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, i) => _NotificationTile(item: items[i]),
          );
        },
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.item});

  final NotificationCenterItem item;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(
          item.priority == NotificationPriority.urgent ? Icons.priority_high : Icons.notifications,
        ),
        title: Text(item.title),
        subtitle: Text(item.body),
        trailing: Text(item.status.value),
      ),
    );
  }
}
