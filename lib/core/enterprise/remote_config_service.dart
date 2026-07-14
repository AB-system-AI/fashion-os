import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:fashion_pos_enterprise/core/config/app_config.dart';
import 'package:fashion_pos_enterprise/core/di/providers.dart';
import 'package:fashion_pos_enterprise/core/services/supabase_service.dart';

/// Remote configuration and feature flags service.
class RemoteConfigService {
  RemoteConfigService(this._client, this._config);

  final SupabaseClient _client;
  final AppConfig _config;

  Map<String, dynamic> _cache = {};
  DateTime? _lastFetch;

  Future<Map<String, dynamic>> fetch({bool force = false}) async {
    if (!force &&
        _lastFetch != null &&
        DateTime.now().difference(_lastFetch!) < const Duration(minutes: 15)) {
      return _cache;
    }

    final response = await _client
        .from('remote_config')
        .select('key, value')
        .eq('is_active', true);

    final configs = response as List<dynamic>;
    _cache = {
      for (final row in configs)
        row['key'] as String: row['value'] as Map<String, dynamic>,
    };
    _lastFetch = DateTime.now();
    return _cache;
  }

  bool isFeatureEnabled(String flag, {bool defaultValue = false}) {
    final flags = _cache['feature_flags'] as Map<String, dynamic>?;
    if (flags == null) return defaultValue;
    return flags[flag] as bool? ?? defaultValue;
  }

  bool get isMaintenanceMode {
    final maintenance = _cache['maintenance_mode'] as Map<String, dynamic>?;
    return maintenance?['enabled'] as bool? ?? false;
  }

  String? get maintenanceMessage {
    final maintenance = _cache['maintenance_mode'] as Map<String, dynamic>?;
    final msg = maintenance?['message'] as String?;
    return msg != null && msg.isNotEmpty ? msg : null;
  }

  bool get isOfflineModeEnabled => isFeatureEnabled('offline_mode', defaultValue: true);
}

final remoteConfigServiceProvider = Provider<RemoteConfigService>((ref) {
  return RemoteConfigService(
    ref.watch(supabaseClientProvider),
    ref.watch(appConfigProvider),
  );
});
