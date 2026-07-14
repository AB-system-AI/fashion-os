# Sync Architecture (Phase 4.2)

## Components

| Component | Responsibility |
|---|---|
| `SyncCoordinator` | Push queue, pull deltas, checkpoints, crash recovery |
| `SyncQueueWriter` | Atomic enqueue with repository transactions |
| `SyncPullApplier` | Persist inbound remote records to Drift |
| `EntitySyncProcessor` | Per-entity push/pull adapters |
| `ConflictResolver` | Strategy-based merge |
| `SyncTenantContext` | Current tenant + device from auth session |

## Push Flow

```
Repository mutation (transaction)
  → local Drift write
  → sync_queue item (same transaction)
SyncCoordinator.sync()
  → getPending() respects scheduled_at + maxRetries
  → processor.push()
  → markCompleted / markFailed with exponential backoff
```

## Pull Flow

```
SyncCoordinator._pull()
  → read checkpoint (device + entity_type)
  → processor.pullDelta(since)
  → SyncPullApplier.applyAll()
  → save checkpoint (max version / updated_at)
```

Inbound records:

- **Create/update** → `upsertFromRemote` + FTS refresh
- **Delete** → `softDelete` + FTS removal
- **Dirty local newer** → conflict logged to `sync_conflict_history`

## Retry & Recovery

- `scheduled_at` set on failure: exponential backoff (1, 2, 4 … up to 60 minutes).
- `getPending()` only returns items where `scheduled_at` is null or ≤ now.
- `resetStuckProcessing()` on coordinator `initialize()` resets `processing` items older than 15 minutes.

## Conflict Resolution

When push returns a conflict:

1. `ConflictResolver` picks strategy (or queue override).
2. If not manual: `SyncPullApplier.applyResolvedPayload()` persists merged payload.
3. History retained in `sync_conflict_history`.

## Tenant Context

`SyncTenantContext.tenantId` is set from `AuthController` on login and cleared on logout. Pull/push never uses `tenantId: ''`.

## Testing

- `test/core/infrastructure/sync/sync_queue_writer_test.dart`
- `test/core/infrastructure/sync/sync_pull_applier_test.dart`
- `test/core/infrastructure/sync/sync_queue_retry_test.dart`
- `test/core/infrastructure/sync/conflict_resolver_test.dart`
