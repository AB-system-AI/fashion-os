import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_app_bar.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_scaffold.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/states/app_state_widgets.dart';
import 'package:fashion_pos_enterprise/features/analytics/presentation/providers/analytics_providers.dart';
import 'package:fashion_pos_enterprise/features/auth/presentation/providers/auth_controller.dart';

class ReportDetailPage extends ConsumerStatefulWidget {
  const ReportDetailPage({required this.reportId, super.key});

  final String reportId;

  @override
  ConsumerState<ReportDetailPage> createState() => _ReportDetailPageState();
}

class _ReportDetailPageState extends ConsumerState<ReportDetailPage> {
  dynamic _report;
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
    final report = await ref.read(reportRepositoryProvider).getById(widget.reportId, tenantId: user!.tenantId);
    if (!mounted) return;
    setState(() {
      _report = report;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final allowed = ref.watch(permissionCheckProvider(ReportPermissions.view));
    if (!allowed) {
      return const AppScaffold(body: PermissionDeniedWidget(permission: ReportPermissions.view));
    }

    return AppScaffold(
      appBar: AppAppBar(title: Text(_report?.name ?? 'Report')),
      body: _loading
          ? const AppLoadingWidget()
          : _report == null
              ? const AppErrorWidget(message: 'Report not found')
              : ListView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  children: [
                    ListTile(title: const Text('Module'), subtitle: Text(_report.module)),
                    ListTile(title: const Text('Status'), subtitle: Text(_report.status.value)),
                    ListTile(title: const Text('Columns'), subtitle: Text(_report.columns.join(', '))),
                    if (_report.groupBy != null) ListTile(title: const Text('Group by'), subtitle: Text(_report.groupBy!)),
                  ],
                ),
    );
  }
}
