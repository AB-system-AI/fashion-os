# Inventory Architecture

## Layers

### Domain

- **Entities** — `lib/features/inventory/domain/entities/`
- **Enums** — movement types, transfer status, stock count status
- **Value objects** — `Quantity`
- **Services** — business rules + `PermissionEngine` + `AuditService`

### Data

- **Repositories** — `InventoryRepositoryImpl<T>` extends `BaseLocalRepository`
- **Remote** — `InventoryRemoteDataSource` (Supabase table per entity)
- **Sync** — `InventorySyncProcessor` per entity type

### Presentation

- Thin pages — no direct DB or Supabase calls
- Providers in `inventory_providers.dart`
- Module init registers sync processors in bootstrap

## Stock Ledger Rules

1. Movements are **immutable** — never update history
2. Corrections use **reversal movements** (`reversal_of_id`)
3. Every quantity change creates a movement + updates `stock_level`
4. Available = on_hand − reserved − damaged

## Transfer Workflow

```
DRAFT → PENDING_APPROVAL → SHIPPED → RECEIVED → COMPLETED
                              ↘ CANCELLED
```

Ship triggers issue from source; receive triggers receipt at destination.

## Offline-First

All repository mutations run in Drift transactions with sync queue enqueue (inherited from `BaseLocalRepository`).
