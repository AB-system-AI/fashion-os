# Infrastructure Testing Strategy

## Unit Tests

| Area | Path | Focus |
|------|------|-------|
| Conflict resolution | `test/core/infrastructure/sync/conflict_resolver_test.dart` | All 5 strategies |
| Sync queue | `test/core/infrastructure/sync/sync_queue_writer_test.dart` | Enqueue, complete |
| Repository DAO | `test/core/infrastructure/repository/syncable_record_dao_test.dart` | CRUD, soft delete, pagination |

## Integration Tests (planned)

- Full sync cycle with mock processor
- Offline enqueue → online drain
- Network recovery triggers sync
- Database encryption open/close

## Running Tests

```bash
flutter test test/core/infrastructure
```

## In-Memory Database

All repository/sync tests use `AppDatabase.inMemory()` — no SQLCipher required in tests.

## Performance Tests (planned)

- 100k syncable records pagination < 100ms
- FTS search < 100ms at 100k products
- Sync queue batch of 50 < 1s
