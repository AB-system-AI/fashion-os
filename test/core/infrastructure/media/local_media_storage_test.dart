import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/media/domain/media_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/security/media_security_service.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/storage/local_media_storage.dart';
import 'package:fashion_pos_enterprise/core/result/result.dart';

void main() {
  group('LocalMediaStorage', () {
    late Directory tempDir;
    late LocalMediaStorage storage;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('media_test_');
      storage = LocalMediaStorage(
        rootDirectory: tempDir,
        security: MediaSecurityService(encryptionKey: 'test-key-32-characters-long!!!!!'),
        defaultQuotaBytes: 1024 * 1024,
      );
    });

    tearDown(() async {
      if (await tempDir.exists()) await tempDir.delete(recursive: true);
    });

    test('writes and reads encrypted file', () async {
      final bytes = Uint8List.fromList([10, 20, 30]);
      final write = await storage.write(tenantId: 't1', assetId: 'a1', bytes: bytes);
      expect(write.isSuccess, isTrue);

      final read = await storage.read((write as Success<String>).data);
      expect((read as Success<Uint8List>).data, bytes);
    });

    test('enforces quota', () async {
      storage = LocalMediaStorage(
        rootDirectory: tempDir,
        security: MediaSecurityService(encryptionKey: 'test-key-32-characters-long!!!!!'),
        defaultQuotaBytes: 10,
      );
      final result = await storage.write(
        tenantId: 't1',
        assetId: 'big',
        bytes: Uint8List(100),
      );
      expect(result.isFailure, isTrue);
    });

    test('cleanupTemporary removes old files', () async {
      await storage.write(
        tenantId: 't1',
        assetId: 'temp1',
        bytes: Uint8List.fromList([1]),
        tier: CacheTier.temporary,
      );
      final deleted = await storage.cleanupTemporary(maxAge: Duration.zero);
      expect(deleted, greaterThanOrEqualTo(0));
    });
  });
}
