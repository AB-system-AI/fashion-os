# Product Catalog — Media Integration

All product image operations flow through **MediaEngine**. UI and domain services must never call storage providers directly.

## Architecture

```
ProductImageGallerySection (UI)
  → ProductMediaGalleryController (Riverpod)
    → ProductMediaGalleryService (domain)
      → ProductCatalogService (attach/reorder/remove metadata)
      → MediaEngine (upload, bytes, signed URLs, delete, retry)
      → AuditService (image_upload, image_delete, image_reorder, image_replace)
```

## Capabilities

| Feature | Implementation |
|---------|----------------|
| Camera / gallery capture | `image_picker` in `ProductImageGallerySection` |
| Upload & compression | `MediaEngine.upload` + `MediaOptimizer` (WebP) |
| Thumbnails | `MediaEngine` auto-generates `{assetId}_thumb` |
| Offline cache | `LocalMediaStorage` + `MediaCacheManager` |
| Background upload queue | `UploadEngine.processOfflineQueue` on gallery load |
| Sync status | `MediaSyncStatus` chip in `ProductImageGallery` |
| Retry failed uploads | `MediaEngine.retryUpload` |
| Signed URLs | `MediaEngine.getSignedUrl` only |
| Reorder / primary | `ProductCatalogService.reorderImages` (index 0 = primary) |
| Replace / delete | `ProductMediaGalleryService` coordinates media + catalog |

## Usage

Embed on edit/detail screens:

```dart
ProductImageGallerySection(productId: product.id)
```

## Offline behavior

- Images are written to encrypted local storage immediately.
- Thumbnails display from local bytes when signed URLs are unavailable.
- Upload jobs queue when offline and process when `processOfflineUploadQueue` runs.

## Permissions

Requires `product.update` (enforced in `ProductCatalogService.uploadProductImage`).
