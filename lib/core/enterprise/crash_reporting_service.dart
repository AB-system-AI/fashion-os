/// Crash reporting hooks — integrate Sentry/Crashlytics in production.
abstract final class CrashReportingService {
  static Future<void> initialize() async {}

  static void captureException(Object error, [StackTrace? stackTrace]) {}

  static void setUser(String? userId, {String? email, String? tenantId}) {}

  static void addBreadcrumb(String message, {Map<String, Object?>? data}) {}
}
