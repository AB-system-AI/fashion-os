import 'package:flutter_test/flutter_test.dart';

import 'package:fashion_pos_enterprise/core/business/engines/analytics/analytics_engine.dart';
import 'package:fashion_pos_enterprise/features/analytics/domain/value_objects/analytics_value_objects.dart';

void main() {
  late AnalyticsEngine engine;

  setUp(() {
    engine = AnalyticsEngine();
  });

  test('growthPercent handles zero previous', () {
    expect(engine.growthPercent(current: 100, previous: 0), 100);
    expect(engine.growthPercent(current: 0, previous: 0), 0);
  });

  test('periodOverPeriod returns growth result', () {
    final result = engine.periodOverPeriod(current: 150, previous: 100);
    expect(result.growthPercent, 50);
    expect(result.current, 150);
    expect(result.previous, 100);
  });

  test('rollingAverage uses trailing window', () {
    expect(engine.rollingAverage([10, 20, 30, 40], window: 2), 35);
  });

  test('calculateVariance computes percent', () {
    final v = engine.calculateVariance(planned: 100, actual: 120);
    expect(v.variance, 20);
    expect(v.variancePercent, 20);
  });

  test('margin and AOV calculations', () {
    expect(engine.marginPercent(revenue: 200, cost: 50), 75);
    expect(engine.averageOrderValue(revenue: 1000, orderCount: 4), 250);
  });

  test('refundRate and stockTurnover', () {
    expect(engine.refundRate(refundTotal: 10, revenue: 100), 10);
    expect(engine.stockTurnover(cogs: 500, averageInventory: 100), 5);
  });

  test('oee multiplies factors', () {
    expect(engine.oee(availability: 90, performance: 95, quality: 98), closeTo(83.79, 0.1));
  });

  test('compareMetrics adds deltas', () {
    final current = [const MetricValue(label: 'Revenue', value: 120)];
    final previous = [const MetricValue(label: 'Revenue', value: 100)];
    final compared = engine.compareMetrics(current, previous);
    expect(compared.first.delta, 20);
    expect(compared.first.deltaPercent, 20);
  });

  test('topPerformers sorts descending', () {
    final top = engine.topPerformers({'a': 10, 'b': 50, 'c': 30}, limit: 2);
    expect(top.first.item, 'b');
    expect(top.last.item, 'c');
  });

  test('simpleForecast extrapolates from history', () {
    expect(engine.simpleForecast([100, 110, 120]), greaterThan(120));
  });

  test('buildExecutiveSummary computes gross profit', () {
    final summary = engine.buildExecutiveSummary(
      revenue: 1000,
      cogs: 400,
      inventoryValue: 5000,
      payrollCost: 200,
      productionEfficiency: 88,
      customerCount: 42,
    );
    expect(summary.grossProfit, 600);
    expect(summary.customerCount, 42);
  });
}
