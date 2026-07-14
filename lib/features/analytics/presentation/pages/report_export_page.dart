import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fashion_pos_enterprise/core/import_export/import_export_service.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_app_bar.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_scaffold.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/states/app_state_widgets.dart';
import 'package:fashion_pos_enterprise/features/analytics/domain/enums/analytics_enums.dart';
import 'package:fashion_pos_enterprise/features/analytics/presentation/providers/analytics_providers.dart';
import 'package:fashion_pos_enterprise/features/auth/presentation/providers/auth_controller.dart';

class ReportExportPage extends ConsumerStatefulWidget {
  const ReportExportPage({super.key});

  @override
  ConsumerState<ReportExportPage> createState() => _ReportExportPageState();
}

class _ReportExportPageState extends ConsumerState<ReportExportPage> {
  ExportFormatType _format = ExportFormatType.csv;
  String? _message;
  bool _loading = false;

  Future<void> _export() async {
    final user = ref.read(authControllerProvider).user;
    if (user?.tenantId == null) return;
    setState(() {
      _loading = true;
      _message = null;
    });
    final reports = await ref.read(reportDefinitionServiceProvider).list(user!.tenantId!);
    if (reports.items.isEmpty) {
      setState(() {
        _loading = false;
        _message = 'Create a report first';
      });
      return;
    }
    final report = reports.items.first;
    final result = await ref.read(analyticsExportServiceProvider).exportReport(
          user: user,
          report: report,
          format: _format,
          rows: [
            {'metric': 'revenue', 'value': 1000},
            {'metric': 'orders', 'value': 42},
          ],
        );
    if (!mounted) return;
    setState(() {
      _loading = false;
      _message = result.isSuccess ? 'Exported ${result.dataOrNull?.fileName}' : result.failureOrNull?.message;
    });
  }

  @override
  Widget build(BuildContext context) {
    final allowed = ref.watch(permissionCheckProvider(ReportPermissions.export));
    if (!allowed) {
      return const AppScaffold(body: PermissionDeniedWidget(permission: ReportPermissions.export));
    }

    return AppScaffold(
      appBar: const AppAppBar(title: Text('Export Report')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Format'),
            const SizedBox(height: AppSpacing.sm),
            SegmentedButton<ExportFormatType>(
              segments: const [
                ButtonSegment(value: ExportFormatType.csv, label: Text('CSV')),
                ButtonSegment(value: ExportFormatType.excel, label: Text('Excel')),
                ButtonSegment(value: ExportFormatType.pdf, label: Text('PDF')),
              ],
              selected: {_format},
              onSelectionChanged: (s) => setState(() => _format = s.first),
            ),
            const SizedBox(height: AppSpacing.xl),
            FilledButton.icon(
              onPressed: _loading ? null : _export,
              icon: _loading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.download),
              label: const Text('Generate export'),
            ),
            if (_message != null) ...[
              const SizedBox(height: AppSpacing.lg),
              Text(_message!),
            ],
          ],
        ),
      ),
    );
  }
}
