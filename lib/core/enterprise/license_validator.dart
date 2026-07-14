import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fashion_pos_enterprise/core/enterprise/remote_config_service.dart';

/// Subscription license validation architecture.
/// Validates tenant subscription status against remote data.
class LicenseValidator {
  LicenseValidator(this._remoteConfig);

  final RemoteConfigService _remoteConfig;

  Future<LicenseStatus> validate({
    required String? tenantId,
    required String? subscriptionStatus,
  }) async {
    await _remoteConfig.fetch();
    if (_remoteConfig.isMaintenanceMode) {
      return LicenseStatus.maintenance;
    }
    if (tenantId == null) return LicenseStatus.unlicensed;

    return switch (subscriptionStatus) {
      'active' || 'trialing' => LicenseStatus.valid,
      'past_due' => LicenseStatus.gracePeriod,
      'cancelled' || 'expired' => LicenseStatus.expired,
      _ => LicenseStatus.unknown,
    };
  }
}

enum LicenseStatus { valid, gracePeriod, expired, unlicensed, maintenance, unknown }

final licenseValidatorProvider = Provider<LicenseValidator>((ref) {
  return LicenseValidator(ref.watch(remoteConfigServiceProvider));
});
