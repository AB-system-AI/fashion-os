import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_app_bar.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_scaffold.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/states/app_state_widgets.dart';
import 'package:fashion_pos_enterprise/features/auth/presentation/providers/auth_controller.dart';
import 'package:fashion_pos_enterprise/features/integrations/presentation/providers/integrations_providers.dart';

class ImportExportHubPage extends ConsumerWidget {
  const ImportExportHubPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canManage = ref.watch(permissionCheckProvider(IntegrationPermissions.manage));
    if (!canManage) {
      return const AppScaffold(body: PermissionDeniedWidget(permission: IntegrationPermissions.manage));
    }
    final tenantId = ref.watch(authControllerProvider).user?.tenantId;
    return AppScaffold(
      appBar: const AppAppBar(title: Text('Import / Export Hub')),
      body: tenantId == null
          ? const Center(child: Text('Sign in to view jobs'))
          : DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  const TabBar(tabs: [Tab(text: 'Imports'), Tab(text: 'Exports')]),
                  Expanded(
                    child: TabBarView(
                      children: [
                        FutureBuilder(
                          future: ref.read(importExportIntegrationServiceProvider).listImports(tenantId),
                          builder: (context, snapshot) => _JobList(
                            items: snapshot.data?.items.map((j) => '${j.entityType} · ${j.status.value} · ${j.importedRows}/${j.totalRows}').toList() ?? [],
                            loading: !snapshot.hasData,
                            empty: 'No import jobs',
                          ),
                        ),
                        FutureBuilder(
                          future: ref.read(importExportIntegrationServiceProvider).listExports(tenantId),
                          builder: (context, snapshot) => _JobList(
                            items: snapshot.data?.items.map((j) => '${j.entityType} · ${j.status.value} · ${j.rowCount} rows').toList() ?? [],
                            loading: !snapshot.hasData,
                            empty: 'No export jobs',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _JobList extends StatelessWidget {
  const _JobList({required this.items, required this.loading, required this.empty});

  final List<String> items;
  final bool loading;
  final String empty;

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (items.isEmpty) return Center(child: Text(empty));
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: items.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (_, i) => ListTile(title: Text(items[i])),
    );
  }
}
