# Inventory Integration

`ReservationService` uses:
- `InventoryEngine.reserveStock`
- `StockReservationRepository` with `referenceType: sales_order`
- `BackOrder` entity for shortfalls
- `StockMovementService` on shipment issue (via `ShipmentService`)

No duplicate of inventory ledger logic.
