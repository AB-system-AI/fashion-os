import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_app_bar.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_scaffold.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/states/app_state_widgets.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/empty/app_empty_state.dart';
import 'package:fashion_pos_enterprise/features/auth/presentation/providers/auth_controller.dart';
import 'package:fashion_pos_enterprise/features/assets/domain/entities/maintenance.dart';
import 'package:fashion_pos_enterprise/features/assets/presentation/providers/assets_providers.dart';

class MaintenancePage extends ConsumerStatefulWidget {
  const MaintenancePage({super.key});

  @override
  ConsumerState<MaintenancePage> createState() => _MaintenancePageState();
}

class _MaintenancePageState extends ConsumerState<MaintenancePage> {
  List<MaintenanceRequest> _requests = const [];
  List<MaintenanceSchedule> _due = const [];
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
    final service = ref.read(maintenanceServiceProvider);
    final open = await service.listOpen(user!.tenantId!);
    final due = await service.listDue(user.tenantId!);
    if (!mounted) return;
    setState(() {
      _requests = open;
      _due = due;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final allowed = ref.watch(permissionCheckProvider(AssetMaintenancePermissions.view));
    if (!allowed) return const AppScaffold(body: PermissionDeniedWidget(permission: AssetMaintenancePermissions.view));
    return AppScaffold(
      appBar: const AppAppBar(title: Text('Maintenance')),
      body: _loading
          ? const AppLoadingWidget()
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  Text('Open Requests', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.sm),
                  if (_requests.isEmpty) const AppEmptyState(message: 'No open maintenance requests'),
                  ..._requests.map((r) => Card(
                        child: ListTile(
                          leading: const Icon(Icons.build_circle_outlined),
                          title: Text(r.title),
                          subtitle: Text('${r.status.value} · Priority ${r.priority}'),
                        ),
                      )),
                  const SizedBox(height: AppSpacing.xl),
                  Text('Due Schedules', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.sm),
                  if (_due.isEmpty) const AppEmptyState(message: 'No schedules due soon'),
                  ..._due.map((s) => Card(
                        child: ListTile(
                          leading: const Icon(Icons.schedule),
                          title: Text(s.name),
                          subtitle: Text(s.nextDueAt?.toLocal().toString() ?? 'No due date'),
                        ),
                      )),
                ],
              ),
            ),
    );
  }
}
