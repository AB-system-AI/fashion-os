# Purchasing & Suppliers (Phase 6)

Offline-first purchasing module: suppliers, purchase orders, goods receiving, returns, supplier financials, and sync.

## Routes

| Screen | Path |
|--------|------|
| Dashboard | `/purchasing` |
| Suppliers | `/purchasing/suppliers` |
| Supplier detail | `/purchasing/suppliers/:id` |
| Purchase orders | `/purchasing/orders` |
| PO detail | `/purchasing/orders/:id` |
| Receive goods | `/purchasing/receive` |
| Returns | `/purchasing/returns` |
| Statement | `/purchasing/statements/:id` |
| Reports | `/purchasing/reports` |

## Entity types (sync)

| Entity | `entity_type` | Remote table |
|--------|---------------|--------------|
| Supplier | `supplier` | `suppliers` |
| PurchaseOrder | `purchase_order` | `purchase_orders` |
| PurchaseReceipt | `purchase_receipt` | `purchase_receipts` |
| PurchaseReturn | `purchase_return` | `purchase_returns` |
| SupplierPayment | `supplier_payment` | `supplier_payments` |
| SupplierStatement | `supplier_statement` | `supplier_statements` |

## Permissions

- `supplier.view`, `supplier.create`, `supplier.update`, `supplier.delete`
- `purchase.view`, `purchase.create`, `purchase.update`, `purchase.approve`, `purchase.send`, `purchase.receive`, `purchase.close`, `purchase.cancel`, `purchase.payment`, `purchase.return.create`, `purchase.return.approve`, `purchase.report`

## Architecture

```
UI → Riverpod → Application Services → Repositories → syncable_records → Sync Queue → PurchaseSyncProcessor → Supabase
```

Receiving integrates with `StockMovementService` and publishes `PurchaseReceivedEvent`.
