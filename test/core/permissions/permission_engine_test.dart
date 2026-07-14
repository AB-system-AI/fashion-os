import 'package:flutter_test/flutter_test.dart';

import 'package:fashion_pos_enterprise/core/permissions/permission_engine.dart';
import 'package:fashion_pos_enterprise/features/auth/domain/entities/auth_user.dart';

void main() {
  const engine = PermissionEngine();
  const user = AuthUser(
    userId: 'u1',
    employeeId: 'e1',
    email: 'a@b.com',
    emailVerified: true,
    tenantId: 't1',
    permissions: {'product.read', 'product.create'},
  );

  test('can returns true when permission present', () {
    expect(engine.can(user, 'product.read'), isTrue);
    expect(engine.can(user, 'product.delete'), isFalse);
  });

  test('require throws when permission missing', () {
    expect(() => engine.require(user, 'product.delete'), throwsA(isA<PermissionDeniedException>()));
  });
}
