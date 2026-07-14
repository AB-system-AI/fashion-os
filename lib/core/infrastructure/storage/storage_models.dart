import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/media/domain/media_enums.dart';

/// Storage bucket mapping aligned with Supabase migration buckets.
class StorageBucket extends Equatable {
  const StorageBucket({
    required this.name,
    required this.isPublic,
    required this.maxSizeBytes,
    required this.allowedMimeTypes,
    required this.mediaCategory,
  });

  final String name;
  final bool isPublic;
  final int maxSizeBytes;
  final List<String> allowedMimeTypes;
  final MediaCategory mediaCategory;

  bool acceptsMime(String mimeType) => allowedMimeTypes.contains(mimeType);

  bool acceptsSize(int bytes) => bytes <= maxSizeBytes;

  @override
  List<Object?> get props => [name, isPublic, maxSizeBytes];
}

/// Well-known storage buckets from STORAGE.md.
abstract final class StorageBuckets {
  static const productImages = StorageBucket(
    name: 'product-images',
    isPublic: true,
    maxSizeBytes: 5 * 1024 * 1024,
    allowedMimeTypes: ['image/jpeg', 'image/png', 'image/webp', 'image/gif'],
    mediaCategory: MediaCategory.product,
  );

  static const receipts = StorageBucket(
    name: 'receipts',
    isPublic: false,
    maxSizeBytes: 10 * 1024 * 1024,
    allowedMimeTypes: ['application/pdf', 'image/png', 'image/jpeg', 'text/html'],
    mediaCategory: MediaCategory.receipt,
  );

  static const expenseReceipts = StorageBucket(
    name: 'expense-receipts',
    isPublic: false,
    maxSizeBytes: 10 * 1024 * 1024,
    allowedMimeTypes: ['application/pdf', 'image/png', 'image/jpeg'],
    mediaCategory: MediaCategory.receipt,
  );

  static const storeAssets = StorageBucket(
    name: 'store-assets',
    isPublic: true,
    maxSizeBytes: 2 * 1024 * 1024,
    allowedMimeTypes: ['image/jpeg', 'image/png', 'image/webp', 'image/svg+xml'],
    mediaCategory: MediaCategory.store,
  );

  static const employeeAvatars = StorageBucket(
    name: 'employee-avatars',
    isPublic: false,
    maxSizeBytes: 2 * 1024 * 1024,
    allowedMimeTypes: ['image/jpeg', 'image/png', 'image/webp'],
    mediaCategory: MediaCategory.employee,
  );

  static const imports = StorageBucket(
    name: 'imports',
    isPublic: false,
    maxSizeBytes: 50 * 1024 * 1024,
    allowedMimeTypes: [
      'text/csv',
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'application/json',
    ],
    mediaCategory: MediaCategory.attachment,
  );

  static StorageBucket forCategory(MediaCategory category) {
    return switch (category) {
      MediaCategory.product => productImages,
      MediaCategory.receipt => receipts,
      MediaCategory.store || MediaCategory.logo => storeAssets,
      MediaCategory.employee => employeeAvatars,
      MediaCategory.attachment ||
      MediaCategory.excel ||
      MediaCategory.csv ||
      MediaCategory.backup =>
        imports,
      _ => storeAssets,
    };
  }
}

/// Builds tenant-scoped object keys: `{tenantId}/{entityType}/{entityId}/{filename}`.
class StoragePathBuilder {
  const StoragePathBuilder();

  String build({
    required String tenantId,
    required String entityType,
    required String entityId,
    required String filename,
  }) {
    return '$tenantId/$entityType/$entityId/$filename';
  }

  String employeeAvatar({required String userId, required String extension}) {
    return '$userId/avatar.$extension';
  }
}
