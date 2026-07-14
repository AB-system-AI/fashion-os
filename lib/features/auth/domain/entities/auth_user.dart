import 'package:equatable/equatable.dart';

/// Authenticated user context from Supabase session + employee record.
class AuthUser extends Equatable {
  const AuthUser({
    required this.userId,
    required this.email,
    required this.emailVerified,
    this.fullName,
    this.tenantId,
    this.employeeId,
    this.employeeStatus,
    this.storeIds = const [],
    this.permissions = const [],
  });

  final String userId;
  final String email;
  final bool emailVerified;
  final String? fullName;
  final String? tenantId;
  final String? employeeId;
  final String? employeeStatus;
  final List<String> storeIds;
  final List<String> permissions;

  bool get hasOrganization => tenantId != null && employeeId != null;
  bool get isActive => employeeStatus == 'active';
  bool hasPermission(String code) => permissions.contains(code);

  AuthUser copyWith({
    String? fullName,
    String? tenantId,
    String? employeeId,
    String? employeeStatus,
    List<String>? storeIds,
    List<String>? permissions,
    bool? emailVerified,
  }) {
    return AuthUser(
      userId: userId,
      email: email,
      emailVerified: emailVerified ?? this.emailVerified,
      fullName: fullName ?? this.fullName,
      tenantId: tenantId ?? this.tenantId,
      employeeId: employeeId ?? this.employeeId,
      employeeStatus: employeeStatus ?? this.employeeStatus,
      storeIds: storeIds ?? this.storeIds,
      permissions: permissions ?? this.permissions,
    );
  }

  @override
  List<Object?> get props => [
        userId,
        email,
        emailVerified,
        fullName,
        tenantId,
        employeeId,
        employeeStatus,
        storeIds,
        permissions,
      ];
}
