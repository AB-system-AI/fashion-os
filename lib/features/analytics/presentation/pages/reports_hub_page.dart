import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_app_bar.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_scaffold.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/states/app_state_widgets.dart';
import 'package:fashion_pos_enterprise/features/analytics/domain/entities/report.dart';
import 'package:fashion_pos_enterprise/features/analytics/domain/enums/analytics_enums.dart';
import 'package:fashion_pos_enterprise/features/analytics/presentation/providers/analytics_providers.dart';
import 'package:fashion_pos_enterprise/features/analytics/routing/analytics_route_paths.dart';
import 'package:fashion_pos_enterprise/features/auth/presentation/providers/auth_controller.dart';

class ReportsHubPage extends ConsumerStatefulWidget {
  const ReportsHubPage({super.key});

  @override
  ConsumerState<ReportsHubPage> createState() => _ReportsHubPageState();
}

class _ReportsHubPageState extends ConsumerState<ReportsHubPage> {
  List<ReportDefinition> _reports = const [];
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
    final page = await ref.read(reportDefinitionServiceProvider).list(user!.tenantId!);
    if (!mounted) return;
    setState(() {
      _reports = page.items;
      _loading = false;
    });
  }

  Future<void> _createSample() async {
    final user = ref.read(authControllerProvider).user;
    if (user == null) return;
    final now = DateTime.now().toUtc();
    await ref.read(reportDefinitionServiceProvider).create(
          user: user,
          draft: ReportDefinition(
            id: '',
            tenantId: user.tenantId!,
            name: 'Sales Summary ${now.day}/${now.month}',
            module: 'sales',
            version: 1,
            createdAt: now,
            updatedAt: now,
            syncStatus: LocalSyncStatus.pending,
            isDirty: true,
            status: ReportStatus.draft,
            columns: const ['revenue', 'orders', 'aov'],
          ),
        );
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final allowed = ref.watch(permissionCheckProvider(ReportPermissions.view));
    if (!allowed) {
      return const AppScaffold(body: PermissionDeniedWidget(permission: ReportPermissions.view));
    }
    final canCreate = ref.watch(permissionCheckProvider(ReportPermissions.create));

    return AppScaffold(
      appBar: AppAppBar(
        title: const Text('Reports'),
        actions: [
          IconButton(icon: const Icon(Icons.schedule), tooltip: 'Scheduled', onPressed: () => context.push(AnalyticsRoutePaths.scheduledReports)),
          IconButton(icon: const Icon(Icons.copy_all), tooltip: 'Templates', onPressed: () => context.push(AnalyticsRoutePaths.reportTemplates)),
          IconButton(icon: const Icon(Icons.file_download_outlined), tooltip: 'Export', onPressed: () => context.push(AnalyticsRoutePaths.reportExport)),
        ],
      ),
      floatingActionButton: canCreate
          ? FloatingActionButton.extended(
              onPressed: _createSample,
              icon: const Icon(Icons.add),
              label: const Text('New report'),
            )
          : null,
      body: _loading
          ? const AppLoadingWidget()
          : RefreshIndicator(
              onRefresh: _load,
              child: _reports.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 120),
                        Center(child: Text('No saved reports yet')),
                      ],
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      itemCount: _reports.length,
                      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, i) {
                        final r = _reports[i];
                        return Card(
                          child: ListTile(
                            title: Text(r.name),
                            subtitle: Text('${r.module} · ${r.status.value}'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => context.push(AnalyticsRoutePaths.reportDetail(r.id)),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
