# Purchasing Workflow

## Purchase order

```
DRAFT → PENDING_APPROVAL → APPROVED → SENT → PARTIALLY_RECEIVED → RECEIVED → CLOSED
                                                              ↘ CANCELLED
```

## Goods receiving

```
Purchase Order → Receive Items → Inventory Increase → Stock Movement → Audit → Sync
```

Supports partial receiving, multiple receipts, over-receive validation (configurable), short receive.

## Purchase returns

```
Return Request (DRAFT) → Approval → Stock Reduction → Supplier Balance Update → Audit → Sync
```

## Supplier financials

- Balance updated on receive (increase) and payment/refund (decrease/increase)
- Statements aggregate orders and payments into `supplier_statements`
