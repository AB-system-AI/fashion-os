import 'package:fashion_pos_enterprise/core/errors/app_exception.dart';
import 'package:fashion_pos_enterprise/core/logging/app_logger.dart';
import 'package:fashion_pos_enterprise/features/auth/data/mappers/auth_user_mapper.dart';
import 'package:fashion_pos_enterprise/features/auth/domain/entities/auth_user.dart';
import 'package:fashion_pos_enterprise/features/auth/domain/entities/owner_registration.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._client);

  final SupabaseClient _client;

  GoTrueClient get _auth => _client.auth;

  Stream<AuthUser?> watchAuthUser() {
    return _auth.onAuthStateChange.map((event) {
      final session = event.session;
      if (session == null) return null;
      return _mapUser(session);
    });
  }

  AuthUser? get currentUser {
    final session = _auth.currentSession;
    if (session == null) return null;
    return _mapUser(session);
  }

  AuthUser _mapUser(Session session) => AuthUserMapper.fromSession(session);

  Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) {
    return _auth.signInWithPassword(email: email, password: password);
  }

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
  }) {
    return _auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName},
    );
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> resendVerificationEmail(String email) {
    return _auth.resend(type: OtpType.signup, email: email);
  }

  Future<void> resetPasswordForEmail(String email) {
    return _auth.resetPasswordForEmail(email);
  }

  Future<UserResponse> updatePassword(String newPassword) {
    return _auth.updateUser(UserAttributes(password: newPassword));
  }

  Future<Map<String, dynamic>> registerOwnerOrganization({
    required String tenantName,
    required String tenantSlug,
    required String storeName,
    required String fullName,
    String storeCode = 'MAIN',
    String currency = 'USD',
    String timezone = 'UTC',
    String country = 'US',
  }) async {
    final result = await _client.rpc<Map<String, dynamic>>(
      'register_owner_organization',
      params: {
        'p_tenant_name': tenantName,
        'p_tenant_slug': tenantSlug,
        'p_store_name': storeName,
        'p_store_code': storeCode,
        'p_currency': currency,
        'p_timezone': timezone,
        'p_country': country,
        'p_full_name': fullName,
      },
    );
    return result;
  }

  Future<void> updateUserClaims() async {
    final response = await _client.functions.invoke('update-user-claims');
    if (response.status != 200) {
      throw ServerException(
        message: response.data?['error']?.toString() ?? 'Failed to update claims',
      );
    }
    await _auth.refreshSession();
  }

  Future<Map<String, dynamic>> acceptInvitation(String token) async {
    return _client.rpc<Map<String, dynamic>>(
      'accept_employee_invitation',
      params: {'p_token': token},
    );
  }

  Future<String> registerDeviceSession({
    required String deviceId,
    required String deviceName,
    required String platform,
    required String appVersion,
    required bool rememberMe,
  }) async {
    return _client.rpc<String>(
      'register_device_session',
      params: {
        'p_device_id': deviceId,
        'p_device_name': deviceName,
        'p_platform': platform,
        'p_app_version': appVersion,
        'p_remember_me': rememberMe,
      },
    );
  }

  Future<List<Map<String, dynamic>>> getActiveSessions(String userId) async {
    return _client
        .from('auth_device_sessions')
        .select()
        .eq('user_id', userId)
        .eq('status', 'active')
        .order('last_active_at', ascending: false) as List<Map<String, dynamic>>;
  }

  Future<void> revokeSession(String sessionId) {
    return _client.rpc<void>(
      'revoke_device_session',
      params: {'p_session_id': sessionId},
    );
  }

  Future<int> revokeAllSessions({String? exceptSessionId}) async {
    return _client.rpc<int>(
      'revoke_all_device_sessions',
      params: {'p_except_session_id': exceptSessionId},
    );
  }

  Future<bool> isLoginLocked(String email) async {
    return _client.rpc<bool>(
      'is_login_locked',
      params: {'p_email': email},
    );
  }

  Future<void> recordLoginAttempt({
    required String email,
    required bool success,
    String? failureReason,
  }) async {
    try {
      await _client.functions.invoke(
        'record-login-attempt',
        body: {
          'email': email,
          'success': success,
          'failure_reason': failureReason,
        },
      );
    } catch (e) {
      AppLogger.warning('Failed to record login attempt', e);
    }
  }
}
