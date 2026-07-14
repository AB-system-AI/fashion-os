# Customers Sync

`CustomerSyncProcessor` extends `EntitySyncProcessor` — registered per entity in `customers_module_initializer.dart`.

## Push / Pull

Repository writes enqueue via `SyncQueueWriter`. Processor pushes to matching Supabase table and pulls delta by `updated_at`.

## Checkpoint

Managed by core `SyncCoordinator` with conflict resolution via `SyncPullApplier`.
