import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_app_bar.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_scaffold.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/states/app_state_widgets.dart';
import 'package:fashion_pos_enterprise/features/hr/routing/hr_route_paths.dart';

class HrDashboardPage extends ConsumerWidget {
  const HrDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canView = ref.watch(permissionCheckProvider(HrPermissions.view));
    if (!canView) {
      return const AppScaffold(body: PermissionDeniedWidget(permission: HrPermissions.view));
    }

    final width = MediaQuery.sizeOf(context).width;
    final crossAxisCount = width >= 900 ? 3 : width >= 600 ? 2 : 1;

    final tiles = [
      ('Employees', Icons.people_outline, HrRoutePaths.employees),
      ('Departments', Icons.corporate_fare_outlined, HrRoutePaths.departments),
      ('Positions', Icons.work_outline, HrRoutePaths.positions),
      ('Attendance', Icons.fingerprint, HrRoutePaths.attendance),
      ('Attendance History', Icons.history, HrRoutePaths.attendanceHistory),
      ('Shifts', Icons.schedule, HrRoutePaths.shifts),
      ('Leave Requests', Icons.beach_access_outlined, HrRoutePaths.leaveRequests),
      ('Payroll', Icons.payments_outlined, HrRoutePaths.payroll),
      ('Salary Structures', Icons.account_balance_wallet_outlined, HrRoutePaths.salaryStructures),
      ('Bonuses', Icons.card_giftcard_outlined, HrRoutePaths.bonuses),
      ('Deductions', Icons.remove_circle_outline, HrRoutePaths.deductions),
      ('Commissions', Icons.trending_up, HrRoutePaths.commissions),
      ('Performance Reviews', Icons.star_outline, HrRoutePaths.performanceReviews),
      ('Employee Documents', Icons.folder_open_outlined, HrRoutePaths.documents),
      ('Reports', Icons.summarize_outlined, HrRoutePaths.reports),
    ];

    return AppScaffold(
      appBar: const AppAppBar(title: Text('Human Resources')),
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
