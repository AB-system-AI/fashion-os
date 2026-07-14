import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/core/result/result.dart';
import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_app_bar.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_scaffold.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/states/app_state_widgets.dart';
import 'package:fashion_pos_enterprise/features/analytics/domain/enums/analytics_enums.dart';
import 'package:fashion_pos_enterprise/features/analytics/domain/services/analytics_services.dart';
import 'package:fashion_pos_enterprise/features/analytics/domain/value_objects/analytics_value_objects.dart';
import 'package:fashion_pos_enterprise/features/analytics/presentation/providers/analytics_providers.dart';
import 'package:fashion_pos_enterprise/features/analytics/presentation/widgets/analytics_chart_widget.dart';
import 'package:fashion_pos_enterprise/features/analytics/presentation/widgets/dashboard_metrics_grid.dart';
import 'package:fashion_pos_enterprise/features/auth/presentation/providers/auth_controller.dart';

class ModuleDashboardPage extends ConsumerStatefulWidget {
  const ModuleDashboardPage({
    required this.type,
    required this.permission,
    super.key,
  });

  final DashboardType type;
  final String permission;

  @override
  ConsumerState<ModuleDashboardPage> createState() => _ModuleDashboardPageState();
}

class _ModuleDashboardPageState extends ConsumerState<ModuleDashboardPage> {
  DashboardBundle? _bundle;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  Future<void> _load() async {
    final user = ref.read(authControllerProvider).user;
    if (user?.tenantId == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final service = ref.read(dashboardServiceProvider);
    final Result<DashboardBundle> result = await switch (widget.type) {
      DashboardType.executive => service.executive(user: user!),
      DashboardType.sales => service.sales(user: user!),
      DashboardType.inventory => service.inventory(user: user!),
      DashboardType.purchasing => service.purchasing(user: user!),
      DashboardType.crm => service.crm(user: user!),
      DashboardType.accounting => service.accounting(user: user!),
      DashboardType.hr => service.hr(user: user!),
      DashboardType.manufacturing => service.manufacturing(user: user!),
    };
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (result.isSuccess) {
        _bundle = result.dataOrNull;
      } else {
        _error = result.failureOrNull?.message;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final allowed = ref.watch(permissionCheckProvider(widget.permission));
    if (!allowed) {
      return AppScaffold(body: PermissionDeniedWidget(permission: widget.permission));
    }

    return AppScaffold(
      appBar: AppAppBar(title: Text(_bundle?.title ?? widget.type.name)),
      body: _loading
          ? const AppLoadingWidget()
          : _error != null
              ? AppErrorWidget(message: _error!, onRetry: _load)
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    children: [
                      if (_bundle != null) DashboardMetricsGrid(metrics: _bundle!.metrics),
                      if (_bundle != null && _bundle!.series.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                          child: AnalyticsChartWidget(
                            title: 'Trend',
                            series: _bundle!.series,
                            chartType: ChartType.line,
                          ),
                        )
                      else if (_bundle != null)
                        Padding(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: AnalyticsChartWidget(
                            title: 'Overview',
                            series: [
                              ChartSeries(
                                name: 'Metrics',
                                points: _bundle!.metrics
                                    .map((m) => TrendPoint(period: DateTime.now(), value: m.value))
                                    .toList(),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: AppSpacing.xl),
                    ],
                  ),
                ),
    );
  }
}
