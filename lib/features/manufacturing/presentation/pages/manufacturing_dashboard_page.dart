import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_app_bar.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_scaffold.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/states/app_state_widgets.dart';
import 'package:fashion_pos_enterprise/features/manufacturing/routing/manufacturing_route_paths.dart';

class ManufacturingDashboardPage extends ConsumerWidget {
  const ManufacturingDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canView = ref.watch(permissionCheckProvider(ManufacturingPermissions.view));
    if (!canView) {
      return const AppScaffold(body: PermissionDeniedWidget(permission: ManufacturingPermissions.view));
    }

    final width = MediaQuery.sizeOf(context).width;
    final crossAxisCount = width >= 900 ? 3 : width >= 600 ? 2 : 1;

    final tiles = [
      ('BOM List', Icons.account_tree_outlined, ManufacturingRoutePaths.bom),
      ('Production Orders', Icons.precision_manufacturing_outlined, ManufacturingRoutePaths.production),
      ('Work Orders', Icons.engineering_outlined, ManufacturingRoutePaths.workOrders),
      ('Work Centers', Icons.factory_outlined, ManufacturingRoutePaths.workCenters),
      ('Capacity Planning', Icons.timeline, ManufacturingRoutePaths.planning),
      ('Production Schedule', Icons.calendar_month_outlined, ManufacturingRoutePaths.schedule),
      ('Quality', Icons.verified_outlined, ManufacturingRoutePaths.quality),
      ('Maintenance', Icons.build_outlined, ManufacturingRoutePaths.maintenance),
      ('Barcode Actions', Icons.qr_code_scanner, ManufacturingRoutePaths.barcode),
      ('Reports', Icons.summarize_outlined, ManufacturingRoutePaths.reports),
    ];

    return AppScaffold(
      appBar: const AppAppBar(title: Text('Manufacturing')),
      body: GridView.builder(
        padding: const EdgeInsets.all(AppSpacing.lg),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: AppSpacing.md,
          crossAxisSpacing: AppSpacing.md,
          childAspectRatio: width >= 600 ? 2.2 : 2.8,
        ),
        itemCount: tiles.length,
        itemBuilder: (context, i) {
          final t = tiles[i];
          return Card(
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => context.push(t.$3),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    Icon(t.$2, size: 32),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(child: Text(t.$1, style: Theme.of(context).textTheme.titleMedium)),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
