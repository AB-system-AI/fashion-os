import 'dart:io';
import 'dart:typed_data';

import 'package:fashion_pos_enterprise/core/infrastructure/database/app_database.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/adapters/remote_storage_adapters.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/domain/media_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/domain/media_models.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/indexing/media_index_repository.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/security/media_security_service.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/storage/local_media_storage.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/upload/upload_engine.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/network/network_monitor.dart';
import 'package:fashion_pos_enterprise/core/result/result.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/network/network_state.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';

class _OnlineNetworkMonitor extends NetworkMonitor {
  @override
  Future<NetworkState> get currentState async => const NetworkState(
        isOnline: true,
        connectionType: NetworkConnectionType.wifi,
        quality: NetworkQuality.good,
      );
}

void main() {
  group('UploadEngine', () {
    late AppDatabase db;
    late MediaIndexRepository index;
    late LocalMediaStorage local;
    late UploadEngine engine;
    late Map<String, Uint8List> store;

    setUp(() async {
      db = AppDatabase.inMemory();
      await db.ensureOpen();
      index = MediaIndexRepository(db);
      final dir = await Directory.systemTemp.createTemp('upload_test_');
      local = LocalMediaStorage(
        rootDirectory: dir,
        security: MediaSecurityService(encryptionKey: 'test-key-32-characters-long!!!!!'),
      );
      store = {};
      engine = UploadEngine(
        providers: {StorageBackend.local: LocalRemoteStorageProvider(store)},
        localStorage: local,
        index: index,
        networkMonitor: _OnlineNetworkMonitor(),
      );
    });

    tearDown(() async {
      engine.dispose();
      await db.close();
    });

    test('uploads queued job to remote provider', () async {
      final bytes = Uint8List.fromList([1, 2, 3]);
      final write = await local.write(tenantId: 't1', assetId: 'asset1', bytes: bytes);
      final asset = MediaAsset(
        id: 'asset1',
        tenantId: 't1',
        category: MediaCategory.product,
        ownerEntityType: 'product',
        ownerEntityId: 'p1',
        mimeType: 'image/webp',
        sizeBytes: bytes.length,
        checksum: 'abc',
        localPath: (write as Success<String>).data,
        remotePath: 't1/product/p1/img.webp',
        remoteBucket: 'product-images',
        storageBackend: StorageBackend.local,
        syncStatus: MediaSyncStatus.pendingUpload,
        createdAt: DateTime.now().toUtc(),
      );
      await index.save(asset);

      final job = UploadJob(
        id: 'job1',
        assetId: asset.id,
        tenantId: 't1',
        localPath: asset.localPath!,
        remoteBucket: 'product-images',
        remotePath: asset.remotePath!,
        mimeType: 'image/webp',
        totalBytes: bytes.length,
        backend: StorageBackend.local,
        status: UploadStatus.queued,
        createdAt: DateTime.now().toUtc(),
      );

      await engine.enqueue(job);
      await engine.processOfflineQueue();

      final exists = await store.containsKey('product-images::t1/product/p1/img.webp');
      expect(exists, isTrue);
    });
  });
}
