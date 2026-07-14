/// Analytics event hooks — integrate Firebase/Amplitude in production.
abstract final class AnalyticsService {
  static void track(String event, [Map<String, Object?>? properties]) {
    // Extension point: wire to analytics provider
  }

  static void setUserId(String? userId) {}
  static void setTenantId(String? tenantId) {}

  static void trackLogin({required String method, required bool success}) {
    track('login', {'method': method, 'success': success});
  }

  static void trackRegistration({required String method}) {
    track('registration', {'method': method});
  }

  static void trackLogout({required bool allSessions}) {
    track('logout', {'all_sessions': allSessions});
  }
}
