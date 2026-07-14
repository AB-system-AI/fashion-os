import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fashion_pos_enterprise/core/auth/sync_tenant_context.dart';
import 'package:fashion_pos_enterprise/core/enterprise/analytics_service.dart';
import 'package:fashion_pos_enterprise/core/enterprise/crash_reporting_service.dart';
import 'package:fashion_pos_enterprise/core/enterprise/remote_config_service.dart';
import 'package:fashion_pos_enterprise/core/logging/app_logger.dart';
import 'package:fashion_pos_enterprise/features/auth/domain/entities/auth_state.dart';
import 'package:fashion_pos_enterprise/features/auth/domain/entities/auth_user.dart';
import 'package:fashion_pos_enterprise/features/auth/domain/entities/owner_registration.dart';
import 'package:fashion_pos_enterprise/features/auth/presentation/providers/auth_providers.dart';
import 'package:fashion_pos_enterprise/core/services/local_storage_service.dart';
import 'package:fashion_pos_enterprise/features/auth/domain/constants/auth_storage_keys.dart';

class AuthController extends Notifier<AuthState> {
  StreamSubscription<AuthUser?>? _authSub;

  @override
  AuthState build() {
    final repository = ref.read(authRepositoryProvider);
    final remoteConfig = ref.read(remoteConfigServiceProvider);

    ref.onDispose(() => _authSub?.cancel());

    _authSub = repository.watchAuthUser().listen(_onAuthUserChanged);
    unawaited(_initialize(remoteConfig));

    return const AuthState(isLoading: true);
  }

  Future<void> _initialize(RemoteConfigService remoteConfig) async {
    try {
      await remoteConfig.fetch();
      if (remoteConfig.isMaintenanceMode) {
        state = state.copyWith(
          status: AuthStatus.maintenance,
          isLoading: false,
        );
      }
    } catch (e) {
      AppLogger.warning('Remote config fetch failed', e);
    }
  }

  void _onAuthUserChanged(AuthUser? user) {
    if (user == null) {
      SyncTenantContext.clear();
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        clearUser: true,
        isLoading: false,
        clearError: true,
      );
      AnalyticsService.setUserId(null);
      return;
    }

    if (!user.emailVerified) {
      state = state.copyWith(
        status: AuthStatus.emailUnverified,
        user: user,
        isLoading: false,
      );
      return;
    }

    if (!user.hasOrganization || !user.isActive) {
      state = state.copyWith(
        status: AuthStatus.noAccess,
        user: user,
        isLoading: false,
      );
      return;
    }

    AnalyticsService.setUserId(user.userId);
    AnalyticsService.setTenantId(user.tenantId);
    CrashReportingService.setUser(user.userId, email: user.email, tenantId: user.tenantId);
    SyncTenantContext.update(tenantId: user.tenantId);

    state = state.copyWith(
      status: AuthStatus.authenticated,
      user: user,
      isLoading: false,
      clearError: true,
    );
  }

  Future<bool> signIn({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await ref.read(authRepositoryProvider).signIn(
          email: email.trim(),
          password: password,
          rememberMe: rememberMe,
        );
    return result.fold(
      onSuccess: (_) {
        state = state.copyWith(isLoading: false);
        return true;
      },
      onFailure: (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        return false;
      },
    );
  }

  Future<bool> registerOwner(OwnerRegistration registration) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await ref.read(authRepositoryProvider).registerOwner(registration);
    return result.fold(
      onSuccess: (_) {
        state = state.copyWith(isLoading: false);
        return true;
      },
      onFailure: (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        return false;
      },
    );
  }

  Future<bool> signOut({bool allSessions = false}) async {
    state = state.copyWith(isLoading: true);
    final result = await ref.read(authRepositoryProvider).signOut(
          revokeAllSessions: allSessions,
        );
    return result.fold(
      onSuccess: (_) {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          clearUser: true,
          isLoading: false,
        );
        return true;
      },
      onFailure: (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        return false;
      },
    );
  }

  Future<bool> sendPasswordReset(String email) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await ref.read(authRepositoryProvider).sendPasswordResetEmail(email.trim());
    return result.fold(
      onSuccess: (_) {
        state = state.copyWith(isLoading: false);
        return true;
      },
      onFailure: (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        return false;
      },
    );
  }

  Future<bool> resendVerification() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await ref.read(authRepositoryProvider).resendVerificationEmail();
    return result.fold(
      onSuccess: (_) {
        state = state.copyWith(isLoading: false);
        return true;
      },
      onFailure: (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        return false;
      },
    );
  }

  Future<bool> acceptInvitation(String token) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await ref.read(authRepositoryProvider).acceptInvitation(token);
    return result.fold(
      onSuccess: (_) {
        state = state.copyWith(isLoading: false);
        return true;
      },
      onFailure: (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        return false;
      },
    );
  }

  bool get hasSeenOnboarding {
    return ref.read(localStorageServiceProvider).getBool(AuthStorageKeys.onboardingSeen) ?? false;
  }

  Future<void> markOnboardingSeen() async {
    await ref.read(localStorageServiceProvider).setBool(AuthStorageKeys.onboardingSeen, true);
  }
}

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);
