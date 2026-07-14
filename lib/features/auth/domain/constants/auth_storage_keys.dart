/// Auth-specific storage keys (extends core StorageKeys).
abstract final class AuthStorageKeys {
  static const String rememberMe = 'auth_remember_me';
  static const String lastEmail = 'auth_last_email';
  static const String currentSessionId = 'auth_current_session_id';
  static const String onboardingSeen = 'auth_onboarding_seen';
  static const String biometricEnabled = 'auth_biometric_enabled';
}
