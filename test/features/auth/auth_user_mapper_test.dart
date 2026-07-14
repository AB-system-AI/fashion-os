import 'package:flutter_test/flutter_test.dart';

import 'package:fashion_pos_enterprise/features/auth/data/mappers/auth_user_mapper.dart';

void main() {
  group('AuthUserMapper.parsePermissions', () {
    test('reads list from app_metadata', () {
      final perms = AuthUserMapper.parsePermissions({
        'permissions': ['product.read', 'product.create'],
      });
      expect(perms, ['product.read', 'product.create']);
    });

    test('reads comma-separated string', () {
      final perms = AuthUserMapper.parsePermissions({
        'permissions': 'product.read, category.manage',
      });
      expect(perms, ['product.read', 'category.manage']);
    });

    test('falls back to roles list', () {
      final perms = AuthUserMapper.parsePermissions({
        'roles': ['admin'],
      });
      expect(perms, ['admin']);
    });

    test('returns empty when no permissions claim', () {
      expect(AuthUserMapper.parsePermissions({}), isEmpty);
    });
  });
}
