import 'package:fashion_pos_enterprise/core/enterprise/analytics_service.dart';
import 'package:fashion_pos_enterprise/core/enterprise/crash_reporting_service.dart';
import 'package:fashion_pos_enterprise/core/logging/app_logger.dart';
import 'package:fashion_pos_enterprise/core/performance/performance_monitor.dart';

/// Unified monitoring facade for crash, analytics, errors, and performance.
class MonitoringHub {
  Future<void> initialize() async {
    await CrashReportingService.initialize();
    AppLogger.info('MonitoringHub initialized');
  }

  void recordError(Object error, StackTrace stackTrace, {String? context}) {
    AppLogger.error(context ?? 'Unhandled error', error, stackTrace);
    CrashReportingService.captureException(error, stackTrace);
  }

  void trackEvent(String name, {Map<String, Object?> parameters = const {}}) {
    AnalyticsService.track(name, parameters);
  }

  void trackScreen(String screenName) {
    AnalyticsService.track('screen_view', {'screen': screenName});
  }

  T trackPerformance<T>(String operation, T Function() action) {
    return PerformanceMonitor.instance.track(operation, action);
  }

  Future<T> trackPerformanceAsync<T>(
    String operation,
    Future<T> Function() action,
  ) {
    return PerformanceMonitor.instance.trackAsync(operation, action);
  }

  Map<String, double> get performanceAverages => PerformanceMonitor.instance.averages;
}
