# Workflow

## Quotation
`draft` → `sent` → `accepted` | `rejected` | `expired`

## Sales Order
`draft` → `confirmed` → `approved` → `reserved` → `picking` → `packed` → `shipped` → `delivered` → `completed` | `cancelled`

## Shipment
`pending` → `picking` → `packed` → `dispatched` → `delivered` | `failed` | `returned`

Services: `QuotationService`, `SalesOrderService`, `ReservationService`, `ShipmentService`, `DeliveryService`.
