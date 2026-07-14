import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_app_bar.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_scaffold.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/empty/app_empty_state.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/states/app_state_widgets.dart';
import 'package:fashion_pos_enterprise/features/auth/presentation/providers/auth_controller.dart';
import 'package:fashion_pos_enterprise/features/hr/domain/enums/hr_enums.dart';
import 'package:fashion_pos_enterprise/features/hr/presentation/providers/hr_providers.dart';

class HrFeaturePage extends ConsumerStatefulWidget {
  const HrFeaturePage({
    super.key,
    required this.title,
    required this.description,
    required this.permission,
    this.showEmployees = false,
    this.showAttendance = false,
    this.showPayroll = false,
    this.showLeave = false,
  });

  final String title;
  final String description;
  final String permission;
  final bool showEmployees;
  final bool showAttendance;
  final bool showPayroll;
  final bool showLeave;

  @override
  ConsumerState<HrFeaturePage> createState() => _HrFeaturePageState();
}

class _HrFeaturePageState extends ConsumerState<HrFeaturePage> {
  String? _summary;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final user = ref.read(authControllerProvider).user;
    if (user?.tenantId == null) return;
    setState(() => _loading = true);

    if (widget.showEmployees) {
      final page = await ref.read(employeeServiceProvider).list(user!.tenantId!);
      if (mounted) setState(() => _summary = '${page.items.length} employees loaded offline');
    } else if (widget.showAttendance) {
      final records = await ref.read(attendanceServiceProvider).history(user!.tenantId!, user.employeeId ?? '');
      if (mounted) setState(() => _summary = '${records.length} attendance records');
    } else if (widget.showPayroll) {
      final runs = await ref.read(payrollRepositoryProvider).listByPeriod(user!.tenantId!, '');
      if (mounted) setState(() => _summary = '${runs.length} payroll runs');
    } else if (widget.showLeave) {
      final pending = await ref.read(leaveRepositoryProvider).listByStatus(user!.tenantId!, LeaveStatus.pending);
      if (mounted) setState(() => _summary = '${pending.length} pending leave requests');
    }

    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final allowed = ref.watch(permissionCheckProvider(widget.permission));
    if (!allowed) {
      return AppScaffold(body: PermissionDeniedWidget(permission: widget.permission));
    }

    return AppScaffold(
      appBar: AppAppBar(title: Text(widget.title)),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.description, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: AppSpacing.xl),
            if (_loading) const LinearProgressIndicator(),
            if (_summary != null) Text(_summary!, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.lg),
            const AppEmptyState(message: 'Offline-first HR data syncs automatically when online.'),
          ],
        ),
      ),
    );
  }
}
