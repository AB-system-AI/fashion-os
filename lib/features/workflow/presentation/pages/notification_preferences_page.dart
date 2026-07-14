import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fashion_pos_enterprise/core/business/domain/enums/business_enums.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_app_bar.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_scaffold.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/states/app_state_widgets.dart';
import 'package:fashion_pos_enterprise/features/workflow/domain/entities/notification_queue.dart';

class NotificationPreferencesPage extends ConsumerStatefulWidget {
  const NotificationPreferencesPage({super.key});

  @override
  ConsumerState<NotificationPreferencesPage> createState() => _NotificationPreferencesPageState();
}

class _NotificationPreferencesPageState extends ConsumerState<NotificationPreferencesPage> {
  final _channels = <NotificationChannel, bool>{
    for (final c in NotificationChannel.values) c: true,
  };
  var _quietStart = 22;
  var _quietEnd = 7;

  @override
  Widget build(BuildContext context) {
    final canView = ref.watch(permissionCheckProvider(NotificationCenterPermissions.manage));
    if (!canView) {
      return const AppScaffold(body: PermissionDeniedWidget(permission: NotificationCenterPermissions.manage));
    }
    return AppScaffold(
      appBar: const AppAppBar(title: Text('Notification Preferences')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text('Channels', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          ..._channels.entries.map((e) => SwitchListTile(
                title: Text(e.key.name),
                value: e.value,
                onChanged: (v) => setState(() => _channels[e.key] = v),
              )),
          const Divider(height: AppSpacing.xl),
          Text('Quiet hours (UTC)', style: Theme.of(context).textTheme.titleMedium),
          ListTile(
            title: Text('$_quietStart:00 – $_quietEnd:00'),
            subtitle: Text(QuietHours(startHour: _quietStart, endHour: _quietEnd).timezone),
            trailing: const Icon(Icons.bedtime_outlined),
          ),
          Slider(
            value: _quietStart.toDouble(),
            min: 0,
            max: 23,
            divisions: 23,
            label: 'Start $_quietStart',
            onChanged: (v) => setState(() => _quietStart = v.round()),
          ),
          Slider(
            value: _quietEnd.toDouble(),
            min: 0,
            max: 23,
            divisions: 23,
            label: 'End $_quietEnd',
            onChanged: (v) => setState(() => _quietEnd = v.round()),
          ),
        ],
      ),
    );
  }
}
