import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_app_bar.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_scaffold.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/states/app_state_widgets.dart';
import 'package:fashion_pos_enterprise/features/auth/presentation/providers/auth_controller.dart';
import 'package:fashion_pos_enterprise/features/automation/domain/entities/scheduled_job.dart';
import 'package:fashion_pos_enterprise/features/automation/domain/enums/automation_enums.dart';
import 'package:fashion_pos_enterprise/features/automation/domain/value_objects/automation_value_objects.dart';
import 'package:fashion_pos_enterprise/features/automation/presentation/providers/automation_providers.dart';

class ScheduledJobsPage extends ConsumerStatefulWidget {
  const ScheduledJobsPage({super.key});

  @override
  ConsumerState<ScheduledJobsPage> createState() => _ScheduledJobsPageState();
}

class _ScheduledJobsPageState extends ConsumerState<ScheduledJobsPage> {
  List<ScheduledJob> _items = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  Future<void> _load() async {
    final user = ref.read(authControllerProvider).user;
    if (user?.tenantId == null) return;
    setState(() => _loading = true);
    final items = await ref.read(schedulerServiceProvider).list(user!.tenantId!);
    if (!mounted) return;
    setState(() {
      _items = items;
      _loading = false;
    });
  }

  Future<void> _createSample() async {
    final user = ref.read(authControllerProvider).user;
    if (user == null) return;
    await ref.read(schedulerServiceProvider).schedule(
          user: user,
          name: 'Daily report',
          spec: ScheduleSpec(
            scheduleType: JobScheduleType.cron,
            cronExpression: '0 8 * * *',
          ),
          payload: const {'action': 'generate_report'},
        );
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final allowed = ref.watch(permissionCheckProvider(AutomationPermissions.view));
    if (!allowed) return const AppScaffold(body: PermissionDeniedWidget(permission: AutomationPermissions.view));
    final canManage = ref.watch(permissionCheckProvider(SchedulerPermissions.manage));
    return AppScaffold(
      appBar: const AppAppBar(title: Text('Scheduled Jobs')),
      floatingActionButton: canManage ? FloatingActionButton.extended(onPressed: _createSample, icon: const Icon(Icons.add), label: const Text('Schedule')) : null,
      body: _loading
          ? const AppLoadingWidget()
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: _items.length,
                separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                itemBuilder: (_, i) {
                  final j = _items[i];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.schedule),
                      title: Text(j.name),
                      subtitle: Text('${j.scheduleType.value} · next: ${j.nextRunAt?.toLocal().toString().split('.').first ?? '—'}'),
                      trailing: Chip(label: Text(j.status.value)),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
