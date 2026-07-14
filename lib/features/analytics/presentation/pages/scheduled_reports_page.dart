import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_app_bar.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_scaffold.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/states/app_state_widgets.dart';
import 'package:fashion_pos_enterprise/features/analytics/domain/entities/dashboard.dart';
import 'package:fashion_pos_enterprise/features/analytics/domain/enums/analytics_enums.dart';
import 'package:fashion_pos_enterprise/features/analytics/presentation/providers/analytics_providers.dart';
import 'package:fashion_pos_enterprise/features/auth/presentation/providers/auth_controller.dart';

class ScheduledReportsPage extends ConsumerStatefulWidget {
  const ScheduledReportsPage({super.key});

  @override
  ConsumerState<ScheduledReportsPage> createState() => _ScheduledReportsPageState();
}

class _ScheduledReportsPageState extends ConsumerState<ScheduledReportsPage> {
  List<ScheduledReport> _scheduled = const [];
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
    final items = await ref.read(reportSchedulingServiceProvider).listActive(user!.tenantId!);
    if (!mounted) return;
    setState(() {
      _scheduled = items;
      _loading = false;
    });
  }

  Future<void> _runNow(ScheduledReport item) async {
    final user = ref.read(authControllerProvider).user;
    if (user == null) return;
    await ref.read(reportSchedulingServiceProvider).executeNow(user: user, scheduled: item);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report executed')));
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final allowed = ref.watch(permissionCheckProvider(ReportPermissions.schedule));
    if (!allowed) {
      return const AppScaffold(body: PermissionDeniedWidget(permission: ReportPermissions.schedule));
    }

    return AppScaffold(
      appBar: const AppAppBar(title: Text('Scheduled Reports')),
      body: _loading
          ? const AppLoadingWidget()
          : RefreshIndicator(
              onRefresh: _load,
              child: _scheduled.isEmpty
                  ? ListView(children: const [SizedBox(height: 120), Center(child: Text('No scheduled reports'))])
                  : ListView.separated(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      itemCount: _scheduled.length,
                      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, i) {
                        final s = _scheduled[i];
                        return Card(
                          child: ListTile(
                            title: Text('Report ${s.reportId.substring(0, 8)}…'),
                            subtitle: Text(
                              '${s.frequency.value} · next: ${s.nextExecutionAt?.toLocal().toString().split('.').first ?? '—'}',
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.play_arrow),
                              onPressed: () => _runNow(s),
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
