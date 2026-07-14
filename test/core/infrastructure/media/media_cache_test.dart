import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/cache/memory_cache.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/cache/media_cache_manager.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/domain/media_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/domain/media_models.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/security/media_security_service.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/storage/local_media_storage.dart';
import 'dart:io';

void main() {
  group('MediaCacheManager', () {
    late MediaCacheManager cache;
    late LocalMediaStorage storage;

    setUp(() async {
      final dir = await Directory.systemTemp.createTemp('cache_test_');
      storage = LocalMediaStorage(
        rootDirectory: dir,
        security: MediaSecurityService(encryptionKey: 'test-key-32-characters-long!!!!!'),
      );
      cache = MediaCacheManager(
        memoryCache: MemoryCache<String, Uint8List>(maxEntries: 10),
        localStorage: storage,
        security: MediaSecurityService(encryptionKey: 'test-key-32-characters-long!!!!!'),
      );
    });

    test('caches bytes after disk read', () async {
      final writeResult = await storage.write(tenantId: 't1', assetId: 'a1', bytes: Uint8List.fromList([1, 2, 3]));
      final path = (writeResult as Success<String>).data;
      final asset = MediaAsset(
        id: 'a1',
        tenantId: 't1',
        category: MediaCategory.product,
        ownerEntityType: 'product',
        ownerEntityId: 'p1',
        mimeType: 'image/png',
        sizeBytes: 3,
        checksum: MediaSecurityService(encryptionKey: 'test-key-32-characters-long!!!!!').checksum(Uint8List.fromList([1, 2, 3])),
        syncStatus: MediaSyncStatus.localOnly,
        createdAt: DateTime.now().toUtc(),
        localPath: path,
      );

      final first = await cache.getBytes(asset);
      final second = await cache.getBytes(asset);
      expect(first, second);
    });
  });
}
