import 'dart:typed_data';

import 'package:mime/mime.dart';

import 'package:fashion_pos_enterprise/core/errors/failure.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/contracts/remote_storage_provider.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/barcode/media_barcode_generator.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/cache/media_cache_manager.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/document/document_engine.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/domain/media_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/domain/media_models.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/download/download_engine.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/indexing/media_index_repository.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/optimization/media_optimizer.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/processing/image_processor.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/security/media_security_service.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/storage/local_media_storage.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/upload/upload_engine.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/network/network_monitor.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/storage/storage_models.dart';
import 'package:fashion_pos_enterprise/core/result/result.dart';

/// Single entry point for all media operations — features must use this exclusively.
class MediaEngine {
  MediaEngine({
    required MediaIndexRepository index,
    required LocalMediaStorage localStorage,
    required MediaSecurityService security,
    required ImageProcessor imageProcessor,
    required MediaOptimizer optimizer,
    required UploadEngine uploadEngine,
    required DownloadEngine downloadEngine,
    required MediaCacheManager cacheManager,
    required DocumentEngine documentEngine,
    required MediaBarcodeGenerator barcodeGenerator,
    required NetworkMonitor networkMonitor,
    required Map<StorageBackend, RemoteStorageProvider> storageProviders,
    StoragePathBuilder? pathBuilder,
  })  : _index = index,
        _local = localStorage,
        _security = security,
        _imageProcessor = imageProcessor,
        _optimizer = optimizer,
        _upload = uploadEngine,
        _download = downloadEngine,
        _cache = cacheManager,
        _documents = documentEngine,
        _barcodes = barcodeGenerator,
        _network = networkMonitor,
        _storageProviders = storageProviders,
        _paths = pathBuilder ?? const StoragePathBuilder();

  final MediaIndexRepository _index;
  final LocalMediaStorage _local;
  final MediaSecurityService _security;
  final ImageProcessor _imageProcessor;
  final MediaOptimizer _optimizer;
  final UploadEngine _upload;
  final DownloadEngine _download;
  final MediaCacheManager _cache;
  final DocumentEngine _documents;
  final MediaBarcodeGenerator _barcodes;
  final NetworkMonitor _network;
  final Map<StorageBackend, RemoteStorageProvider> _storageProviders;
  final StoragePathBuilder _paths;

  Future<Result<MediaAsset>> upload(MediaUploadRequest request) async {
    final mime = request.mimeType ?? lookupMimeType(request.filename) ?? 'application/octet-stream';
    final bucket = StorageBuckets.forCategory(request.category);

    if (!bucket.acceptsMime(mime) && !_isDocumentCategory(request.category)) {
      return Error(ValidationFailure(message: 'MIME $mime not allowed for ${request.category.name}', code: 'invalid_mime'));
    }

    final network = await _network.currentState;
    Uint8List payload = request.bytes;

    if (_isImageMime(mime)) {
      final optimized = _optimizer.optimizeForUpload(
        bytes: request.bytes,
        profile: request.qualityProfile,
        network: network,
        generateThumbnail: request.generateThumbnail,
      );
      if (optimized.isFailure) return Error(optimized.failureOrNull!);
      payload = (optimized as Success<ProcessedImage>).data.bytes;
    } else {
      final doc = _documents.process(bytes: request.bytes, filename: request.filename);
      if (doc.isFailure) return Error(doc.failureOrNull!);
      payload = (doc as Success<ProcessedDocument>).data.bytes;
    }

    if (!bucket.acceptsSize(payload.length)) {
      return const Error(ValidationFailure(message: 'File exceeds bucket size limit', code: 'file_too_large'));
    }

    final quota = await _local.quotaFor(request.tenantId);
    if (quota.isExceeded || quota.usedBytes + payload.length > quota.limitBytes) {
      return const Error(ValidationFailure(message: 'Tenant storage quota exceeded', code: 'quota_exceeded'));
    }

    final assetId = _index.newId();
    final checksum = _security.checksum(payload);
    final writeResult = await _local.write(
      tenantId: request.tenantId,
      assetId: assetId,
      bytes: payload,
      tier: request.uploadImmediately ? CacheTier.persistent : CacheTier.temporary,
    );
    if (writeResult.isFailure) return Error(writeResult.failureOrNull!);

    final remotePath = _paths.build(
      tenantId: request.tenantId,
      entityType: request.ownerEntityType,
      entityId: request.ownerEntityId,
      filename: request.filename,
    );

    var asset = MediaAsset(
      id: assetId,
      tenantId: request.tenantId,
      storeId: request.storeId,
      category: request.category,
      ownerEntityType: request.ownerEntityType,
      ownerEntityId: request.ownerEntityId,
      variant: request.variant,
      mimeType: mime,
      sizeBytes: payload.length,
      checksum: checksum,
      localPath: (writeResult as Success<String>).data,
      remotePath: remotePath,
      remoteBucket: bucket.name,
      storageBackend: request.backend,
      filename: request.filename,
      syncStatus: request.uploadImmediately && network.isOnline
          ? MediaSyncStatus.pendingUpload
          : MediaSyncStatus.localOnly,
      createdAt: DateTime.now().toUtc(),
      metadata: request.metadata,
    );

    await _index.save(asset);
    await _cache.putBytes(asset, payload);

    if (request.generateThumbnail && _isImageMime(mime)) {
      await _createThumbnail(asset, request.bytes);
    }

    if (request.uploadImmediately && network.isOnline) {
      final job = UploadJob(
        id: _upload.createJobId(),
        assetId: asset.id,
        tenantId: request.tenantId,
        localPath: asset.localPath!,
        remoteBucket: bucket.name,
        remotePath: remotePath,
        mimeType: mime,
        totalBytes: payload.length,
        backend: request.backend,
        status: UploadStatus.queued,
        createdAt: DateTime.now().toUtc(),
      );
      await _upload.enqueue(job);
      asset = asset.copyWith(syncStatus: MediaSyncStatus.pendingUpload);
      await _index.save(asset);
    }

    return Success(asset);
  }

