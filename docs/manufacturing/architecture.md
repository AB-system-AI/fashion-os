# Manufacturing Architecture

## Layering

```
UI (Riverpod pages)
  → Application Services (BomService, ProductionOrderService, …)
    → Repository interfaces
      → Local repository implementations (Drift syncable_records)
        → Sync queue → ManufacturingSyncProcessor → Supabase
```

Business rules live in `ManufacturingEngine` only. Widgets never contain domain logic.

## Offline-first mutation pipeline

Every write:

1. Drift transaction on `syncable_records`
2. Audit log entry
3. Sync queue enqueue
4. Domain event publish (when applicable)
5. RBAC check via `PermissionService`
6. Tenant scoping on all queries

## Module initializer

`manufacturingModuleInitializerProvider` registers eight sync processors and starts `ManufacturingIntegrationService`.

## Integrations

| Module | Hook |
|--------|------|
| Inventory | Material issue, FG receipt, stock reservation |
| Purchasing | MRP purchase suggestions |
| Accounting | WIP, variance, COGS (event stubs) |
| HR | Labor hours on work orders |
| CRM | Make-to-order production orders |
| POS | Sell manufactured finished goods |

## Events

Published via `DomainEventBus`: production started/completed, work order completed, material issued/returned, quality passed/failed, finished goods received.
