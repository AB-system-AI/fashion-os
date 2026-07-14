# Phase 3.7 — Enterprise Media Engine

Production-grade media management. **All features must route uploads, downloads, and image processing through `MediaEngine`.**

## Architecture

```
lib/core/infrastructure/media/
├── domain/              # MediaAsset, upload/download models, enums
├── contracts/           # RemoteStorageProvider abstraction
├── adapters/            # Supabase, S3/R2/GCS/Azure, local
├── processing/          # ImageProcessor (resize, crop, WebP, …)
├── optimization/        # Network-aware compression
├── storage/             # Encrypted LocalMediaStorage + quota
├── cache/               # Memory LRU + disk validation
├── upload/              # UploadEngine (queue, resume, progress)
├── download/            # DownloadEngine (priority queue)
├── security/            # Encryption, checksums, secure delete
├── document/            # PDF, Excel, CSV, backup archives
├── barcode/             # QR/barcode raster generation
├── indexing/            # MediaIndexRepository (Drift syncable_records)
├── sync/                # Offline upload queue integration
├── events/              # Media lifecycle events
├── di/                  # Riverpod providers
└── media_engine.dart    # Single public entry point
```

## Design Rules

| Rule | Detail |
|------|--------|
| **No direct storage** | Features never call Supabase/S3 SDKs |
| **MediaEngine only** | `ref.read(mediaEngineProvider)` for all media |
| **Offline-first** | Local encrypted vault + pending upload queue |
| **Indexed** | Every asset tracked: owner, checksum, sync status |
| **Provider pattern** | `RemoteStorageProvider` per backend |

## Supported Media Categories

Products, categories, brands, customers, employees, suppliers, stores, logos, receipts, invoices, attachments, Excel, CSV, PDF, backups, QR/barcode images, future video.

## Remote Storage Backends

| Backend | Provider |
|---------|----------|
| Supabase | `SupabaseStorageProvider` |
| AWS S3 | `S3CompatibleStorageProvider` |
| Cloudflare R2 | `CloudflareR2StorageProvider` |
| Google Cloud Storage | `GoogleCloudStorageProvider` |
| Azure Blob | `AzureBlobStorageProvider` |
| Custom | `CustomStorageProviderAdapter` |
| Local (tests/offline) | `LocalRemoteStorageProvider` |

## Bootstrap

Media vault initializes after infrastructure in `bootstrap.dart`:

```dart
await container.read(mediaInitializerProvider)();
```

## Tests

```bash
flutter test test/core/infrastructure/media
```

See `docs/media/DEVELOPER_GUIDE.md` and `EXTENSION_POINTS.md`.
