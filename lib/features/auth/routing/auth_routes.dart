import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:fashion_pos_enterprise/app/pages/foundation_page.dart';
import 'package:fashion_pos_enterprise/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:fashion_pos_enterprise/features/auth/presentation/pages/invite_accepted_page.dart';
import 'package:fashion_pos_enterprise/features/auth/presentation/pages/login_page.dart';
import 'package:fashion_pos_enterprise/features/auth/presentation/pages/maintenance_page.dart';
import 'package:fashion_pos_enterprise/features/auth/presentation/pages/no_access_page.dart';
import 'package:fashion_pos_enterprise/features/auth/presentation/pages/onboarding_page.dart';
import 'package:fashion_pos_enterprise/features/auth/presentation/pages/register_page.dart';
import 'package:fashion_pos_enterprise/features/auth/presentation/pages/session_expired_page.dart';
import 'package:fashion_pos_enterprise/features/auth/presentation/pages/splash_page.dart';
import 'package:fashion_pos_enterprise/features/auth/presentation/pages/verify_email_page.dart';
import 'package:fashion_pos_enterprise/features/auth/presentation/pages/welcome_page.dart';
import 'package:fashion_pos_enterprise/features/auth/routing/auth_route_paths.dart';

List<RouteBase> buildAuthRoutes() {
  return [
    GoRoute(
      path: AuthRoutePaths.splash,
      name: AuthRouteNames.splash,
      pageBuilder: (context, state) => _fade(const SplashPage(), state),
    ),
    GoRoute(
      path: AuthRoutePaths.onboarding,
      name: AuthRouteNames.onboarding,
      pageBuilder: (context, state) => _fade(const OnboardingPage(), state),
    ),
    GoRoute(
      path: AuthRoutePaths.welcome,
      name: AuthRouteNames.welcome,
      pageBuilder: (context, state) => _fade(const WelcomePage(), state),
    ),
    GoRoute(
      path: AuthRoutePaths.login,
      name: AuthRouteNames.login,
      pageBuilder: (context, state) => _slide(const LoginPage(), state),
    ),
    GoRoute(
      path: AuthRoutePaths.register,
      name: AuthRouteNames.register,
      pageBuilder: (context, state) => _slide(const RegisterPage(), state),
    ),
    GoRoute(
      path: AuthRoutePaths.forgotPassword,
      name: AuthRouteNames.forgotPassword,
      pageBuilder: (context, state) => _slide(const ForgotPasswordPage(), state),
    ),
    GoRoute(
      path: AuthRoutePaths.verifyEmail,
      name: AuthRouteNames.verifyEmail,
      pageBuilder: (context, state) => _fade(const VerifyEmailPage(), state),
    ),
    GoRoute(
      path: AuthRoutePaths.inviteAccepted,
      name: AuthRouteNames.inviteAccepted,
      pageBuilder: (context, state) => _fade(
        InviteAcceptedPage(token: state.uri.queryParameters['token']),
        state,
      ),
    ),
    GoRoute(
      path: AuthRoutePaths.noAccess,
      name: AuthRouteNames.noAccess,
      pageBuilder: (context, state) => _fade(const NoAccessPage(), state),
    ),
    GoRoute(
      path: AuthRoutePaths.sessionExpired,
      name: AuthRouteNames.sessionExpired,
      pageBuilder: (context, state) => _fade(const SessionExpiredPage(), state),
    ),
    GoRoute(
      path: AuthRoutePaths.maintenance,
      name: AuthRouteNames.maintenance,
      pageBuilder: (context, state) => _fade(const MaintenancePage(), state),
    ),
    GoRoute(
      path: AuthRoutePaths.home,
      name: AuthRouteNames.home,
      pageBuilder: (context, state) => _fade(const FoundationPage(), state),
    ),
  ];
}

CustomTransitionPage<void> _fade(Widget child, GoRouterState state) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, _, child) =>
        FadeTransition(opacity: animation, child: child),
  );
}

CustomTransitionPage<void> _slide(Widget child, GoRouterState state) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, _, child) {
      final offset = Tween<Offset>(
        begin: const Offset(0.05, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
      return SlideTransition(
        position: offset,
        child: FadeTransition(opacity: animation, child: child),
      );
    },
  );
}
