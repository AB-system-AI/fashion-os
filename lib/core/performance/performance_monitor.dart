import 'package:fashion_pos_enterprise/core/logging/app_logger.dart';

/// Performance timing hooks for production monitoring integration.
class PerformanceMonitor {
  PerformanceMonitor._();
  static final PerformanceMonitor instance = PerformanceMonitor._();

  final Map<String, List<int>> _samples = {};

  T track<T>(String operation, T Function() action) {
    final stopwatch = Stopwatch()..start();
    try {
      return action();
    } finally {
      stopwatch.stop();
      _record(operation, stopwatch.elapsedMilliseconds);
    }
  }

  Future<T> trackAsync<T>(String operation, Future<T> Function() action) async {
    final stopwatch = Stopwatch()..start();
    try {
      return await action();
    } finally {
      stopwatch.stop();
      _record(operation, stopwatch.elapsedMilliseconds);
    }
  }

  void _record(String operation, int milliseconds) {
    _samples.putIfAbsent(operation, () => []).add(milliseconds);
    if (_samples[operation]!.length > 100) {
      _samples[operation]!.removeAt(0);
    }
    AppLogger.debug('Perf[$operation]: ${milliseconds}ms');
  }

  double? averageMs(String operation) {
    final samples = _samples[operation];
    if (samples == null || samples.isEmpty) return null;
    return samples.reduce((a, b) => a + b) / samples.length;
  }

  Map<String, double> get averages => {
        for (final entry in _samples.entries)
          entry.key: entry.value.reduce((a, b) => a + b) / entry.value.length,
      };
}

/// Performance budgets from enterprise requirements.
abstract final class PerformanceBudgets {
  static const int appStartupMs = 2000;
  static const int productSearchMs = 100;
  static const int barcodeScanMs = 100;
  static const int checkoutMs = 1000;
}
