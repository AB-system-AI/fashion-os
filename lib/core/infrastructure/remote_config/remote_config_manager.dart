import 'package:fashion_pos_enterprise/core/enterprise/app_version_checker.dart';
import 'package:fashion_pos_enterprise/core/enterprise/remote_config_service.dart';

/// Remote configuration manager with maintenance, version, and dynamic settings.
class RemoteConfigManager {
  RemoteConfigManager({
    required RemoteConfigService remoteConfig,
    required AppVersionChecker versionChecker,
  })  : _remoteConfig = remoteConfig,
        _versionChecker = versionChecker;

  final RemoteConfigService _remoteConfig;
  final AppVersionChecker _versionChecker;

  Future<RemoteConfigSnapshot> fetch({bool force = false}) async {
    final config = await _remoteConfig.fetch(force: force);
    final version = await _versionChecker.check();
    return RemoteConfigSnapshot(
      config: config,
      isMaintenanceMode: _remoteConfig.isMaintenanceMode,
      maintenanceMessage: _remoteConfig.maintenanceMessage,
      needsUpdate: version.needsUpdate,
      forceUpdate: version.forceUpdate,
      currentVersion: version.currentVersion,
      minimumVersion: version.minimumVersion,
    );
  }

  bool isFeatureEnabled(String key, {bool defaultValue = false}) {
    return _remoteConfig.isFeatureEnabled(key, defaultValue: defaultValue);
  }
}

class RemoteConfigSnapshot {
  const RemoteConfigSnapshot({
    required this.config,
    required this.isMaintenanceMode,
    required this.needsUpdate,
    required this.forceUpdate,
    required this.currentVersion,
    this.maintenanceMessage,
    this.minimumVersion,
  });

  final Map<String, dynamic> config;
  final bool isMaintenanceMode;
  final String? maintenanceMessage;
  final bool needsUpdate;
  final bool forceUpdate;
  final String currentVersion;
  final String? minimumVersion;
}
