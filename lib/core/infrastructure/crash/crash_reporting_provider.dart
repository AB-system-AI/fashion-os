/// Crash reporting provider contract for Crashlytics, Sentry, or custom backends.
abstract class CrashReportingProvider {
  Future<void> initialize();

  Future<void> captureException(
    Object error,
    StackTrace stackTrace, {
    String? reason,
    Map<String, Object?>? extras,
  });

  Future<void> setUser({
    String? userId,
    String? email,
    String? tenantId,
  });

  Future<void> addBreadcrumb(String message, {Map<String, Object?> data});

  Future<void> dispose();
}

/// No-op crash provider.
class NoOpCrashReportingProvider implements CrashReportingProvider {
  @override
  Future<void> initialize() async {}

  @override
  Future<void> captureException(
    Object error,
    StackTrace stackTrace, {
    String? reason,
    Map<String, Object?> extras = const {},
  }) async {}

  @override
  Future<void> setUser({String? userId, String? email, String? tenantId}) async {}

  @override
  Future<void> addBreadcrumb(String message, {Map<String, Object?> data = const {}}) async {}

  @override
  Future<void> dispose() async {}
}

/// Multi-provider crash reporting hub.
class CrashReportingHub {
  CrashReportingHub(this._providers);

  final List<CrashReportingProvider> _providers;

  Future<void> initialize() async {
    for (final provider in _providers) {
      await provider.initialize();
    }
  }

  Future<void> captureException(
    Object error,
    StackTrace stackTrace, {
    String? reason,
    Map<String, Object?> extras = const {},
  }) async {
    for (final provider in _providers) {
      await provider.captureException(error, stackTrace, reason: reason, extras: extras);
    }
  }

  Future<void> dispose() async {
    for (final provider in _providers) {
      await provider.dispose();
    }
  }
}
