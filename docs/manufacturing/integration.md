# Manufacturing Integrations

Phase 11.1 wires Manufacturing into the full ERP stack.

## Inventory

| Trigger | Service call |
|---------|--------------|
| Production release | `InventoryEngine.reserveStock` + `StockReservation` |
| Material issue | `StockMovementService.issueStock` |
| Material return | `StockMovementService.receiveStock` |
| Finished goods receipt | `StockMovementService.receiveStock` (POS-available) |

## Purchasing

| Trigger | Service call |
|---------|--------------|
| MRP shortage on release | `ProductionPlanningService.createPurchaseOrdersFromShortages` → `PurchaseOrderService.create` |

Uses product `supplierId`, MOQ defaults, supplier priority sorting.

## Accounting

`AccountingIntegrationService` subscribes to manufacturing events and posts via `AccountingEngine` + `PostingService.createAutoJournal`:

- `material.issued` → WIP / Inventory
- `material.returned` → Inventory / WIP
- `production.started` → WIP overhead allocation
- `production.completed` → manufacturing variance
- `finished_goods.received` → Inventory / WIP

## HR

`WorkOrderService.complete` calculates labor via `HREngine.calculateOvertimeAmount` with regular hours, overtime, and shift premium.

## CRM / Make-to-Order

`ProductionOrderService.createFromCustomerOrder` creates production demand from customer orders.

## POS

Finished goods receipt increases on-hand stock immediately via `StockMovementService.receiveStock`.

## Events

All integration paths audit via `ManufacturingIntegrationService` and domain `AuditService`.
