import 'package:fashion_pos_enterprise/core/result/result.dart';
import 'package:fashion_pos_enterprise/features/auth/domain/entities/auth_user.dart';
import 'package:fashion_pos_enterprise/features/auth/domain/entities/device_session.dart';
import 'package:fashion_pos_enterprise/features/auth/domain/entities/owner_registration.dart';

abstract class AuthRepository {
  Stream<AuthUser?> watchAuthUser();

  Future<Result<AuthUser>> signIn({
    required String email,
    required String password,
    required bool rememberMe,
  });

  Future<Result<OrganizationContext>> registerOwner(OwnerRegistration registration);

  Future<Result<void>> signOut({bool revokeAllSessions = false});

  Future<Result<void>> resendVerificationEmail();

  Future<Result<void>> sendPasswordResetEmail(String email);

  Future<Result<void>> updatePassword(String newPassword);

  Future<Result<void>> refreshClaims();

  Future<Result<List<DeviceSession>>> getActiveSessions();

  Future<Result<void>> revokeSession(String sessionId);

  Future<Result<void>> revokeAllSessions({String? exceptSessionId});

  Future<Result<void>> acceptInvitation(String token);

  Future<bool> isLoginLocked(String email);
}
