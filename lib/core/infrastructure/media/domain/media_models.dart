import 'dart:typed_data';

import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/media/domain/media_enums.dart';

/// Indexed media asset metadata.
class MediaAsset extends Equatable {
  const MediaAsset({
    required this.id,
    required this.tenantId,
    required this.category,
    required this.ownerEntityType,
    required this.ownerEntityId,
    required this.mimeType,
    required this.sizeBytes,
    required this.checksum,
    required this.syncStatus,
    required this.createdAt,
    this.storeId,
    this.variant = MediaVariant.original,
    this.localPath,
    this.remotePath,
    this.remoteBucket,
    this.storageBackend = StorageBackend.local,
    this.filename,
    this.uploadedAt,
    this.signedUrl,
    this.signedUrlExpiresAt,
    this.metadata = const {},
  });

  final String id;
  final String tenantId;
  final String? storeId;
  final MediaCategory category;
  final String ownerEntityType;
  final String ownerEntityId;
  final MediaVariant variant;
  final String mimeType;
  final int sizeBytes;
  final String checksum;
  final String? localPath;
  final String? remotePath;
  final String? remoteBucket;
  final StorageBackend storageBackend;
  final String? filename;
  final MediaSyncStatus syncStatus;
  final DateTime createdAt;
  final DateTime? uploadedAt;
  final String? signedUrl;
  final DateTime? signedUrlExpiresAt;
  final Map<String, dynamic> metadata;

  bool get isOfflineAvailable => localPath != null;
  bool get isRemote => remotePath != null;
  bool get needsUpload => syncStatus == MediaSyncStatus.pendingUpload || syncStatus == MediaSyncStatus.failed;

