# Realtime

Migration `20250711000017_realtime.sql` adds selected tables to the **`supabase_realtime`** publication. Clients subscribe via Supabase Realtime; **RLS still applies** to change payloads for `authenticated` users.

## Published tables

| Table | Typical consumer | Why realtime |
|-------|------------------|--------------|
| `sale_orders` | POS floor, backoffice | Live order status and totals |
| `sale_order_lines` | POS kitchen/display | Line-level updates |
| `inventory_items` | POS stock lookup | On-hand quantity changes |
| `inventory_movements` | Backoffice inventory | Ledger stream / alerts |
| `cash_sessions` | Register supervisor | Session open/close state |
| `notifications` | Employee apps | In-app alerts |
| `sync_queue` | Offline devices | Push pending sync work |
| `product_variants` | Catalog terminals | Price/SKU updates |
| `customers` | Clienteling / POS | Profile updates at checkout |

## Recommended channels (application-side)

These are **logical channel names**; implement with `supabase.channel(name)` and Postgres `filter` on the table subscription.

| Channel pattern | Tables | Filter (Postgres changes) |
|-----------------|--------|---------------------------|
| `store:{store_id}:sales` | `sale_orders`, `sale_order_lines` | `store_id=eq.{store_id}` |
| `store:{store_id}:inventory` | `inventory_items` | Join warehouses where `store_id` matches, or filter movements by `store_id` if denormalized |
| `tenant:{tenant_id}:sync` | `sync_queue` | `tenant_id=eq.{tenant_id}` and optionally `device_id=eq.{device_id}` |
| `employee:{employee_id}:notifications` | `notifications` | `employee_id=eq.{employee_id}` |
| `tenant:{tenant_id}:catalog` | `product_variants` | `tenant_id=eq.{tenant_id}` |
| `tenant:{tenant_id}:customers` | `customers` | `tenant_id=eq.{tenant_id}` |

Migration comments document the same conventions:

```
store:{store_id}:sales     -> sale_orders.store_id=eq.{store_id}
store:{store_id}:inventory -> inventory_items via warehouse.store_id
tenant:{tenant_id}:sync    -> sync_queue.tenant_id=eq.{tenant_id}
employee:{employee_id}:notifications -> notifications.employee_id
```

## Client example (Dart / Flutter)

```dart
final channel = supabase
    .channel('store:$storeId:sales')
    .onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'sale_orders',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'store_id',
        value: storeId,
      ),
      callback: (payload) => _onSaleChanged(payload),
    )
    .subscribe();
```

## Security notes

1. Subscribe only after session has valid `tenant_id` / `employee_id` in JWT.
2. Do not rely on channel names for security — RLS must allow the row.
3. Prefer **narrow filters** to reduce fan-out and egress costs.
4. For inventory by warehouse, resolve `warehouse_ids` for the store server-side, then subscribe per warehouse or use a consolidated Edge Function fan-in.

## Tables intentionally not on Realtime

High-volume or batch tables (e.g. `audit_logs`, `loyalty_point_transactions`, purchase documents) use polling or server push to avoid unnecessary WAL fan-out. Add to publication only with product justification and load testing.

## Adding a new realtime table

```sql
ALTER PUBLICATION supabase_realtime ADD TABLE public.your_table;
```

Document the channel/filter pattern in this file and load-test with expected concurrent subscribers per store.
