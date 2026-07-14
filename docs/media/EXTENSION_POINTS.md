# Media Engine — Extension Points

## Custom Remote Storage

Implement `RemoteStorageProvider` or wrap with `CustomStorageProviderAdapter`:

```dart
class MyStorageProvider implements CustomStorageProvider {
  @override
  String get providerId => 'my_cdn';

  @override
  Future<Result<RemoteStoredObject>> upload({...}) async { ... }
  // download, delete, getSignedUrl, ...
}

ref.read(remoteStorageProvidersProvider)[StorageBackend.custom] = MyStorageProvider();
```

## Register S3 / R2 Production Credentials

Override `remoteStorageProvidersProvider`:

```dart
S3CompatibleStorageProvider(
  backend: StorageBackend.cloudflareR2,
  endpoint: 'https://<account>.r2.cloudflarestorage.com',
  region: 'auto',
  accessKeyId: config.r2Key,
  secretAccessKey: config.r2Secret,
  objectStore: sharedObjectStore, // optional HTTP-backed store
),
```

## Encryption Key

Override `mediaSecurityServiceProvider` with tenant/device-derived key from `flutter_secure_storage`.

## Quota Limits

Configure per-tenant limits by wrapping `LocalMediaStorage` or extending `defaultQuotaBytes`.

## Thumbnail Profiles

Extend `ImageProcessor` or pass custom `ImageProcessRequest` before upload.

## Video (Future)

Add `MediaCategory.video` pipeline with chunked upload and `video/*` MIME in bucket config.

## DOCX (Future)

Extend `DocumentEngine._detectType` and MIME map when library is added.

## AVIF (Future)

Add encoder branch in `ImageProcessor._encode` when `image` package AVIF support is enabled.

## Background Upload Tenant

Pass `MediaSyncIntegration` + `defaultTenantId` to `BackgroundTaskScheduler`:

```dart
BackgroundTaskScheduler(
  syncCoordinator: sync,
  backupManager: backup,
  mediaSync: ref.read(mediaSyncIntegrationProvider),
  defaultTenantId: activeTenantId,
);
```

## Conflict Resolution

Use `MediaSyncIntegration.detectConflict()` and emit `MediaSyncConflictEvent` before overwriting remote objects.

## Storage Adapter Bridge

Legacy `StorageService` (`lib/core/infrastructure/storage/`) can register adapters that delegate to `RemoteStorageProvider` for backward compatibility.
