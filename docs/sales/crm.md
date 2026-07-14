# CRM Integration

- Customer credit validation in `SalesOrderService.create`
- `CustomerTimelineService` records quotation/order/shipment events
- Wallet/loyalty: extend via existing `WalletService` / `LoyaltyService` at payment capture (future POS bridge)

Timeline entity: `customer_order_timeline`
