import 'package:flutter/material.dart';

import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';
import 'package:fashion_pos_enterprise/features/analytics/domain/value_objects/analytics_value_objects.dart';

class MetricCard extends StatelessWidget {
  const MetricCard({required this.metric, super.key});

  final MetricValue metric;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final valueText = metric.unit != null
        ? '${metric.value.toStringAsFixed(metric.value.truncateToDouble() == metric.value ? 0 : 1)} ${metric.unit}'
        : metric.value.toStringAsFixed(metric.value.truncateToDouble() == metric.value ? 0 : 1);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(metric.label, style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: AppSpacing.sm),
            Text(valueText, style: theme.textTheme.headlineSmall),
            if (metric.deltaPercent != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                '${metric.deltaPercent! >= 0 ? '+' : ''}${metric.deltaPercent!.toStringAsFixed(1)}%',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: metric.deltaPercent! >= 0 ? Colors.green : Colors.red,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
