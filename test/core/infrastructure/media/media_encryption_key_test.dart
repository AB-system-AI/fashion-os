import 'package:flutter_test/flutter_test.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/media/security/media_encryption_key_store.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/security/media_security_service.dart';

void main() {
  tearDown(MediaEncryptionKeyStore.clearCache);

  group('Media encryption security', () {
    test('MediaSecurityService rejects short keys', () {
      expect(
        () => MediaSecurityService(encryptionKey: 'short'),
        throwsStateError,
      );
    });

    test('seeded key enables encrypt/decrypt', () {
      MediaEncryptionKeyStore.seedForTests('test-key-32-characters-long!!!!!');

      final security = MediaSecurityService(encryptionKey: MediaEncryptionKeyStore.cachedKey!);
      final encrypted = security.encrypt([1, 2, 3, 4]);
      final decrypted = security.decrypt(encrypted);
      expect(decrypted.isSuccess, isTrue);
    });
  });
}
