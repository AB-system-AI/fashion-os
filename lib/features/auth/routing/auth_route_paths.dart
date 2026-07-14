/// Auth feature route paths.
abstract final class AuthRoutePaths {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String verifyEmail = '/verify-email';
  static const String inviteAccepted = '/invite-accepted';
  static const String noAccess = '/no-access';
  static const String sessionExpired = '/session-expired';
  static const String maintenance = '/maintenance';
  static const String home = '/';
}

abstract final class AuthRouteNames {
  static const String splash = 'splash';
  static const String onboarding = 'onboarding';
  static const String welcome = 'welcome';
  static const String login = 'login';
  static const String register = 'register';
  static const String forgotPassword = 'forgotPassword';
  static const String resetPassword = 'resetPassword';
  static const String verifyEmail = 'verifyEmail';
  static const String inviteAccepted = 'inviteAccepted';
  static const String noAccess = 'noAccess';
  static const String sessionExpired = 'sessionExpired';
  static const String maintenance = 'maintenance';
  static const String home = 'home';
}

/// Routes that do not require authentication.
const authPublicRoutes = <String>{
  AuthRoutePaths.splash,
  AuthRoutePaths.onboarding,
  AuthRoutePaths.welcome,
  AuthRoutePaths.login,
  AuthRoutePaths.register,
  AuthRoutePaths.forgotPassword,
  AuthRoutePaths.resetPassword,
  AuthRoutePaths.verifyEmail,
  AuthRoutePaths.inviteAccepted,
  AuthRoutePaths.maintenance,
  AuthRoutePaths.sessionExpired,
};
