/// Analytics provider contract for Firebase, Supabase, Mixpanel, or custom backends.
abstract class AnalyticsProvider {
  Future<void> initialize();

  Future<void> setUserId(String? userId);

  Future<void> setTenantId(String? tenantId);

  Future<void> trackEvent(String name, {Map<String, Object?> parameters = const {}});

  Future<void> trackScreen(String screenName, {Map<String, Object?> parameters = const {}});

  Future<void> dispose();
}

/// No-op analytics provider for offline/testing.
class NoOpAnalyticsProvider implements AnalyticsProvider {
  @override
  Future<void> initialize() async {}

  @override
  Future<void> setUserId(String? userId) async {}

  @override
  Future<void> setTenantId(String? tenantId) async {}

  @override
  Future<void> trackEvent(String name, {Map<String, Object?> parameters = const {}}) async {}

  @override
  Future<void> trackScreen(String screenName, {Map<String, Object?> parameters = const {}}) async {}

  @override
  Future<void> dispose() async {}
}

/// Multi-provider analytics hub.
class AnalyticsHub {
  AnalyticsHub(this._providers);

  final List<AnalyticsProvider> _providers;

  Future<void> initialize() async {
    for (final provider in _providers) {
      await provider.initialize();
    }
  }

  Future<void> trackEvent(String name, {Map<String, Object?> parameters = const {}}) async {
    for (final provider in _providers) {
      await provider.trackEvent(name, parameters: parameters);
    }
  }

  Future<void> trackScreen(String screenName) async {
    for (final provider in _providers) {
      await provider.trackScreen(screenName);
    }
  }

  Future<void> dispose() async {
    for (final provider in _providers) {
      await provider.dispose();
    }
  }
}
