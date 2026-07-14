import 'package:fashion_pos_enterprise/core/performance/performance_monitor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('track records elapsed time', () {
    final result = PerformanceMonitor.instance.track('test_op', () {
      return 42;
    });
    expect(result, 42);
    expect(PerformanceMonitor.instance.averageMs('test_op'), isNotNull);
  });

  test('trackAsync records elapsed time', () async {
    final result = await PerformanceMonitor.instance.trackAsync('async_op', () async {
      return 'ok';
    });
    expect(result, 'ok');
    expect(PerformanceMonitor.instance.averages.containsKey('async_op'), isTrue);
  });

  test('performance budgets are defined', () {
    expect(PerformanceBudgets.productSearchMs, 100);
    expect(PerformanceBudgets.checkoutMs, 1000);
  });
}