  MediaAsset copyWith({
    String? localPath,
    String? remotePath,
    String? remoteBucket,
    StorageBackend? storageBackend,
    MediaSyncStatus? syncStatus,
    int? sizeBytes,
    String? checksum,
    String? mimeType,
    DateTime? uploadedAt,
    String? signedUrl,
    DateTime? signedUrlExpiresAt,
    Map<String, dynamic>? metadata,
  }) {
    return MediaAsset(
      id: id,
      tenantId: tenantId,
      storeId: storeId,
      category: category,
      ownerEntityType: ownerEntityType,
      ownerEntityId: ownerEntityId,
      variant: variant,
      mimeType: mimeType ?? this.mimeType,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      checksum: checksum ?? this.checksum,
      localPath: localPath ?? this.localPath,
      remotePath: remotePath ?? this.remotePath,
      remoteBucket: remoteBucket ?? this.remoteBucket,
      storageBackend: storageBackend ?? this.storageBackend,
      filename: filename,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      signedUrl: signedUrl ?? this.signedUrl,
      signedUrlExpiresAt: signedUrlExpiresAt ?? this.signedUrlExpiresAt,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'tenant_id': tenantId,
        'store_id': storeId,
        'category': category.name,
        'owner_entity_type': ownerEntityType,
        'owner_entity_id': ownerEntityId,
        'variant': variant.name,
        'mime_type': mimeType,
        'size_bytes': sizeBytes,
        'checksum': checksum,
        'local_path': localPath,
        'remote_path': remotePath,
        'remote_bucket': remoteBucket,
        'storage_backend': storageBackend.name,
        'filename': filename,
        'sync_status': syncStatus.name,
        'created_at': createdAt.toIso8601String(),
        'uploaded_at': uploadedAt?.toIso8601String(),
        'signed_url': signedUrl,
        'signed_url_expires_at': signedUrlExpiresAt?.toIso8601String(),
        'metadata': metadata,
      };

  factory MediaAsset.fromJson(Map<String, dynamic> json) {
    return MediaAsset(
      id: json['id'] as String,
      tenantId: json['tenant_id'] as String,
      storeId: json['store_id'] as String?,
      category: MediaCategory.values.byName(json['category'] as String),
      ownerEntityType: json['owner_entity_type'] as String,
      ownerEntityId: json['owner_entity_id'] as String,
      variant: MediaVariant.values.byName(json['variant'] as String? ?? 'original'),
      mimeType: json['mime_type'] as String,
      sizeBytes: json['size_bytes'] as int,
      checksum: json['checksum'] as String,
      localPath: json['local_path'] as String?,
      remotePath: json['remote_path'] as String?,
      remoteBucket: json['remote_bucket'] as String?,
      storageBackend: StorageBackend.values.byName(json['storage_backend'] as String? ?? 'local'),
      filename: json['filename'] as String?,
      syncStatus: MediaSyncStatus.values.byName(json['sync_status'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      uploadedAt: json['uploaded_at'] != null ? DateTime.parse(json['uploaded_at'] as String) : null,
      signedUrl: json['signed_url'] as String?,
      signedUrlExpiresAt: json['signed_url_expires_at'] != null
          ? DateTime.parse(json['signed_url_expires_at'] as String)
          : null,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
    );
  }

  @override
  List<Object?> get props => [id, checksum, syncStatus, variant];
}

/// Request to ingest media through the engine.
class MediaUploadRequest extends Equatable {
  const MediaUploadRequest({
    required this.tenantId,
    required this.category,
    required this.ownerEntityType,
    required this.ownerEntityId,
    required this.bytes,
    required this.filename,
    this.storeId,
    this.mimeType,
    this.variant = MediaVariant.original,
    this.backend = StorageBackend.supabase,
    this.uploadImmediately = true,
    this.generateThumbnail = false,
    this.qualityProfile = UploadQualityProfile.standard,
    this.metadata = const {},
  });

  final String tenantId;
  final String? storeId;
  final MediaCategory category;
  final String ownerEntityType;
  final String ownerEntityId;
  final Uint8List bytes;
  final String filename;
  final String? mimeType;
  final MediaVariant variant;
  final StorageBackend backend;
  final bool uploadImmediately;
  final bool generateThumbnail;
  final UploadQualityProfile qualityProfile;
  final Map<String, dynamic> metadata;

  @override
  List<Object?> get props => [tenantId, category, ownerEntityId, filename];
}

/// Image processing request.
class ImageProcessRequest extends Equatable {
  const ImageProcessRequest({
    required this.bytes,
    this.operations = const [],
    this.maxWidth,
    this.maxHeight,
    this.cropRect,
    this.rotationDegrees = 0,
    this.outputFormat = ImageFormat.webp,
    this.quality = 85,
    this.thumbnailSize = 200,
  });

  final Uint8List bytes;
  final List<ImageOperation> operations;
  final int? maxWidth;
  final int? maxHeight;
  final ({int x, int y, int width, int height})? cropRect;
  final int rotationDegrees;
  final ImageFormat outputFormat;
  final int quality;
  final int thumbnailSize;

  @override
  List<Object?> get props => [operations, outputFormat, quality];
}

/// Processed image result.
class ProcessedImage extends Equatable {
  const ProcessedImage({
    required this.bytes,
    required this.mimeType,
    required this.width,
    required this.height,
    this.thumbnailBytes,
    this.thumbnailMimeType,
  });

  final Uint8List bytes;
  final String mimeType;
  final int width;
  final int height;
  final Uint8List? thumbnailBytes;
  final String? thumbnailMimeType;

  @override
  List<Object?> get props => [mimeType, width, height, bytes.length];
}

/// Upload progress event.
class UploadProgress extends Equatable {
  const UploadProgress({
    required this.jobId,
    required this.assetId,
    required this.status,
    required this.bytesUploaded,
    required this.totalBytes,
    this.errorMessage,
  });

  final String jobId;
  final String assetId;
  final UploadStatus status;
  final int bytesUploaded;
  final int totalBytes;
  final String? errorMessage;

  double get fraction => totalBytes == 0 ? 0 : bytesUploaded / totalBytes;

  @override
  List<Object?> get props => [jobId, status, bytesUploaded, totalBytes];
}

/// Download progress event.
class DownloadProgress extends Equatable {
  const DownloadProgress({
    required this.jobId,
    required this.assetId,
    required this.status,
    required this.bytesDownloaded,
    required this.totalBytes,
    this.errorMessage,
  });

  final String jobId;
  final String assetId;
  final DownloadStatus status;
  final int bytesDownloaded;
  final int totalBytes;
  final String? errorMessage;

  double get fraction => totalBytes == 0 ? 0 : bytesDownloaded / totalBytes;

  @override
  List<Object?> get props => [jobId, status, bytesDownloaded];
}

/// Upload job persisted for resume/retry.
class UploadJob extends Equatable {
  const UploadJob({
    required this.id,
    required this.assetId,
    required this.tenantId,
    required this.localPath,
    required this.remoteBucket,
    required this.remotePath,
    required this.mimeType,
    required this.totalBytes,
    required this.backend,
    required this.status,
    required this.createdAt,
    this.bytesUploaded = 0,
    this.chunkSize = 262144,
    this.uploadedChunks = const [],
    this.retryCount = 0,
    this.maxRetries = 5,
    this.errorMessage,
    this.pausedAt,
  });

  final String id;
  final String assetId;
  final String tenantId;
  final String localPath;
  final String remoteBucket;
  final String remotePath;
  final String mimeType;
  final int totalBytes;
  final StorageBackend backend;
  final UploadStatus status;
  final int bytesUploaded;
  final int chunkSize;
  final List<int> uploadedChunks;
  final int retryCount;
  final int maxRetries;
  final DateTime createdAt;
  final String? errorMessage;
  final DateTime? pausedAt;

  bool get canRetry => retryCount < maxRetries && status == UploadStatus.failed;

  UploadJob copyWith({
    UploadStatus? status,
    int? bytesUploaded,
    List<int>? uploadedChunks,
    int? retryCount,
    String? errorMessage,
    DateTime? pausedAt,
  }) {
    return UploadJob(
      id: id,
      assetId: assetId,
      tenantId: tenantId,
      localPath: localPath,
      remoteBucket: remoteBucket,
      remotePath: remotePath,
      mimeType: mimeType,
      totalBytes: totalBytes,
      backend: backend,
      status: status ?? this.status,
      bytesUploaded: bytesUploaded ?? this.bytesUploaded,
      chunkSize: chunkSize,
      uploadedChunks: uploadedChunks ?? this.uploadedChunks,
      retryCount: retryCount ?? this.retryCount,
      maxRetries: maxRetries,
      createdAt: createdAt,
      errorMessage: errorMessage ?? this.errorMessage,
      pausedAt: pausedAt ?? this.pausedAt,
    );
  }

  @override
  List<Object?> get props => [id, assetId, status, bytesUploaded];
}

/// Download job for queue management.
class DownloadJob extends Equatable {
  const DownloadJob({
    required this.id,
    required this.assetId,
    required this.tenantId,
    required this.remoteBucket,
    required this.remotePath,
    required this.backend,
    required this.status,
    required this.priority,
    required this.createdAt,
    this.bytesDownloaded = 0,
    this.totalBytes = 0,
    this.localPath,
    this.retryCount = 0,
    this.maxRetries = 5,
    this.errorMessage,
  });

  final String id;
  final String assetId;
  final String tenantId;
  final String remoteBucket;
  final String remotePath;
  final StorageBackend backend;
  final DownloadStatus status;
  final int priority;
  final int bytesDownloaded;
  final int totalBytes;
  final String? localPath;
  final int retryCount;
  final int maxRetries;
  final DateTime createdAt;
  final String? errorMessage;

  bool get canRetry => retryCount < maxRetries && status == DownloadStatus.failed;

  DownloadJob copyWith({
    DownloadStatus? status,
    int? bytesDownloaded,
    int? totalBytes,
    String? localPath,
    int? retryCount,
    String? errorMessage,
  }) {
    return DownloadJob(
      id: id,
      assetId: assetId,
      tenantId: tenantId,
      remoteBucket: remoteBucket,
      remotePath: remotePath,
      backend: backend,
      status: status ?? this.status,
      priority: priority,
      bytesDownloaded: bytesDownloaded ?? this.bytesDownloaded,
      totalBytes: totalBytes ?? this.totalBytes,
      localPath: localPath ?? this.localPath,
      retryCount: retryCount ?? this.retryCount,
      maxRetries: maxRetries,
      createdAt: createdAt,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [id, assetId, status, priority];
}

/// Remote upload result.
class RemoteStoredObject extends Equatable {
  const RemoteStoredObject({
    required this.bucket,
    required this.path,
    required this.url,
    required this.sizeBytes,
    required this.mimeType,
    this.checksum,
    this.isPublic = false,
  });

  final String bucket;
  final String path;
  final String url;
  final int sizeBytes;
  final String mimeType;
  final String? checksum;
  final bool isPublic;

  @override
  List<Object?> get props => [bucket, path, url];
}

/// Signed URL result with expiration.
class SignedUrlResult extends Equatable {
  const SignedUrlResult({
    required this.url,
    required this.expiresAt,
    required this.policy,
  });

  final String url;
  final DateTime expiresAt;
  final MediaAccessPolicy policy;

  bool get isExpired => DateTime.now().toUtc().isAfter(expiresAt);

  @override
  List<Object?> get props => [url, expiresAt];
}

/// Storage quota snapshot.
class StorageQuota extends Equatable {
  const StorageQuota({
    required this.usedBytes,
    required this.limitBytes,
    required this.tenantId,
  });

  final int usedBytes;
  final int limitBytes;
  final String tenantId;

  int get remainingBytes => (limitBytes - usedBytes).clamp(0, limitBytes);
  double get usageFraction => limitBytes == 0 ? 1 : usedBytes / limitBytes;
  bool get isExceeded => usedBytes >= limitBytes;

  @override
  List<Object?> get props => [usedBytes, limitBytes, tenantId];
}

/// Document processing result.
class ProcessedDocument extends Equatable {
  const ProcessedDocument({
    required this.bytes,
    required this.mimeType,
    required this.documentType,
    required this.sizeBytes,
    required this.checksum,
  });

  final Uint8List bytes;
  final String mimeType;
  final DocumentType documentType;
  final int sizeBytes;
  final String checksum;

  @override
  List<Object?> get props => [documentType, checksum, sizeBytes];
}
