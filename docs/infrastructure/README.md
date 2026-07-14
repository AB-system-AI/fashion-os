# Phase 3.5 — Core Infrastructure

Production-grade infrastructure layer that all feature modules depend on.

## Architecture

```
lib/core/infrastructure/
├── database/          # Drift ORM + SQLCipher + DAOs
├── repository/        # BaseLocalRepository + RepositoryQuery
├── sync/              # SyncCoordinator, conflicts, queue
├── network/           # NetworkMonitor, RetryExecutor
├── storage/           # StorageAdapter interfaces
├── feature_flags/     # Offline-capable feature flags
├── license/           # LicenseEngine facade
├── remote_config/     # RemoteConfigManager
├── logging/           # CentralLogger + sinks
├── analytics/         # AnalyticsProvider interfaces
├── crash/             # CrashReportingProvider interfaces
├── background/        # BackgroundTaskScheduler
├── cache/             # Memory + disk cache
├── hardware/          # Barcode + printer interfaces
└── di/                # Riverpod providers
```

## Local Database (Drift)

- **ORM:** Drift with typed DAOs and companions
- **Encryption:** SQLCipher via `sqlcipher_flutter_libs`
- **Migrations:** `MigrationStrategy` in `AppDatabase`
- **Tables:** sync queue, checkpoints, logs, syncable records, audit, license, settings, feature flags

### Syncable Records Pattern

All feature entities persist through `syncable_records`:

| Column | Purpose |
|--------|---------|
| `version` | Optimistic concurrency |
| `created_at` / `updated_at` / `deleted_at` | Audit + soft delete |
| `sync_status` / `is_dirty` | Offline sync tracking |
| `search_*` | Indexed search columns + FTS5 |

## Repository Layer

Extend `BaseLocalRepository<T>` for any feature module:

```dart
class ProductRepository extends BaseLocalRepository<Product> {
  ProductRepository({required AppDatabase db, required SyncQueueWriter sync})
      : super(database: db, entityType: 'product', syncQueue: sync);

  @override
  Product mapFromLocalRecord(LocalRecord record) => Product.fromJson(record.payload);

  @override
  LocalRecord mapToLocalRecord(Product entity) => LocalRecord(...);
}
```

Supports: CRUD, soft delete, restore, pagination, search, watch, sync enqueue.

## Sync Framework

`SyncCoordinator` provides:

- Background / manual / scheduled / network-recovery sync
- Exponential backoff retry (via queue `scheduled_at`)
- Conflict detection + resolution (server/client/LWW/manual/custom)
- Delta pull via `EntitySyncProcessor.pullDelta`
- Checkpoints per device + entity type
- Progress stream + lifecycle events
- Pause / resume / cancel

## Network Layer

`NetworkMonitor` detects:

- WiFi / mobile / offline
- Captive portal (DNS lookup failure with connectivity)
- Poor connection (HTTP latency probe)

`RetryExecutor` provides exponential backoff with jitter.

## Extension Points

| Interface | Future Implementation |
|-----------|----------------------|
| `EntitySyncProcessor` | Per-entity push/pull |
| `StorageAdapter` | Supabase, S3 |
| `AnalyticsProvider` | Firebase, Mixpanel |
| `CrashReportingProvider` | Sentry, Crashlytics |
| `BarcodeScannerAdapter` | Camera, USB HID, BLE, NFC |
| `PrinterAdapter` | Bluetooth, USB, WiFi, PDF |

## Bootstrap Wiring

```dart
await container.read(infrastructureInitializerProvider)();
```

Initializes: database, network monitor, sync coordinator, background tasks, analytics, crash reporting, feature flags.

## Code Generation

After modifying Drift tables/DAOs:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Related Docs

- [Developer Guide](./DEVELOPER_GUIDE.md)
- [Sequence Diagrams](./SEQUENCE_DIAGRAMS.md)
- [Testing Strategy](./TESTING_STRATEGY.md)
