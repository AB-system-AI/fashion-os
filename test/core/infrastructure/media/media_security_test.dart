import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/media/security/media_security_service.dart';
import 'package:fashion_pos_enterprise/core/result/result.dart';

void main() {
  group('MediaSecurityService', () {
    late MediaSecurityService security;

    setUp(() {
      security = MediaSecurityService(encryptionKey: 'test-key-32-characters-long!!!!!');
    });

    test('checksum is deterministic', () {
      final bytes = Uint8List.fromList([1, 2, 3, 4]);
      expect(security.checksum(bytes), security.checksum(bytes));
    });

    test('encrypt and decrypt roundtrip', () {
      final plain = Uint8List.fromList(List.generate(64, (i) => i));
      final encrypted = security.encrypt(plain);
      final decrypted = security.decrypt(encrypted);
      expect(decrypted.isSuccess, isTrue);
      expect((decrypted as Success<Uint8List>).data, plain);
    });

    test('validateChecksum detects tampering', () {
      final bytes = Uint8List.fromList([9, 9, 9]);
      final result = security.validateChecksum(bytes, 'invalid');
      expect(result.isFailure, isTrue);
    });
  });
}
