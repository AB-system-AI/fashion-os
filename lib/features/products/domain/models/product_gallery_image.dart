import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/media/domain/media_enums.dart';

/// View model for a product gallery image — resolved via MediaEngine only.
class ProductGalleryImage extends Equatable {
  const ProductGalleryImage({
    required this.assetId,
    required this.syncStatus,
    this.displayUrl,
    this.thumbnailBytes,
    this.uploadJobId,
    this.isPrimary = false,
    this.filename,
  });

  final String assetId;
  final MediaSyncStatus syncStatus;
  final String? displayUrl;
  final List<int>? thumbnailBytes;
  final String? uploadJobId;
  final bool isPrimary;
  final String? filename;

  bool get isOfflineAvailable => thumbnailBytes != null || displayUrl != null;
  bool get needsRetry => syncStatus == MediaSyncStatus.failed;
  bool get isUploading =>
      syncStatus == MediaSyncStatus.pendingUpload || syncStatus == MediaSyncStatus.uploading;

  @override
  List<Object?> get props => [assetId, syncStatus, isPrimary];
}
