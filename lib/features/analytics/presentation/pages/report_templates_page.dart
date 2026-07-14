import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_app_bar.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_scaffold.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/states/app_state_widgets.dart';
import 'package:fashion_pos_enterprise/features/analytics/domain/entities/report.dart';
import 'package:fashion_pos_enterprise/features/analytics/presentation/providers/analytics_providers.dart';
import 'package:fashion_pos_enterprise/features/auth/presentation/providers/auth_controller.dart';

class ReportTemplatesPage extends ConsumerStatefulWidget {
  const ReportTemplatesPage({super.key});

  @override
  ConsumerState<ReportTemplatesPage> createState() => _ReportTemplatesPageState();
}

class _ReportTemplatesPageState extends ConsumerState<ReportTemplatesPage> {
  List<ReportTemplate> _templates = const [];
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
    final templates = await ref.read(reportRepositoryProvider).listTemplates(user!.tenantId!);
    if (!mounted) return;
    setState(() {
      _templates = templates;
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
      appBar: const AppAppBar(title: Text('Report Templates')),
      body: _loading
          ? const AppLoadingWidget()
          : ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: _templates.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, i) {
                final t = _templates[i];
                return Card(
                  child: ListTile(
                    title: Text(t.name),
                    subtitle: Text('${t.module}${t.isSystem ? ' · system' : ''}'),
                  ),
                );
              },
            ),
    );
  }
}
