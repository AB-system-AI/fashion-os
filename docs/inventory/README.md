# Inventory Module

Phase 5 — Inventory & Warehouse Management for FashionOS Enterprise.

## Capabilities

- Multi-warehouse stock tracking
- Immutable stock movement ledger
- Inter-warehouse transfers with approval workflow
- Physical stock counts with variance adjustments
- Barcode-driven receive/issue
- Offline-first with sync queue and delta pull

## Architecture

```
UI (pages)
  ↓
Riverpod providers
  ↓
Domain services (WarehouseService, StockMovementService, …)
  ↓
Repositories (BaseLocalRepository / syncable_records)
  ↓
Drift local database
  ↓
Sync queue → InventorySyncProcessor → Supabase
```

## Entity Types (local `syncable_records`)

| Entity | `entity_type` | Remote table |
|---|---|---|
| Warehouse | `warehouse` | `warehouses` |
| Warehouse location | `warehouse_location` | `warehouse_locations` |
| Inventory item | `inventory_item` | `inventory_items` |
| Stock level | `stock_level` | `stock_levels` |
| Stock movement | `stock_movement` | `inventory_movements` |
| Stock reservation | `stock_reservation` | `stock_reservations` |
| Stock adjustment | `stock_adjustment` | `stock_adjustments` |
| Transfer | `inventory_transfer` | `inventory_transfers` |
| Stock count | `stock_count` | `stock_counts` |

## Routes

| Screen | Path |
|---|---|
| Dashboard | `/inventory` |
| Warehouses | `/inventory/warehouses` |
| Warehouse detail | `/inventory/warehouses/:id` |
| Stock | `/inventory/stock` |
| Movements | `/inventory/movements` |
| Transfers | `/inventory/transfers` |
| Transfer detail | `/inventory/transfers/:id` |
| Stock counts | `/inventory/counts` |
| Barcode actions | `/inventory/barcode` |

## Permissions

See `lib/core/permissions/permission_codes.dart` — `WarehousePermissions`, `InventoryPermissions`.

## Core Engine

`lib/core/business/engines/inventory/inventory_engine.dart` — stock math, reservations, transfers, availability checks.
