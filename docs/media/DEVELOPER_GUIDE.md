# Media Engine — Developer Guide

## Uploading Media

**Never** call `supabase.storage` or file APIs from feature code.

```dart
final media = ref.read(mediaEngineProvider);

final result = await media.upload(
  MediaUploadRequest(
    tenantId: tenantId,
    category: MediaCategory.product,
    ownerEntityType: 'product',
    ownerEntityId: productId,
    bytes: imageBytes,
    filename: '$productId-front.webp',
    generateThumbnail: true,
    uploadImmediately: true,
    backend: StorageBackend.supabase,
  ),
);

result.fold(
  onSuccess: (asset) => saveProductImageRef(asset.id),
  onFailure: (f) => showError(f.message),
);
```

## Batch Upload

```dart
await media.uploadMany([
  MediaUploadRequest(...),
  MediaUploadRequest(...),
]);
```

## Download / Offline Access

```dart
final bytes = await media.getBytes(assetId);
await media.download(assetId, priority: 10);
media.downloadProgress(jobId).listen((p) => updateUi(p.fraction));
```

## Image Processing

```dart
await media.processImage(ImageProcessRequest(
  bytes: raw,
  operations: [ImageOperation.resize, ImageOperation.compress, ImageOperation.thumbnail],
  maxWidth: 1280,
  outputFormat: ImageFormat.webp,
  quality: 85,
));
```

## QR / Barcode as Media

```dart
await media.generateQrAsset(
  baseRequest: MediaUploadRequest(...),
  qrData: 'https://receipts.example.com/$saleId',
);
```

## Signed URLs

```dart
final signed = await media.getSignedUrl(assetId, expiration: Duration(hours: 1));
```

## Upload Control

```dart
await media.pauseUpload(jobId);
await media.cancelUpload(jobId);
await media.retryUpload(jobId);
await media.processOfflineUploadQueue();
```

## Storage Quota

```dart
final quota = await media.quota(tenantId);
if (quota.isExceeded) { /* block upload */ }
```

## Path Convention

Remote paths follow `docs/database/STORAGE.md`:

```
{tenant_id}/{entity_type}/{entity_id}/{filename}
```

Buckets are selected automatically via `StorageBuckets.forCategory()`.

## Background Sync

When `BackgroundTaskScheduler` is configured with `MediaSyncIntegration`, pending uploads drain every 5 minutes while online.

## Error Handling

All operations return `Result<T>`. Common codes:

| Code | Meaning |
|------|---------|
| `quota_exceeded` | Tenant vault full |
| `invalid_mime` | MIME not allowed for bucket |
| `file_too_large` | Exceeds bucket max |
| `checksum_invalid` | Cache validation failed |
| `no_remote` | Asset not uploaded yet |
