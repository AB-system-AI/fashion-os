# POS Sync

Processors registered in `posModuleInitializerProvider`:

| Processor | Entity type | Remote table |
|-----------|-------------|--------------|
| SalesSyncProcessor | `sale_order` | `sale_orders` |
| Payment | `sale_payment` | `sale_payments` |
| CashSessionSyncProcessor | `cash_session` | `cash_sessions` |
| ReceiptSyncProcessor | `receipt` | `receipt_history` |
| ReturnSyncProcessor | `sale_return` | `sale_returns` |
| ExchangeSyncProcessor | `exchange` | `exchanges` |
| LayawaySyncProcessor | `layaway_order` | `layaway_orders` |
| Coupon | `coupon` | `coupons` |

Migration: `20250712000006_sales_pos_enterprise.sql`
