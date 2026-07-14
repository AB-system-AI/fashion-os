enum FeatureFlagScope {
  global,
  tenant,
  store,
  user;

  String get value => name;

  static FeatureFlagScope fromValue(String? v) =>
      FeatureFlagScope.values.firstWhere((e) => e.name == v, orElse: () => FeatureFlagScope.tenant);
}

enum HealthStatus {
  healthy,
  degraded,
  unhealthy,
  unknown;

  String get value => name;

  static HealthStatus fromValue(String? v) =>
      HealthStatus.values.firstWhere((e) => e.name == v, orElse: () => HealthStatus.unknown);
}

enum JobRunStatus {
  pending,
  running,
  completed,
  failed,
  cancelled;

  String get value => name;

  static JobRunStatus fromValue(String? v) =>
      JobRunStatus.values.firstWhere((e) => e.name == v, orElse: () => JobRunStatus.pending);
}

enum ErrorSeverity {
  debug,
  info,
  warning,
  error,
  critical;

  String get value => name;

  static ErrorSeverity fromValue(String? v) =>
      ErrorSeverity.values.firstWhere((e) => e.name == v, orElse: () => ErrorSeverity.error);
}

enum LicenseStatus {
  valid,
  gracePeriod,
  expired,
  suspended,
  unknown;

  String get value => name;

  static LicenseStatus fromValue(String? v) =>
      LicenseStatus.values.firstWhere((e) => e.name == v, orElse: () => LicenseStatus.unknown);
}

enum SubscriptionStatus {
  active,
  trialing,
  pastDue,
  cancelled,
  paused;

  String get value => name;

  static SubscriptionStatus fromValue(String? v) =>
      SubscriptionStatus.values.firstWhere((e) => e.name == v, orElse: () => SubscriptionStatus.active);
}

enum SessionStatus {
  active,
  expired,
  revoked;

  String get value => name;

  static SessionStatus fromValue(String? v) =>
      SessionStatus.values.firstWhere((e) => e.name == v, orElse: () => SessionStatus.active);
}

enum DeviceTrustLevel {
  trusted,
  unknown,
  blocked;

  String get value => name;

  static DeviceTrustLevel fromValue(String? v) =>
      DeviceTrustLevel.values.firstWhere((e) => e.name == v, orElse: () => DeviceTrustLevel.unknown);
}

enum MaintenanceScope {
  global,
  tenant,
  module;

  String get value => name;

  static MaintenanceScope fromValue(String? v) =>
      MaintenanceScope.values.firstWhere((e) => e.name == v, orElse: () => MaintenanceScope.tenant);
}

enum EnvironmentType {
  development,
  staging,
  production;

  String get value => name;

  static EnvironmentType fromValue(String? v) =>
      EnvironmentType.values.firstWhere((e) => e.name == v, orElse: () => EnvironmentType.production);
}

enum MigrationStatus {
  pending,
  applied,
  failed,
  rolledBack;

  String get value => name;

  static MigrationStatus fromValue(String? v) =>
      MigrationStatus.values.firstWhere((e) => e.name == v, orElse: () => MigrationStatus.pending);
}
