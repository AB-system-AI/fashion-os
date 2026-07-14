import 'package:flutter_test/flutter_test.dart';

import 'package:fashion_pos_enterprise/core/security/password_validator.dart';

void main() {
  group('PasswordValidator', () {
    test('rejects empty password', () {
      expect(PasswordValidator.validate(''), 'password_required');
    });

    test('rejects weak password', () {
      expect(PasswordValidator.validate('short'), 'password_too_short');
    });

    test('rejects password without uppercase', () {
      expect(
        PasswordValidator.validate('alllowercase1!'),
        'password_missing_uppercase',
      );
    });

    test('accepts strong password', () {
      expect(PasswordValidator.validate('SecurePass1!'), isNull);
    });

    test('strength score increases with complexity', () {
      final weak = PasswordValidator.strengthScore('abc');
      final strong = PasswordValidator.strengthScore('SecurePass1!');
      expect(strong, greaterThan(weak));
    });
  });
}
