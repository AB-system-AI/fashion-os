# Purchasing Architecture

## Layers

- **Domain**: entities, enums, repository interfaces, services, `PurchaseEngine`
- **Data**: `PurchasingRepositoryImpl`, `PurchasingRemoteDataSource`, `PurchaseSyncProcessor`
- **Presentation**: Riverpod providers, Material 3 pages, GoRouter routes

## Business engines

- `PurchaseEngine` — totals, line validation, receive validation, status resolution
- `NumberGeneratorEngine` — PO, supplier, receipt, return numbers
- `InventoryEngine` / `StockMovementService` — stock increase on receive, decrease on return

## Cross-module dependencies

- **Products**: barcode lookup for receiving
- **Inventory**: stock movements on receive/return
- **Auth**: RBAC via `PermissionEngine`

## Audit

All mutations call `AuditService.log`. Receiving uses `AuditAction.inventoryChange`.
