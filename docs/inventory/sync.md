# Inventory Sync

## Processors

Registered in `inventory_module_initializer.dart`:

- `warehouse` → `warehouses`
- `inventory_item` → `inventory_items`
- `stock_level` → `stock_levels`
- `stock_movement` → `inventory_movements`
- `inventory_transfer` → `inventory_transfers`
- `stock_count` → `stock_counts`

## Push

Repository create/update/delete → `sync_queue_items` → `SyncCoordinator` → `InventorySyncProcessor.push()`.

## Pull

Per-entity checkpoint in `sync_checkpoints` → `pullDelta(since)` → `SyncPullApplier` with tenant isolation.

## Conflicts

Dirty local records newer than remote are skipped and logged to `sync_conflict_history`.

## Remote Schema

`supabase/migrations/20250712000003_inventory_warehouse.sql`
