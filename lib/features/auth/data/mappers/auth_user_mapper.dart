import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:fashion_pos_enterprise/features/auth/domain/entities/auth_user.dart';

/// Maps Supabase session/JWT claims to [AuthUser].
abstract final class AuthUserMapper {
  static AuthUser fromSession(Session session) {
    final user = session.user;
    final meta = user.appMetadata;
    return AuthUser(
      userId: user.id,
      email: user.email ?? '',
      emailVerified: user.emailConfirmedAt != null,
      fullName: user.userMetadata?['full_name'] as String?,
      tenantId: meta['tenant_id'] as String?,
      employeeId: meta['employee_id'] as String?,
      employeeStatus: meta['employee_status'] as String?,
      storeIds: (meta['store_ids'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      permissions: parsePermissions(meta),
    );
  }

  /// Parses RBAC permission codes from JWT app_metadata.
  static List<String> parsePermissions(Map<String, dynamic> appMetadata) {
    final raw = appMetadata['permissions'];
    if (raw is List) {
      return raw.map((e) => e.toString()).where((p) => p.isNotEmpty).toList();
    }
    if (raw is String && raw.isNotEmpty) {
      return raw.split(',').map((e) => e.trim()).where((p) => p.isNotEmpty).toList();
    }
    final roles = appMetadata['roles'];
    if (roles is List) {
      return roles.map((e) => e.toString()).where((p) => p.isNotEmpty).toList();
    }
    return const [];
  }
}
