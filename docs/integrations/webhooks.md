# Webhooks

`WebhookEndpoint` entities subscribe to domain events and dispatch HTTP callbacks.

## Service

`WebhookService` — create endpoints, dispatch events to matching subscribers.

## Events

Store event names in `events` JSON array (e.g. `sales_order.confirmed`, `shipment.dispatched`).

## Permissions

`webhook.manage` required.

## Remote table

`webhooks`
