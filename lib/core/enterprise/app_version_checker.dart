import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:fashion_pos_enterprise/core/enterprise/remote_config_service.dart';

class AppVersionCheckResult {
  const AppVersionCheckResult({
    required this.needsUpdate,
    required this.forceUpdate,
    required this.currentVersion,
    this.minimumVersion,
  });

  final bool needsUpdate;
  final bool forceUpdate;
  final String currentVersion;
  final String? minimumVersion;
}

/// Validates app version against remote minimum version config.
class AppVersionChecker {
  AppVersionChecker(this._remoteConfig);

  final RemoteConfigService _remoteConfig;

  Future<AppVersionCheckResult> check() async {
    final config = await _remoteConfig.fetch();
    final packageInfo = await PackageInfo.fromPlatform();
    final current = packageInfo.version;
    final minConfig = config['min_app_version'] as Map<String, dynamic>? ?? {};
    final forceUpdate = minConfig['force_update'] as bool? ?? false;
    final minVersion = minConfig['android'] as String? ?? current;

    final needsUpdate = _compareVersions(current, minVersion) < 0;
    return AppVersionCheckResult(
      needsUpdate: needsUpdate,
      forceUpdate: forceUpdate && needsUpdate,
      currentVersion: current,
      minimumVersion: minVersion,
    );
  }

  int _compareVersions(String a, String b) {
    final aParts = a.split('.').map(int.parse).toList();
    final bParts = b.split('.').map(int.parse).toList();
    for (var i = 0; i < 3; i++) {
      final av = i < aParts.length ? aParts[i] : 0;
      final bv = i < bParts.length ? bParts[i] : 0;
      if (av != bv) return av.compareTo(bv);
    }
    return 0;
  }
}

final appVersionCheckerProvider = Provider<AppVersionChecker>((ref) {
  return AppVersionChecker(ref.watch(remoteConfigServiceProvider));
});
