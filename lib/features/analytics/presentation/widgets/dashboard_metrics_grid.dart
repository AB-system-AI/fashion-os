import 'package:flutter/material.dart';

import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';
import 'package:fashion_pos_enterprise/features/analytics/domain/value_objects/analytics_value_objects.dart';
import 'package:fashion_pos_enterprise/features/analytics/presentation/widgets/metric_card.dart';

class DashboardMetricsGrid extends StatelessWidget {
  const DashboardMetricsGrid({required this.metrics, super.key});

  final List<MetricValue> metrics;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final crossAxisCount = width >= 1200 ? 4 : width >= 800 ? 3 : width >= 500 ? 2 : 1;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.lg),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        childAspectRatio: 1.8,
      ),
      itemCount: metrics.length,
      itemBuilder: (_, i) => MetricCard(metric: metrics[i]),
    );
  }
}
