# Manufacturing Inventory

## Release flow

1. `ProductionOrderService.release` validates transition
2. For each `ProductionOrderLine`, reserves stock via `InventoryEngine.reserveStock`
3. Persists `StockReservation` with `referenceType: production_order`
4. Runs MRP and creates purchase orders for shortages

## Issue flow

`MaterialConsumptionService.issue`:

1. Persists `MaterialIssue`
2. Calls `StockMovementService.issueStock`
3. Publishes `material.issued` → accounting journal

## Return flow

`MaterialConsumptionService.returnMaterial`:

1. Persists `MaterialReturn`
2. Calls `StockMovementService.receiveStock`
3. Publishes `material.returned`

## Finished goods

`ProductionReceiptService.receive`:

1. Persists `FinishedGoodsReceipt`
2. Calls `StockMovementService.receiveStock`
3. Stock immediately available for POS sale
4. Publishes `finished_goods.received` → accounting

Never duplicate inventory logic — always call `StockMovementService` and `InventoryEngine`.