  Future<Result<List<MediaAsset>>> uploadMany(List<MediaUploadRequest> requests) async {
    final assets = <MediaAsset>[];
    for (final request in requests) {
      final result = await upload(request);
      if (result.isFailure) return Error(result.failureOrNull!);
      assets.add((result as Success<MediaAsset>).data);
    }
    return Success(assets);
  }

  Future<Result<Uint8List>> getBytes(String assetId) async {
    final asset = await _index.getById(assetId);
    if (asset == null) {
      return const Error(ValidationFailure(message: 'Media asset not found', code: 'not_found'));
    }
    final cached = await _cache.getBytes(asset);
    if (cached != null) return Success(cached);

    if (asset.localPath != null) {
      return _local.read(asset.localPath!);
    }

    await _download.downloadAsset(asset);
    final refreshed = await _index.getById(assetId);
    if (refreshed?.localPath == null) {
      return const Error(CacheFailure(message: 'Media not available offline', code: 'offline_unavailable'));
    }
    return _local.read(refreshed!.localPath!);
  }

  Future<Result<MediaAsset>> download(String assetId, {int priority = 0}) async {
    final asset = await _index.getById(assetId);
    if (asset == null) {
      return const Error(ValidationFailure(message: 'Media asset not found', code: 'not_found'));
    }
    return _download.downloadAsset(asset, priority: priority);
  }

  Future<Result<ProcessedImage>> processImage(ImageProcessRequest request) => _imageProcessor.process(request);

  Future<Result<ProcessedDocument>> processDocument({
    required Uint8List bytes,
    required String filename,
    DocumentType? type,
  }) =>
      Future.value(_documents.process(bytes: bytes, filename: filename, type: type));

  Future<Result<MediaAsset>> generateQrAsset({
    required MediaUploadRequest baseRequest,
    required String qrData,
  }) async {
    final generated = _barcodes.generateQrImage(data: qrData);
    if (generated.isFailure) return Error(generated.failureOrNull!);
    final image = (generated as Success<({Uint8List bytes, String mimeType, MediaCategory category})>).data;
    return upload(
      MediaUploadRequest(
        tenantId: baseRequest.tenantId,
        storeId: baseRequest.storeId,
        category: MediaCategory.qr,
        ownerEntityType: baseRequest.ownerEntityType,
        ownerEntityId: baseRequest.ownerEntityId,
        bytes: image.bytes,
        filename: 'qr-${baseRequest.filename}',
        mimeType: image.mimeType,
        backend: baseRequest.backend,
        metadata: {...baseRequest.metadata, 'qr_data': qrData},
      ),
    );
  }

  Future<Result<void>> delete(String assetId) async {
    final asset = await _index.getById(assetId);
    if (asset == null) {
      return const Error(ValidationFailure(message: 'Media asset not found', code: 'not_found'));
    }
    if (asset.remotePath != null && asset.remoteBucket != null) {
      final provider = _storageProviders[asset.storageBackend];
      if (provider != null) {
        await provider.delete(bucket: asset.remoteBucket!, path: asset.remotePath!);
      }
    }
    if (asset.localPath != null) {
      await _local.delete(asset.localPath!, tenantId: asset.tenantId);
    }
    _cache.evict(assetId);
    await _index.delete(assetId);
    return const Success(null);
  }

