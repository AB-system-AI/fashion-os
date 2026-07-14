import 'dart:typed_data';

import 'package:fashion_pos_enterprise/core/audit/audit_action.dart';
import 'package:fashion_pos_enterprise/core/audit/audit_service.dart';
import 'package:fashion_pos_enterprise/core/errors/failure.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/domain/media_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/domain/media_models.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/media_engine.dart';
import 'package:fashion_pos_enterprise/core/result/result.dart';
import 'package:fashion_pos_enterprise/features/auth/domain/entities/auth_user.dart';
import 'package:fashion_pos_enterprise/features/products/domain/entities/product.dart';
import 'package:fashion_pos_enterprise/features/products/domain/models/product_gallery_image.dart';
import 'package:fashion_pos_enterprise/features/products/domain/services/product_catalog_service.dart';

/// Product image operations — all storage access via [MediaEngine].
class ProductMediaGalleryService {
  ProductMediaGalleryService({
    required ProductCatalogService catalogService,
    required MediaEngine mediaEngine,
    required AuditService auditService,
  })  : _catalog = catalogService,
        _media = mediaEngine,
        _audit = auditService;

  final ProductCatalogService _catalog;
  final MediaEngine _media;
  final AuditService _audit;

  Future<List<ProductGalleryImage>> loadGallery({required Product product}) async {
    final images = <ProductGalleryImage>[];
    for (var i = 0; i < product.imageAssetIds.length; i++) {
      final assetId = product.imageAssetIds[i];
      final asset = await _media.getAsset(assetId);
      images.add(
        ProductGalleryImage(
          assetId: assetId,
          syncStatus: asset?.syncStatus ?? MediaSyncStatus.localOnly,
          displayUrl: await _resolveDisplayUrl(assetId),
          thumbnailBytes: await _resolveThumbnailBytes(assetId),
          isPrimary: i == 0,
          filename: asset?.filename,
        ),
      );
    }
    return images;
  }

  Future<Result<Product>> uploadImage({
    required AuthUser user,
    required Product product,
    required Uint8List bytes,
    required String filename,
    bool primary = false,
  }) async {
    final upload = await _catalog.uploadProductImage(
      user: user,
      productId: product.id,
      bytes: bytes,
      filename: filename,
      tenantId: product.tenantId,
    );
    if (upload.isFailure) return Error(upload.failureOrNull!);
    final asset = upload.dataOrNull!;
    await _audit.log(
      action: AuditAction.update,
      entityType: Product.entityTypeName,
      tenantId: product.tenantId,
      employeeId: user.employeeId,
      entityId: product.id,
      metadata: {'change_type': 'image_upload', 'asset_id': asset.id},
    );
    return _catalog.attachUploadedImage(user: user, product: product, assetId: asset.id, primary: primary);
  }

  Future<Result<Product>> deleteImage({
    required AuthUser user,
    required Product product,
    required String assetId,
  }) async {
    await _media.delete(assetId);
    final thumbId = '${assetId}_thumb';
    await _media.delete(thumbId);
    final result = await _catalog.removeImage(user: user, product: product, assetId: assetId);
    if (result.isSuccess) {
      await _audit.log(
        action: AuditAction.update,
        entityType: Product.entityTypeName,
        tenantId: product.tenantId,
        employeeId: user.employeeId,
        entityId: product.id,
        metadata: {'change_type': 'image_delete', 'asset_id': assetId},
      );
    }
    return result;
  }

  Future<Result<Product>> replaceImage({
    required AuthUser user,
    required Product product,
    required String oldAssetId,
    required Uint8List bytes,
    required String filename,
  }) async {
    final wasPrimary = product.imageAssetIds.isNotEmpty && product.imageAssetIds.first == oldAssetId;
    final upload = await uploadImage(
      user: user,
      product: product,
      bytes: bytes,
      filename: filename,
      primary: wasPrimary,
    );
    if (upload.isFailure) return upload;
    var updated = upload.dataOrNull!;
    final deleteResult = await deleteImage(user: user, product: updated, assetId: oldAssetId);
    if (deleteResult.isSuccess) updated = deleteResult.dataOrNull!;
    await _audit.log(
      action: AuditAction.update,
      entityType: Product.entityTypeName,
      tenantId: product.tenantId,
      employeeId: user.employeeId,
      entityId: product.id,
      metadata: {'change_type': 'image_replace', 'old_asset_id': oldAssetId},
    );
    return Success(updated);
  }

  Future<Result<Product>> reorderImages({
    required AuthUser user,
    required Product product,
    required List<String> imageAssetIds,
  }) async {
    final result = await _catalog.reorderImages(user: user, product: product, imageAssetIds: imageAssetIds);
    if (result.isSuccess) {
      await _audit.log(
        action: AuditAction.update,
        entityType: Product.entityTypeName,
        tenantId: product.tenantId,
        employeeId: user.employeeId,
        entityId: product.id,
        metadata: {'change_type': 'image_reorder', 'order': imageAssetIds},
      );
    }
    return result;
  }

  Future<Result<MediaAsset>> retryFailedUpload(String jobId) => _media.retryUpload(jobId);

  Future<void> processOfflineQueue() => _media.processOfflineUploadQueue();

  Future<String?> _resolveDisplayUrl(String assetId) async {
    final signed = await _media.getSignedUrl(assetId);
    if (signed.isSuccess) return signed.dataOrNull!.url;
    return null;
  }

  Future<List<int>?> _resolveThumbnailBytes(String assetId) async {
    final thumb = await _media.getBytes('${assetId}_thumb');
    if (thumb.isSuccess) return thumb.dataOrNull;
    final original = await _media.getBytes(assetId);
    if (original.isSuccess) return original.dataOrNull;
    return null;
  }
}
