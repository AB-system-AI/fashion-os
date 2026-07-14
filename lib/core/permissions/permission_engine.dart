import 'package:fashion_pos_enterprise/features/auth/domain/entities/auth_user.dart';

/// Evaluates RBAC permission codes against the authenticated user.
class PermissionEngine {
  const PermissionEngine();

  bool can(AuthUser? user, String permission) {
    if (user == null) return false;
    return user.hasPermission(permission);
  }

  bool canAny(AuthUser? user, Iterable<String> permissions) {
    return permissions.any((p) => can(user, p));
  }

  bool canAll(AuthUser? user, Iterable<String> permissions) {
    return permissions.every((p) => can(user, p));
  }

  void require(AuthUser? user, String permission) {
    if (!can(user, permission)) {
      throw PermissionDeniedException(permission);
    }
  }
}

/// Thrown when an action is not permitted for the current user.
class PermissionDeniedException implements Exception {
  PermissionDeniedException(this.permission);

  final String permission;

  @override
  String toString() => 'Permission denied: $permission';
}
