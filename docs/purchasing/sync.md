# Purchasing Sync

`PurchaseSyncProcessor` extends `EntitySyncProcessor` — one instance per entity type registered in `purchasing_module_initializer.dart`.

## Push

Repository writes enqueue via `SyncQueueWriter`. Processor pushes to Supabase table matching entity.

## Pull

Delta pull uses `updated_at >= since` per table. Checkpoint/version tracked by `SyncCoordinator`.

## Conflict resolution

Inherited from core sync infrastructure (`SyncPullApplier`, conflict history).
