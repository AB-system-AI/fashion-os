import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'package:fashion_pos_enterprise/core/infrastructure/cache/memory_cache.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/di/infrastructure_providers.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/adapters/remote_storage_adapters.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/adapters/supabase_storage_provider.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/barcode/media_barcode_generator.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/cache/media_cache_manager.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/contracts/remote_storage_provider.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/document/document_engine.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/domain/media_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/download/download_engine.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/indexing/media_index_repository.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/media_engine.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/optimization/media_optimizer.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/processing/image_processor.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/security/media_encryption_key_store.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/security/media_security_service.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/storage/local_media_storage.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/sync/media_sync_integration.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/upload/upload_engine.dart';

final mediaEncryptionKeyStoreProvider = Provider<MediaEncryptionKeyStore>((ref) => MediaEncryptionKeyStore());

final mediaSecurityServiceProvider = Provider<MediaSecurityService>((ref) {
  final key = MediaEncryptionKeyStore.cachedKey;
  if (key == null || key.length < 32) {
    throw StateError('Media encryption key unavailable — bootstrap media initializer first');
  }
  return MediaSecurityService(encryptionKey: key);
});

final mediaObjectStoreProvider = Provider<Map<String, Uint8List>>((ref) => {});

final remoteStorageProvidersProvider = Provider<Map<StorageBackend, RemoteStorageProvider>>((ref) {
  final store = ref.watch(mediaObjectStoreProvider);
  return {
    StorageBackend.local: LocalRemoteStorageProvider(store),
    StorageBackend.supabase: SupabaseStorageProvider(),
    StorageBackend.s3: S3CompatibleStorageProvider(
      backend: StorageBackend.s3,
      endpoint: 'memory://s3',
      region: 'us-east-1',
      accessKeyId: 'local',
      secretAccessKey: 'local',
      objectStore: store,
    ),
    StorageBackend.cloudflareR2: CloudflareR2StorageProvider(
      endpoint: 'memory://r2',
      accessKeyId: 'local',
      secretAccessKey: 'local',
      objectStore: store,
    ),
    StorageBackend.googleCloudStorage: GoogleCloudStorageProvider(
      endpoint: 'memory://gcs',
      accessKeyId: 'local',
      secretAccessKey: 'local',
      objectStore: store,
    ),
    StorageBackend.azureBlob: AzureBlobStorageProvider(
      endpoint: 'memory://azure',
      accessKeyId: 'local',
      secretAccessKey: 'local',
      objectStore: store,
    ),
  };
});

final localMediaStorageProvider = Provider<LocalMediaStorage>((ref) {
  return LocalMediaStorage(
    security: ref.watch(mediaSecurityServiceProvider),
    rootResolver: () async {
      final dir = await getApplicationDocumentsDirectory();
      return Directory(p.join(dir.path, 'media_vault'));
    },
  );
});

final mediaIndexRepositoryProvider = Provider<MediaIndexRepository>((ref) {
  return MediaIndexRepository(ref.watch(appDatabaseProvider));
});

final imageProcessorProvider = Provider<ImageProcessor>((ref) => ImageProcessor());

final mediaOptimizerProvider = Provider<MediaOptimizer>((ref) {
  return MediaOptimizer(imageProcessor: ref.watch(imageProcessorProvider));
});

final documentEngineProvider = Provider<DocumentEngine>((ref) => DocumentEngine());

final mediaBarcodeGeneratorProvider = Provider<MediaBarcodeGenerator>((ref) => MediaBarcodeGenerator());

final mediaCacheManagerProvider = Provider<MediaCacheManager>((ref) {
  return MediaCacheManager(
    memoryCache: MemoryCache<String, Uint8List>(maxEntries: 200, maxBytes: 64 * 1024 * 1024),
    localStorage: ref.watch(localMediaStorageProvider),
    security: ref.watch(mediaSecurityServiceProvider),
  );
});

final uploadEngineProvider = Provider<UploadEngine>((ref) {
  final engine = UploadEngine(
    providers: ref.watch(remoteStorageProvidersProvider),
    localStorage: ref.watch(localMediaStorageProvider),
    index: ref.watch(mediaIndexRepositoryProvider),
    networkMonitor: ref.watch(networkMonitorProvider),
    syncQueueWriter: ref.watch(syncQueueWriterProvider),
  );
  ref.onDispose(engine.dispose);
  return engine;
});

final downloadEngineProvider = Provider<DownloadEngine>((ref) {
  final engine = DownloadEngine(
    providers: ref.watch(remoteStorageProvidersProvider),
    localStorage: ref.watch(localMediaStorageProvider),
    index: ref.watch(mediaIndexRepositoryProvider),
  );
  ref.onDispose(engine.dispose);
  return engine;
});

final mediaSyncIntegrationProvider = Provider<MediaSyncIntegration>((ref) {
  return MediaSyncIntegration(
    uploadEngine: ref.watch(uploadEngineProvider),
    index: ref.watch(mediaIndexRepositoryProvider),
    networkMonitor: ref.watch(networkMonitorProvider),
  );
});

final mediaEngineProvider = Provider<MediaEngine>((ref) {
  return MediaEngine(
    index: ref.watch(mediaIndexRepositoryProvider),
    localStorage: ref.watch(localMediaStorageProvider),
    security: ref.watch(mediaSecurityServiceProvider),
    imageProcessor: ref.watch(imageProcessorProvider),
    optimizer: ref.watch(mediaOptimizerProvider),
    uploadEngine: ref.watch(uploadEngineProvider),
    downloadEngine: ref.watch(downloadEngineProvider),
    cacheManager: ref.watch(mediaCacheManagerProvider),
    documentEngine: ref.watch(documentEngineProvider),
    barcodeGenerator: ref.watch(mediaBarcodeGeneratorProvider),
    networkMonitor: ref.watch(networkMonitorProvider),
    storageProviders: ref.watch(remoteStorageProvidersProvider),
  );
});

/// Warms local media storage and loads encryption key during bootstrap.
final mediaInitializerProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    await ref.read(mediaEncryptionKeyStoreProvider).loadOrCreate();
    await ref.read(localMediaStorageProvider).rootDirectory;
  };
});
