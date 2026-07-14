import 'package:fashion_pos_enterprise/features/analytics/domain/value_objects/analytics_value_objects.dart';

class GrowthResult {
  const GrowthResult({required this.current, required this.previous, required this.growthPercent});

  final double current;
  final double previous;
  final double growthPercent;
}

class VarianceResult {
  const VarianceResult({required this.planned, required this.actual, required this.variance, required this.variancePercent});

  final double planned;
  final double actual;
  final double variance;
  final double variancePercent;
}

class TopPerformer<T> {
  const TopPerformer({required this.item, required this.value});

  final T item;
  final double value;
}

class ExecutiveSummary {
  const ExecutiveSummary({
    required this.revenue,
    required this.grossProfit,
    required this.inventoryValue,
    required this.payrollCost,
    required this.productionEfficiency,
    required this.customerCount,
  });

  final double revenue;
  final double grossProfit;
  final double inventoryValue;
  final double payrollCost;
  final double productionEfficiency;
  final int customerCount;
}

/// Pure analytics rules: KPIs, trends, forecasts, comparisons.
class AnalyticsEngine {
  double growthPercent({required double current, required double previous}) {
    if (previous == 0) return current > 0 ? 100 : 0;
    return _round(((current - previous) / previous) * 100);
  }

  GrowthResult periodOverPeriod({required double current, required double previous}) {
    return GrowthResult(current: current, previous: previous, growthPercent: growthPercent(current: current, previous: previous));
  }

  double rollingAverage(List<double> values, {int window = 3}) {
    if (values.isEmpty) return 0;
    final slice = values.length <= window ? values : values.sublist(values.length - window);
    return _round(slice.fold(0.0, (s, v) => s + v) / slice.length);
  }

  VarianceResult calculateVariance({required double planned, required double actual}) {
    final variance = actual - planned;
    final variancePercent = planned != 0 ? _round((variance / planned) * 100) : 0;
    return VarianceResult(planned: planned, actual: actual, variance: _round(variance), variancePercent: variancePercent);
  }

  double marginPercent({required double revenue, required double cost}) {
    if (revenue <= 0) return 0;
    return _round(((revenue - cost) / revenue) * 100);
  }

  double averageOrderValue({required double revenue, required int orderCount}) {
    if (orderCount <= 0) return 0;
    return _round(revenue / orderCount);
  }

  double refundRate({required double refundTotal, required double revenue}) {
    if (revenue <= 0) return 0;
    return _round((refundTotal / revenue) * 100);
  }

  double stockTurnover({required double cogs, required double averageInventory}) {
    if (averageInventory <= 0) return 0;
    return _round(cogs / averageInventory);
  }

  double coverageDays({required double onHand, required double dailyUsage}) {
    if (dailyUsage <= 0) return 0;
    return _round(onHand / dailyUsage);
  }

  double churnRate({required int lostCustomers, required int totalCustomers}) {
    if (totalCustomers <= 0) return 0;
    return _round((lostCustomers / totalCustomers) * 100);
  }

  double attendanceRate({required int presentDays, required int scheduledDays}) {
    if (scheduledDays <= 0) return 0;
    return _round((presentDays / scheduledDays) * 100);
  }

  double oee({required double availability, required double performance, required double quality}) {
    return _round((availability / 100) * (performance / 100) * (quality / 100) * 100);
  }

  double capacityUtilization({required double utilizedHours, required double availableHours}) {
    if (availableHours <= 0) return 0;
    return _round((utilizedHours / availableHours) * 100);
  }

  double currentRatio({required double currentAssets, required double currentLiabilities}) {
    if (currentLiabilities <= 0) return 0;
    return _round(currentAssets / currentLiabilities);
  }

  List<TrendPoint> buildTrend(List<({DateTime period, double value})> raw) {
    return raw.map((r) => TrendPoint(period: r.period, value: r.value)).toList();
  }

  List<MetricValue> compareMetrics(List<MetricValue> current, List<MetricValue> previous) {
    final prevMap = {for (final m in previous) m.label: m.value};
    return current
        .map((m) {
          final prev = prevMap[m.label] ?? 0;
          return MetricValue(
            label: m.label,
            value: m.value,
            unit: m.unit,
            delta: _round(m.value - prev),
            deltaPercent: growthPercent(current: m.value, previous: prev),
          );
        })
        .toList();
  }

  List<TopPerformer<String>> topPerformers(Map<String, double> values, {int limit = 10, bool ascending = false}) {
    final entries = values.entries.toList()
      ..sort((a, b) => ascending ? a.value.compareTo(b.value) : b.value.compareTo(a.value));
    return entries.take(limit).map((e) => TopPerformer(item: e.key, value: e.value)).toList();
  }

  double simpleForecast(List<double> history, {int periodsAhead = 1}) {
    if (history.isEmpty) return 0;
    if (history.length == 1) return history.first;
    final avg = rollingAverage(history);
    final last = history.last;
    return _round(last + (avg - last) * 0.5 * periodsAhead);
  }

  ExecutiveSummary buildExecutiveSummary({
    required double revenue,
    required double cogs,
    required double inventoryValue,
    required double payrollCost,
    required double productionEfficiency,
    required int customerCount,
  }) {
    return ExecutiveSummary(
      revenue: revenue,
      grossProfit: _round(revenue - cogs),
      inventoryValue: inventoryValue,
      payrollCost: payrollCost,
      productionEfficiency: productionEfficiency,
      customerCount: customerCount,
    );
  }

  double _round(double v) => double.parse(v.toStringAsFixed(4));
}
