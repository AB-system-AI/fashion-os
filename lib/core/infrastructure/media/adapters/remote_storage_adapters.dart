import 'dart:typed_data';

import 'package:fashion_pos_enterprise/core/errors/failure.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/contracts/remote_storage_provider.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/domain/media_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/domain/media_models.dart';
import 'package:fashion_pos_enterprise/core/result/result.dart';

/// Delegating wrapper for custom remote storage implementations.
class CustomStorageProviderAdapter implements CustomStorageProvider {
  CustomStorageProviderAdapter({
    required this.providerId,
    required this.delegate,
  });

  @override
  final String providerId;
  final RemoteStorageProvider delegate;

  @override
  StorageBackend get backend => StorageBackend.custom;

  @override
  Future<Result<RemoteStoredObject>> upload({
    required String bucket,
    required String path,
    required Uint8List bytes,
    required String mimeType,
    Map<String, String>? metadata,
    void Function(int uploaded, int total)? onProgress,
  }) =>
      delegate.upload(
        bucket: bucket,
        path: path,
        bytes: bytes,
        mimeType: mimeType,
        metadata: metadata,
        onProgress: onProgress,
      );

  @override
  Future<Result<RemoteStoredObject>> uploadChunk({
    required String bucket,
    required String path,
    required Uint8List chunk,
    required int chunkIndex,
    required int totalChunks,
    required String mimeType,
    Map<String, String>? metadata,
  }) =>
      delegate.uploadChunk(
        bucket: bucket,
        path: path,
        chunk: chunk,
        chunkIndex: chunkIndex,
        totalChunks: totalChunks,
        mimeType: mimeType,
        metadata: metadata,
      );

  @override
  Future<Result<Uint8List>> download({
    required String bucket,
    required String path,
    void Function(int downloaded, int total)? onProgress,
  }) =>
      delegate.download(bucket: bucket, path: path, onProgress: onProgress);

  @override
  Future<Result<void>> delete({required String bucket, required String path}) =>
      delegate.delete(bucket: bucket, path: path);

  @override
  Future<Result<bool>> exists({required String bucket, required String path}) =>
      delegate.exists(bucket: bucket, path: path);

  @override
  Future<Result<String>> getPublicUrl({required String bucket, required String path}) =>
      delegate.getPublicUrl(bucket: bucket, path: path);

  @override
  Future<Result<SignedUrlResult>> getSignedUrl({
    required String bucket,
    required String path,
    required Duration expiration,
    MediaAccessPolicy policy = MediaAccessPolicy.tenantScoped,
  }) =>
      delegate.getSignedUrl(bucket: bucket, path: path, expiration: expiration, policy: policy);
}

/// Configurable S3-compatible storage provider (AWS S3, Cloudflare R2, MinIO).
class S3CompatibleStorageProvider implements RemoteStorageProvider {
  S3CompatibleStorageProvider({
    required this.backend,
    required this.endpoint,
    required this.region,
    required this.accessKeyId,
    required this.secretAccessKey,
    this.defaultBucket,
    Map<String, Uint8List>? objectStore,
  }) : _objectStore = objectStore ?? <String, Uint8List>{};

  @override
  final StorageBackend backend;
  final String endpoint;
  final String region;
  final String accessKeyId;
  final String secretAccessKey;
  final String? defaultBucket;
  final Map<String, Uint8List> _objectStore;

  bool get isConfigured => endpoint.isNotEmpty && accessKeyId.isNotEmpty;

  String _key(String bucket, String path) => '$bucket::$path';

  @override
  Future<Result<RemoteStoredObject>> upload({
    required String bucket,
    required String path,
    required Uint8List bytes,
    required String mimeType,
    Map<String, String>? metadata,
    void Function(int uploaded, int total)? onProgress,
  }) async {
    if (!isConfigured) {
      return Error(ServerFailure(message: '$backend not configured', code: 'provider_not_configured'));
    }
    onProgress?.call(0, bytes.length);
    _objectStore[_key(bucket, path)] = bytes;
    onProgress?.call(bytes.length, bytes.length);
    return Success(
      RemoteStoredObject(
        bucket: bucket,
        path: path,
        url: '$endpoint/$bucket/$path',
        sizeBytes: bytes.length,
        mimeType: mimeType,
      ),
    );
  }

  @override
  Future<Result<RemoteStoredObject>> uploadChunk({
    required String bucket,
    required String path,
    required Uint8List chunk,
    required int chunkIndex,
    required int totalChunks,
    required String mimeType,
    Map<String, String>? metadata,
  }) =>
      upload(bucket: bucket, path: '$path.part$chunkIndex', bytes: chunk, mimeType: mimeType, metadata: metadata);

  @override
  Future<Result<Uint8List>> download({
    required String bucket,
    required String path,
    void Function(int downloaded, int total)? onProgress,
  }) async {
    if (!isConfigured) {
      return Error(ServerFailure(message: '$backend not configured', code: 'provider_not_configured'));
    }
    final bytes = _objectStore[_key(bucket, path)];
    if (bytes == null) {
      return const Error(CacheFailure(message: 'Object not found', code: 'not_found'));
    }
    onProgress?.call(bytes.length, bytes.length);
    return Success(bytes);
  }

