# Accounting Integration

`SalesIntegrationService` listens for `sales_order.confirmed` and `shipment.dispatched` events and writes integration audit metadata for accounting hooks.

Invoice eligibility via `SalesOrderEngine.isInvoiceEligible`. `SalesInvoiceReference` entity links orders to journal entries.

Extend `AccountingIntegrationService` to subscribe to OMS events for revenue recognition.
