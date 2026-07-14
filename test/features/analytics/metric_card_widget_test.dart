import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fashion_pos_enterprise/features/analytics/domain/value_objects/analytics_value_objects.dart';
import 'package:fashion_pos_enterprise/features/analytics/presentation/widgets/metric_card.dart';

void main() {
  testWidgets('MetricCard renders label and value', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MetricCard(metric: MetricValue(label: 'Revenue', value: 1200, unit: 'USD')),
        ),
      ),
    );
    expect(find.text('Revenue'), findsOneWidget);
    expect(find.textContaining('1200'), findsOneWidget);
  });
}
