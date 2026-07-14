# Scalability

Growth path for FashionOS from single-region SaaS to high-volume multi-store retail.

## Current baseline (v1 migrations)

- Single Postgres primary (Supabase managed).
- Tenant isolation via RLS (not database-per-tenant).
- ~70 public tables, ~180 indexes, 9 realtime tables.
- No partitioning; connection pooling via Supabase pooler.

## Scaling dimensions

| Dimension | Symptom | First lever | Long-term |
|-----------|---------|-------------|-----------|
| Tenants | CPU on auth/RLS | Index `tenant_id`; cache permissions | Read replicas for reporting |
| Stores per tenant | Realtime fan-out | Narrow filters; regional edge | Dedicated publication per region |
| SKUs | Catalog query slow | Trigram / search service | Read replica + CDN for images |
| Transactions | Insert latency on sales | Batch lines; partition `sale_orders` | Citus / sharding by `tenant_id` (enterprise) |
| Inventory ledger | Table bloat | Archive movements | Monthly partitions |
| Offline sync | `sync_queue` depth | Per-device workers | Queue sharding by `tenant_id` |

## Partitioning roadmap

### Phase 1 — Archive tables (low risk)

1. `audit_logs` — RANGE (`created_at`) monthly.
2. `inventory_movements` — RANGE (`created_at`) monthly.
3. Detach partitions older than retention to cold storage.

### Phase 2 — Transactional (tenant-aware)

For tenants exceeding **50M** sale rows:

- `sale_orders` PARTITION BY RANGE (`created_at`) with sub-partition LIST (`tenant_id`) if using PG16+ or manual tenant tables.

Migration approach:

```sql
-- Create parent + monthly child, attach trigger for routing, backfill, swap names.
```

Always update RLS policies on parent; children inherit.

### Phase 3 — Global tenants

- Move largest tenant to dedicated Supabase project (logical isolation).
- Central control plane still in main SaaS; use `tenant.metadata.dedicated_project_url`.

## Read replicas

Use for:

- Backoffice analytics and exports
- Nightly closing reconciliation
- BI tools (read-only role, no service_role)

**Do not** route POS writes to replicas. POS stays on primary with short transactions.

## Connection pooling

| Client | Mode | Guidance |
|--------|------|----------|
| Flutter POS (long lived) | Session pooler | Low connection count per device |
| Edge Functions | Transaction pooler | Open connection per request only |
| Batch ETL | Direct (bypass pooler) | `SET statement_timeout` |

Rule of thumb: `max_connections` on primary reserved; auto-scale pooler before adding DB size.

## Caching layer (application)

- Cache `permissions` and role maps per employee session (invalidate on `employee_roles` change via Realtime).
- Cache store list and warehouse mapping per tenant (5–15 min TTL).
- Product lookup: local SQLite on POS with `sync_checkpoints` — database is source of truth, not cache.

## Realtime scaling

- Limit subscribers per channel; shard `store:{id}:sales` per register only if needed.
- Consider **Broadcast** from Edge Function for aggregated stock if warehouse-level Postgres changes overwhelm clients.

## Storage scaling

- Images on CDN; original in `product-images`.
- Lifecycle rules: delete orphaned imports after 30 days.
- Large exports → `imports` bucket streaming upload, process via worker.

## Multi-region (future)

1. Primary region per geography (EU, US, GCC).
2. Tenant `default_timezone` / `metadata.region` routes signup.
3. Auth stays regional; no cross-region FKs.
4. Replicate **subscription_plans** and **permissions** globally (read-only).

## Observability at scale

- Per-tenant query tags (`SET app.tenant_id` custom GUC in server jobs).
- Alert on `sync_queue` depth p95, `sale_orders` insert latency, replication lag.
- Regular `pg_stat_user_tables` review for seq scans.

## When to shard

Consider dedicated database or Citus when **any** of:

- Single tenant > 30% of primary storage
- Sustained write rate > 5k TPS on inventory ledger
- PITR window insufficient for backup size

Until then, **vertical scale** (larger Supabase compute) + partitioning + replicas is simpler and RLS-friendly.
