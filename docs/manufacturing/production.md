# Production Orders & Work Orders

## Production workflow

`draft` → `planned` → `released` → `inProgress` → (`paused`) → `completed` → `closed`

Cancelled from most pre-completed states.

## Work order workflow

`draft` → `assigned` → `started` → (`paused`) → `completed` or `rejected`

## Entities

- `ProductionOrder`, `ProductionOrderLine`
- `WorkOrder`, `Operation`
- `MaterialIssue`, `MaterialReturn`
- `ProductionOutput`, `ProductionScrap`, `FinishedGoodsReceipt`

## Services

| Service | Responsibility |
|---------|----------------|
| `ProductionOrderService` | Create, release, start, complete |
| `WorkOrderService` | Assign, start, complete shop floor work |
| `MaterialConsumptionService` | Issue and return materials |
| `ProductionReceiptService` | Record output, scrap, FG receipt |

## Document numbers

`MO-` production orders, `WO-` work orders via `NumberGeneratorEngine`.

## Permissions

`production.create`, `production.release`, `production.complete`