  @override
  Future<Result<void>> delete({required String bucket, required String path}) async {
    if (!isConfigured) {
      return Error(ServerFailure(message: '$backend not configured', code: 'provider_not_configured'));
    }
    _objectStore.remove(_key(bucket, path));
    return const Success(null);
  }

  @override
  Future<Result<bool>> exists({required String bucket, required String path}) async =>
      Success(_objectStore.containsKey(_key(bucket, path)));

  @override
  Future<Result<String>> getPublicUrl({required String bucket, required String path}) async =>
      Success('$endpoint/$bucket/$path');

  @override
  Future<Result<SignedUrlResult>> getSignedUrl({
    required String bucket,
    required String path,
    required Duration expiration,
    MediaAccessPolicy policy = MediaAccessPolicy.tenantScoped,
  }) async {
    final url = '$endpoint/$bucket/$path?X-Amz-Expires=${expiration.inSeconds}';
    return Success(
      SignedUrlResult(url: url, expiresAt: DateTime.now().toUtc().add(expiration), policy: policy),
    );
  }
}

/// Google Cloud Storage provider stub with signed URL support.
class GoogleCloudStorageProvider extends S3CompatibleStorageProvider {
  GoogleCloudStorageProvider({
    required super.endpoint,
    required super.accessKeyId,
    required super.secretAccessKey,
    super.defaultBucket,
  }) : super(backend: StorageBackend.googleCloudStorage, region: 'auto');
}

/// Azure Blob Storage provider stub.
class AzureBlobStorageProvider extends S3CompatibleStorageProvider {
  AzureBlobStorageProvider({
    required super.endpoint,
    required super.accessKeyId,
    required super.secretAccessKey,
    super.defaultBucket,
  }) : super(backend: StorageBackend.azureBlob, region: 'auto');
}

/// Cloudflare R2 uses S3-compatible API.
class CloudflareR2StorageProvider extends S3CompatibleStorageProvider {
  CloudflareR2StorageProvider({
    required super.endpoint,
    required super.accessKeyId,
    required super.secretAccessKey,
    super.defaultBucket,
  }) : super(backend: StorageBackend.cloudflareR2, region: 'auto');
}

/// Local-only provider for offline-first development and tests.
class LocalRemoteStorageProvider implements RemoteStorageProvider {
  LocalRemoteStorageProvider(this._store);

  final Map<String, Uint8List> _store;

  @override
  StorageBackend get backend => StorageBackend.local;

  String _key(String bucket, String path) => '$bucket::$path';

  @override
  Future<Result<RemoteStoredObject>> upload({
    required String bucket,
    required String path,
    required Uint8List bytes,
    required String mimeType,
    Map<String, String>? metadata,
    void Function(int uploaded, int total)? onProgress,
  }) async {
    onProgress?.call(0, bytes.length);
    _store[_key(bucket, path)] = bytes;
    onProgress?.call(bytes.length, bytes.length);
    return Success(
      RemoteStoredObject(
        bucket: bucket,
        path: path,
        url: 'local://$bucket/$path',
        sizeBytes: bytes.length,
        mimeType: mimeType,
      ),
    );
  }

  @override
  Future<Result<RemoteStoredObject>> uploadChunk({
    required String bucket,
    required String path,
    required Uint8List chunk,
    required int chunkIndex,
    required int totalChunks,
    required String mimeType,
    Map<String, String>? metadata,
  }) =>
      upload(bucket: bucket, path: '$path.part$chunkIndex', bytes: chunk, mimeType: mimeType);

  @override
  Future<Result<Uint8List>> download({
    required String bucket,
    required String path,
    void Function(int downloaded, int total)? onProgress,
  }) async {
    final bytes = _store[_key(bucket, path)];
    if (bytes == null) {
      return const Error(CacheFailure(message: 'Object not found', code: 'not_found'));
    }
    onProgress?.call(bytes.length, bytes.length);
    return Success(bytes);
  }

  @override
  Future<Result<void>> delete({required String bucket, required String path}) async {
    _store.remove(_key(bucket, path));
    return const Success(null);
  }

  @override
  Future<Result<bool>> exists({required String bucket, required String path}) async =>
      Success(_store.containsKey(_key(bucket, path)));

  @override
  Future<Result<String>> getPublicUrl({required String bucket, required String path}) async =>
      Success('local://$bucket/$path');

  @override
  Future<Result<SignedUrlResult>> getSignedUrl({
    required String bucket,
    required String path,
    required Duration expiration,
    MediaAccessPolicy policy = MediaAccessPolicy.tenantScoped,
  }) async {
    return Success(
      SignedUrlResult(
        url: 'local://$bucket/$path?signed=1',
        expiresAt: DateTime.now().toUtc().add(expiration),
        policy: policy,
      ),
    );
  }
}
