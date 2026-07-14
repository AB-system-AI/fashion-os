import 'dart:convert';

import 'package:drift/drift.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/database/app_database.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/network/network_monitor.dart';
import 'package:fashion_pos_enterprise/core/enterprise/remote_config_service.dart';

/// Feature flag evaluation source.
enum FeatureFlagSource { remote, localCache, defaultValue }

/// Evaluated feature flag.
class FeatureFlagValue {
  const FeatureFlagValue({
    required this.key,
    required this.enabled,
    required this.source,
    this.variant,
    this.payload = const {},
  });

  final String key;
  final bool enabled;
  final String? variant;
  final Map<String, dynamic> payload;
  final FeatureFlagSource source;
}

/// Remote + local cached feature flag system with offline support.
class FeatureFlagService {
  FeatureFlagService({
    required AppDatabase database,
    required RemoteConfigService remoteConfig,
    required NetworkMonitor networkMonitor,
    this.cacheTtl = const Duration(hours: 24),
  })  : _db = database,
        _remoteConfig = remoteConfig,
        _network = networkMonitor;

  final AppDatabase _db;
  final RemoteConfigService _remoteConfig;
  final NetworkMonitor _network;
  final Duration cacheTtl;

  Future<void> refresh({bool force = false}) async {
    final online = (await _network.currentState).isOnline;
    if (!online && !force) return;

    final config = await _remoteConfig.fetch(force: force);
    final flags = config['feature_flags'] as Map<String, dynamic>? ?? {};
    final now = DateTime.now().toUtc();
    final expires = now.add(cacheTtl);

    for (final entry in flags.entries) {
      await _db.featureFlagDao.upsert(
        FeatureFlagEntriesCompanion.insert(
          key: entry.key,
          value: jsonEncode(entry.value),
          source: const Value('remote'),
          fetchedAt: now,
          expiresAt: Value(expires),
        ),
      );
    }
    await _db.featureFlagDao.clearExpired();
  }

  Future<FeatureFlagValue> isEnabled(
    String key, {
    bool defaultValue = false,
  }) async {
    final cached = await _readCache(key);
    if (cached != null) {
      return _fromCached(key, cached, defaultValue);
    }

    if (_remoteConfig.isFeatureEnabled(key, defaultValue: defaultValue)) {
      return FeatureFlagValue(
        key: key,
        enabled: true,
        source: FeatureFlagSource.remote,
      );
    }

    return FeatureFlagValue(
      key: key,
      enabled: defaultValue,
      source: FeatureFlagSource.defaultValue,
    );
  }

  Future<bool> isOfflineModeEnabled() => (await isEnabled('offline_mode', defaultValue: true)).enabled;

  FeatureFlagValue _fromCached(String key, FeatureFlagEntry cached, bool defaultValue) {
    final decoded = jsonDecode(cached.value);
    if (decoded is bool) {
      return FeatureFlagValue(key: key, enabled: decoded, source: FeatureFlagSource.localCache);
    }
    if (decoded is Map<String, dynamic>) {
      return FeatureFlagValue(
        key: key,
        enabled: decoded['enabled'] as bool? ?? defaultValue,
        variant: decoded['variant'] as String?,
        payload: decoded,
        source: FeatureFlagSource.localCache,
      );
    }
    return FeatureFlagValue(
      key: key,
      enabled: defaultValue,
      source: FeatureFlagSource.localCache,
    );
  }

  Future<FeatureFlagEntry?> _readCache(String key) async {
    final rows = await _db.featureFlagDao.getAll();
    final now = DateTime.now().toUtc();
    for (final row in rows) {
      if (row.key != key) continue;
      if (row.expiresAt != null && row.expiresAt!.isBefore(now)) return null;
      return row;
    }
    return null;
  }
}
