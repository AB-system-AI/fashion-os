import 'package:fashion_pos_enterprise/core/errors/error_handler.dart';
import 'package:fashion_pos_enterprise/core/errors/failure.dart';
import 'package:fashion_pos_enterprise/core/logging/app_logger.dart';
import 'package:fashion_pos_enterprise/core/result/result.dart';
import 'package:fashion_pos_enterprise/core/security/device_info_service.dart';
import 'package:fashion_pos_enterprise/core/services/local_storage_service.dart';
import 'package:fashion_pos_enterprise/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:fashion_pos_enterprise/features/auth/domain/constants/auth_storage_keys.dart';
import 'package:fashion_pos_enterprise/features/auth/domain/entities/auth_user.dart';
import 'package:fashion_pos_enterprise/features/auth/domain/entities/device_session.dart';
import 'package:fashion_pos_enterprise/features/auth/domain/entities/owner_registration.dart';
import 'package:fashion_pos_enterprise/features/auth/domain/repositories/auth_repository.dart';
import 'package:fashion_pos_enterprise/core/enterprise/analytics_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required LocalStorageService localStorage,
    required DeviceInfoService deviceInfo,
  })  : _remote = remoteDataSource,
        _localStorage = localStorage,
        _deviceInfo = deviceInfo;

  final AuthRemoteDataSource _remote;
  final LocalStorageService _localStorage;
  final DeviceInfoService _deviceInfo;
  String? _currentSessionId;

  @override
  Stream<AuthUser?> watchAuthUser() => _remote.watchAuthUser();

  @override
  Future<Result<AuthUser>> signIn({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    try {
      if (await _remote.isLoginLocked(email)) {
        return const Error(AuthFailure(message: 'account_locked'));
      }

      final response = await _remote.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        await _remote.recordLoginAttempt(
          email: email,
          success: false,
          failureReason: 'invalid_credentials',
        );
        return const Error(AuthFailure(message: 'invalid_credentials'));
      }

      await _remote.recordLoginAttempt(email: email, success: true);
      await _localStorage.setBool(AuthStorageKeys.rememberMe, rememberMe);
      if (rememberMe) {
        await _localStorage.setString(AuthStorageKeys.lastEmail, email);
      }

      if (response.user!.appMetadata['tenant_id'] == null) {
        await _remote.updateUserClaims();
      }

      await _registerDeviceSession(rememberMe);

      final user = _remote.currentUser;
      AnalyticsService.trackLogin(method: 'email', success: true);
      return Success(user!);
    } catch (e, st) {
      AppLogger.error('Sign in failed', e, st);
      await _remote.recordLoginAttempt(
        email: email,
        success: false,
        failureReason: e.toString(),
      );
      AnalyticsService.trackLogin(method: 'email', success: false);
      return Error(ErrorHandler.handle(e, st));
    }
  }

  @override
  Future<Result<OrganizationContext>> registerOwner(
    OwnerRegistration registration,
  ) async {
    try {
      final signUpResponse = await _remote.signUp(
        email: registration.email,
        password: registration.password,
        fullName: registration.fullName,
      );

      if (signUpResponse.user == null) {
        return const Error(AuthFailure(message: 'registration_failed'));
      }

      final org = await _remote.registerOwnerOrganization(
        tenantName: registration.tenantName,
        tenantSlug: registration.tenantSlug,
        storeName: registration.storeName,
        fullName: registration.fullName,
        storeCode: registration.storeCode,
        currency: registration.currency,
        timezone: registration.timezone,
        country: registration.country,
      );

      await _remote.updateUserClaims();
      await _registerDeviceSession(true);

      AnalyticsService.trackRegistration(method: 'email');
      return Success(OrganizationContext.fromJson(org));
    } catch (e, st) {
      AppLogger.error('Owner registration failed', e, st);
      return Error(ErrorHandler.handle(e, st));
    }
  }

  @override
  Future<Result<void>> signOut({bool revokeAllSessions = false}) async {
    try {
      if (revokeAllSessions) {
        await _remote.revokeAllSessions(exceptSessionId: _currentSessionId);
      } else if (_currentSessionId != null) {
        await _remote.revokeSession(_currentSessionId!);
      }
      await _remote.signOut();
      _currentSessionId = null;
      AnalyticsService.trackLogout(allSessions: revokeAllSessions);
      return const Success(null);
    } catch (e, st) {
      return Error(ErrorHandler.handle(e, st));
    }
  }

  @override
  Future<Result<void>> resendVerificationEmail() async {
    try {
      final email = _remote.currentUser?.email;
      if (email == null) return const Error(AuthFailure(message: 'not_authenticated'));
      await _remote.resendVerificationEmail(email);
      return const Success(null);
    } catch (e, st) {
      return Error(ErrorHandler.handle(e, st));
    }
  }

  @override
  Future<Result<void>> sendPasswordResetEmail(String email) async {
    try {
      await _remote.resetPasswordForEmail(email);
      return const Success(null);
    } catch (e, st) {
      return Error(ErrorHandler.handle(e, st));
    }
  }

  @override
  Future<Result<void>> updatePassword(String newPassword) async {
    try {
      await _remote.updatePassword(newPassword);
      return const Success(null);
    } catch (e, st) {
      return Error(ErrorHandler.handle(e, st));
    }
  }

  @override
  Future<Result<void>> refreshClaims() async {
    try {
      await _remote.updateUserClaims();
      return const Success(null);
    } catch (e, st) {
      return Error(ErrorHandler.handle(e, st));
    }
  }

  @override
  Future<Result<List<DeviceSession>>> getActiveSessions() async {
    try {
      final userId = _remote.currentUser?.userId;
      if (userId == null) return const Error(AuthFailure(message: 'not_authenticated'));
      final deviceId = await _deviceInfo.getDeviceId();
      final rows = await _remote.getActiveSessions(userId);
      return Success(
        rows.map((r) => DeviceSession.fromJson(r, currentDeviceId: deviceId)).toList(),
      );
    } catch (e, st) {
      return Error(ErrorHandler.handle(e, st));
    }
  }

  @override
  Future<Result<void>> revokeSession(String sessionId) async {
    try {
      await _remote.revokeSession(sessionId);
      return const Success(null);
    } catch (e, st) {
      return Error(ErrorHandler.handle(e, st));
    }
  }

  @override
  Future<Result<void>> revokeAllSessions({String? exceptSessionId}) async {
    try {
      await _remote.revokeAllSessions(exceptSessionId: exceptSessionId);
      return const Success(null);
    } catch (e, st) {
      return Error(ErrorHandler.handle(e, st));
    }
  }

  @override
  Future<Result<void>> acceptInvitation(String token) async {
    try {
      await _remote.acceptInvitation(token);
      await _remote.updateUserClaims();
      return const Success(null);
    } catch (e, st) {
      return Error(ErrorHandler.handle(e, st));
    }
  }

  @override
  Future<bool> isLoginLocked(String email) => _remote.isLoginLocked(email);

  Future<void> _registerDeviceSession(bool rememberMe) async {
    final sessionId = await _remote.registerDeviceSession(
      deviceId: await _deviceInfo.getDeviceId(),
      deviceName: await _deviceInfo.getDeviceName(),
      platform: await _deviceInfo.getPlatform(),
      appVersion: await _deviceInfo.getAppVersion(),
      rememberMe: rememberMe,
    );
    _currentSessionId = sessionId;
    await _localStorage.setString(AuthStorageKeys.currentSessionId, sessionId);
  }
}
