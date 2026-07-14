# Inventory Extension Guide

## Add a new inventory entity

1. Create entity in `domain/entities/` implementing `SyncableEntity`
2. Add repository interface + `InventoryRepositoryImpl` mapping
3. Add `InventorySyncProcessor` with remote table name
4. Register processor in `inventory_module_initializer.dart`
5. Add Supabase migration + RLS policies
6. Expose via domain service with permission checks

## Add a movement type

1. Extend `MovementType` enum
2. Handle in `StockMovementService` if special rules apply
3. Update remote `inventory_movements` check constraint if used

## Warehouse-scoped queries

Use `storeId` on `syncable_records` as `warehouse_id` for indexed queries via `RepositoryQuery.storeId`.

## Barcode integration

Use `BarcodeStockActionService` — resolves product via `ProductRepository.findByBarcode` or `InventoryItemRepository.findByBarcode`.

Do not import scanner SDKs in features; use `BarcodeScannerHub` from hardware abstraction when wiring devices.
