# Performance

FashionOS migrations define **~180 indexes** on hot paths: tenant scoping, foreign keys, status filters, and partial unique indexes for soft-deleted masters.

## Index strategy

### 1. Tenant scoping

Nearly every tenant table has:

```sql
CREATE INDEX {table}_tenant_id_idx ON public.{table} (tenant_id);
```

Always filter by `tenant_id` first in application queries so Postgres can use these indexes.

### 2. Partial unique indexes (soft delete)

Masters such as `tenants`, `stores`, `employees`, `roles`, `products` use:

```sql
CREATE UNIQUE INDEX ... ON ... (tenant_id, code) WHERE deleted_at IS NULL;
```

Queries for active rows should include `deleted_at IS NULL` to match partial index predicates.

### 3. Foreign key indexes

All major FK columns are indexed (e.g. `sale_orders.store_id`, `sale_order_lines.sale_order_id`, `inventory_items.variant_id`). This speeds joins and `ON DELETE` cascades.

### 4. Operational filters

Examples from migrations:

| Index | Use case |
|-------|----------|
| `stores_status_idx` | Active store pickers |
| `tenant_subscriptions_status_idx` | Billing dashboards |
| `sale_orders_store_status_created_idx` | POS history by store |
| `inventory_items_warehouse_variant_uidx` | Stock lookup |
| `sync_queue_device_status_idx` | Offline sync worker |

### 5. Permissions and RBAC

`permissions_module_idx`, `role_permissions_role_id_idx`, `employee_roles_employee_id_idx` support `has_permission()` EXISTS subqueries — keep `permissions.code` selective and cached in app where possible.

## Query optimization guidelines

### POS sale lookup

```sql
SELECT * FROM sale_orders
WHERE tenant_id = $1 AND store_id = $2 AND created_at >= $3
ORDER BY created_at DESC
LIMIT 50;
```

Use composite filters matching `(tenant_id, store_id, created_at)` index if present.

### Inventory availability

```sql
SELECT ii.* FROM inventory_items ii
JOIN warehouses w ON w.id = ii.warehouse_id
WHERE ii.tenant_id = $1 AND w.store_id = $2 AND ii.variant_id = $3;
```

Prefer resolving `warehouse_id` once per store session to avoid repeated joins on every scan.

### Catalog search

Use `ILIKE` only with `pg_trgm` (extension in `20250711000001_extensions.sql`) and trigram indexes if search latency grows; until then, prefix search on `sku` / `barcode` via `product_variant_barcodes`.

### Aggregates (daily closing)

Run closing totals in a single SQL transaction; use `daily_closings` + `daily_closing_payments` rather than scanning raw `sale_payments` without date bounds.

## Partitioning (current state)

**No table partitioning** is applied in v1 migrations. High-growth candidates for future monthly partitioning:

| Table | Partition key | Rationale |
|-------|---------------|-----------|
| `audit_logs` | `created_at` | Append-only, time-series |
| `inventory_movements` | `created_at` | Large ledger |
| `loyalty_point_transactions` | `created_at` | Historical points |
| `sale_orders` | `created_at` (per tenant) | Very large tenants |

See [SCALABILITY.md](./SCALABILITY.md) for rollout plan.

## Connection and pooling

- Use **Supavisor** (transaction mode) for serverless Edge Functions.
- Use **session mode** only when you need prepared statements across a long-lived connection.
- Cap pool size per tenant-facing service; prefer read replicas for reporting (future).

## Vacuum and analyze

- `inventory_movements`, `audit_logs`, `sync_queue` — monitor bloat; tune autovacuum scale factor for append-heavy tables.
- After large imports, run `ANALYZE` on `products`, `product_variants`, `customers`.

## Monitoring

Track on Supabase / Postgres:

- P95 latency for `sale_orders` insert + lines + payments (single transaction)
- Sequential scans on `inventory_items` and `product_variants`
- Realtime replication lag when many stores subscribe per region

## Anti-patterns

- Selecting `*` across tables without `tenant_id` filter (RLS hides rows but plans degrade).
- N+1 variant fetches — batch by `id = ANY($1::uuid[])`.
- Storing large blobs in JSONB `metadata` on hot rows — use Storage + `file_attachments`.
