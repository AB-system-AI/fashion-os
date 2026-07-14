# POS Architecture

## Layers

```
UI (pages) → Riverpod providers → Application services → Repositories → syncable_records (Drift) → SyncQueue → PosSyncProcessor → Supabase
```

Business rules live in **SalesEngine** and existing engines (`PricingEngine`, `TaxEngine`, `PromotionEngine`, `CashSessionEngine`, `ReceiptEngine`). Widgets contain zero business logic.

## Services

| Service | Responsibility |
|---------|----------------|
| `POSService` | Draft sales, lines, suspend/resume, product search |
| `CheckoutService` | Complete sale, payments, stock issue, events |
| `CashDrawerService` | Open/close session, movements |
| `ReceiptService` | Generate, print, reprint |
| `CouponService` | Validate and apply coupons |
| `SplitPaymentService` | Multi-tender validation |
| `BarcodeSaleService` | Barcode → sale line |
| `ReturnValidationService` / `ExchangeValidationService` | Refund/exchange rules |
| `LayawayService` | Deposit and schedule |

## Hardware

Uses infrastructure abstractions only (`BarcodeScannerHub`, `PrinterHub`, etc.) — no SDK coupling in feature code.

## Events

- `SaleCompletedEvent`
- `SaleCancelledEvent`
- `PaymentReceivedEvent`
- `CashSessionClosedEvent`