  Future<Result<SignedUrlResult>> getSignedUrl(
    String assetId, {
    Duration expiration = const Duration(hours: 1),
    MediaAccessPolicy policy = MediaAccessPolicy.tenantScoped,
  }) async {
    final asset = await _index.getById(assetId);
    if (asset == null || asset.remotePath == null || asset.remoteBucket == null) {
      return const Error(ValidationFailure(message: 'Remote asset not available', code: 'no_remote'));
    }
    final provider = _storageProviders[asset.storageBackend];
    if (provider == null) {
      return const Error(ServerFailure(message: 'Storage provider not registered', code: 'no_provider'));
    }
    final result = await provider.getSignedUrl(
      bucket: asset.remoteBucket!,
      path: asset.remotePath!,
      expiration: expiration,
      policy: policy,
    );
    if (result.isSuccess) {
      final signed = result.dataOrNull!;
      if (!_security.isSignedUrlValid(signed, policy: policy)) {
        return const Error(ValidationFailure(message: 'Signed URL expired or invalid', code: 'invalid_signed_url'));
      }
    }
    return result;
  }

  Future<Result<StorageQuota>> quota(String tenantId) async => Success(await _local.quotaFor(tenantId));

  Future<int> cleanupTemporaryCache() => _local.cleanupTemporary();

  Stream<UploadProgress> uploadProgress(String jobId) => _upload.progressStream(jobId);

  Stream<DownloadProgress> downloadProgress(String jobId) => _download.progressStream(jobId);

  Future<Result<UploadJob>> pauseUpload(String jobId) => _upload.pause(jobId);

  Future<Result<void>> cancelUpload(String jobId) => _upload.cancel(jobId);

  Future<Result<MediaAsset>> retryUpload(String jobId) => _upload.retry(jobId);

  Future<void> processOfflineUploadQueue() => _upload.processOfflineQueue();

  Future<List<MediaAsset>> listByOwner({
    required String tenantId,
    required String ownerEntityType,
    required String ownerEntityId,
  }) =>
      _index.listByOwner(tenantId: tenantId, ownerEntityType: ownerEntityType, ownerEntityId: ownerEntityId);

  Future<MediaAsset?> getAsset(String assetId) => _index.getById(assetId);

  Future<void> prefetch(List<String> assetIds) async {
    final assets = <MediaAsset>[];
    for (final id in assetIds) {
      final asset = await _index.getById(id);
      if (asset != null) assets.add(asset);
    }
    await _cache.prefetch(assets);
  }

  Future<void> _createThumbnail(MediaAsset parent, Uint8List originalBytes) async {
    final thumb = _imageProcessor.process(
      ImageProcessRequest(
        bytes: originalBytes,
        operations: const [ImageOperation.thumbnail, ImageOperation.autoOrient],
        outputFormat: ImageFormat.webp,
        quality: 75,
        thumbnailSize: 200,
      ),
    );
    if (thumb.isFailure) return;

    final processed = (thumb as Success<ProcessedImage>).data;
    final thumbBytes = processed.thumbnailBytes ?? processed.bytes;
    final thumbId = '${parent.id}_thumb';
    final writeResult = await _local.write(
      tenantId: parent.tenantId,
      assetId: thumbId,
      bytes: thumbBytes,
      tier: CacheTier.disk,
    );
    if (writeResult.isFailure) return;

    final thumbAsset = MediaAsset(
      id: thumbId,
      tenantId: parent.tenantId,
      storeId: parent.storeId,
      category: parent.category,
      ownerEntityType: parent.ownerEntityType,
      ownerEntityId: parent.ownerEntityId,
      variant: MediaVariant.thumbnail,
      mimeType: processed.thumbnailMimeType ?? 'image/webp',
      sizeBytes: thumbBytes.length,
      checksum: _security.checksum(thumbBytes),
      localPath: (writeResult as Success<String>).data,
      remotePath: parent.remotePath != null ? '${parent.remotePath!}.thumb' : null,
      remoteBucket: parent.remoteBucket,
      storageBackend: parent.storageBackend,
      filename: 'thumb_${parent.filename ?? parent.id}',
      syncStatus: parent.syncStatus,
      createdAt: DateTime.now().toUtc(),
      metadata: {'parent_asset_id': parent.id},
    );
    await _index.save(thumbAsset);
  }

  bool _isImageMime(String mime) => mime.startsWith('image/') && mime != 'image/svg+xml';

  bool _isDocumentCategory(MediaCategory category) {
    return switch (category) {
      MediaCategory.pdf || MediaCategory.excel || MediaCategory.csv || MediaCategory.backup || MediaCategory.invoice || MediaCategory.receipt || MediaCategory.attachment => true,
      _ => false,
    };
  }
}
