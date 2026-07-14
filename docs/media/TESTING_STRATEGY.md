# Media Engine — Testing Strategy

## Location

```
test/core/infrastructure/media/
├── image_processor_test.dart
├── media_security_test.dart
├── local_media_storage_test.dart
├── remote_storage_test.dart
├── document_engine_test.dart
├── media_optimizer_test.dart
├── media_cache_test.dart
└── upload_engine_test.dart
```

## Run

```bash
flutter test test/core/infrastructure/media
```

## Categories

| Category | Files | Focus |
|----------|-------|-------|
| Compression | `image_processor_test`, `media_optimizer_test` | Resize, WebP, network profiles |
| Storage | `local_media_storage_test` | Encryption, quota, cleanup |
| Security | `media_security_test` | Checksum, AES roundtrip |
| Upload | `upload_engine_test` | Queue, offline provider |
| Remote | `remote_storage_test` | Local + S3-compatible store |
| Cache | `media_cache_test` | LRU memory + disk validation |
| Documents | `document_engine_test` | CSV, backup zip |
| Offline | `upload_engine_test` | Queue without network (mock online monitor) |

## Test Patterns

- Use `AppDatabase.inMemory()` for index tests
- Use `Directory.systemTemp` for local vault tests
- Use `LocalRemoteStorageProvider` + in-memory map for remote simulation
- Subclass `NetworkMonitor` to force online state in upload tests
- No Flutter bindings required for engine unit tests

## CI

```yaml
- run: flutter test test/core/infrastructure/media --reporter expanded
```

## Not Tested Here

- Supabase live integration (use staging E2E separately)
- UI image widgets (`app_image_cache.dart` — display only)
