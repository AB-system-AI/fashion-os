enum OrgUnitStatus {
  active('active'),
  inactive('inactive'),
  archived('archived');

  const OrgUnitStatus(this.value);
  final String value;

  static OrgUnitStatus fromValue(String? v) =>
      OrgUnitStatus.values.firstWhere((e) => e.value == v, orElse: () => OrgUnitStatus.active);
}

enum AdminUserStatus {
  active('active'),
  suspended('suspended'),
  invited('invited'),
  deactivated('deactivated');

  const AdminUserStatus(this.value);
  final String value;

  static AdminUserStatus fromValue(String? v) =>
      AdminUserStatus.values.firstWhere((e) => e.value == v, orElse: () => AdminUserStatus.active);
}

enum LicenseStatus {
  trial('trial'),
  active('active'),
  expired('expired'),
  suspended('suspended');

  const LicenseStatus(this.value);
  final String value;

  static LicenseStatus fromValue(String? v) =>
      LicenseStatus.values.firstWhere((e) => e.value == v, orElse: () => LicenseStatus.trial);
}

enum SubscriptionTier {
  starter('starter'),
  professional('professional'),
  enterprise('enterprise');

  const SubscriptionTier(this.value);
  final String value;

  static SubscriptionTier fromValue(String? v) =>
      SubscriptionTier.values.firstWhere((e) => e.value == v, orElse: () => SubscriptionTier.starter);
}

enum HealthStatus {
  healthy('healthy'),
  degraded('degraded'),
  critical('critical'),
  unknown('unknown');

  const HealthStatus(this.value);
  final String value;

  static HealthStatus fromValue(String? v) =>
      HealthStatus.values.firstWhere((e) => e.value == v, orElse: () => HealthStatus.unknown);
}

enum SettingsScope {
  tenant('tenant'),
  company('company'),
  branch('branch');

  const SettingsScope(this.value);
  final String value;

  static SettingsScope fromValue(String? v) =>
      SettingsScope.values.firstWhere((e) => e.value == v, orElse: () => SettingsScope.tenant);
}
