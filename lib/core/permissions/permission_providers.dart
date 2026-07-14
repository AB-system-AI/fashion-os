import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fashion_pos_enterprise/core/permissions/permission_engine.dart';
import 'package:fashion_pos_enterprise/features/auth/domain/entities/auth_user.dart';
import 'package:fashion_pos_enterprise/features/auth/presentation/providers/auth_controller.dart';

final permissionEngineProvider = Provider<PermissionEngine>((ref) => const PermissionEngine());

final currentUserProvider = Provider<AuthUser?>((ref) {
  return ref.watch(authControllerProvider).user;
});

/// Returns whether the current user has [permission].
final permissionCheckProvider = Provider.family<bool, String>((ref, permission) {
  final user = ref.watch(currentUserProvider);
  return ref.watch(permissionEngineProvider).can(user, permission);
});
