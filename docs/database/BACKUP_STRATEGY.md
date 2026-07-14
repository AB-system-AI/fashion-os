# Backup Strategy

FashionOS on Supabase inherits managed Postgres backups. Treat **migrations + PITR + object storage** as one disaster-recovery story.

## Recovery objectives

| Tier | RTO | RPO | Scope |
|------|-----|-----|-------|
| Production tenant data | < 4 hours | < 15 minutes | Postgres + Storage |
| Staging | < 24 hours | < 24 hours | Full restore acceptable |
| Development | best effort | none | Rebuild from migrations |

Tune RTO/RPO with your Supabase plan (PITR window length).

## Postgres backups

### Point-in-Time Recovery (PITR)

- Enable on **Pro** (or higher) production projects.
- WAL archiving allows restore to a timestamp before accidental DDL or bad bulk update.
- Document the **PITR window** (e.g. 7 days) in your runbook.

### Daily logical backups

- Schedule **pg_dump** (schema + data) nightly for long-term retention outside Supabase.
- Store encrypted dumps in object storage (separate region/account).
- Retain: 7 daily, 4 weekly, 12 monthly (adjust for compliance).

```bash
# Example: schema-only for CI drift detection
pg_dump "$DATABASE_URL" --schema-only --schema=public --schema=private -f fashionos_schema.sql

# Example: single-tenant export (custom script with tenant_id filters)
pg_dump "$DATABASE_URL" --data-only --table=public.sale_orders --where="tenant_id='...'"
```

## Storage backups

Buckets (`product-images`, `receipts`, etc.) are **not** in SQL dumps.

- Enable **S3-compatible replication** or periodic sync from Supabase Storage to a DR bucket.
- Include storage restore in tenant export/import procedures.

## What to backup together

| Asset | Method |
|-------|--------|
| Schema | Git `supabase/migrations/` (source of truth) + nightly `pg_dump --schema-only` |
| Tenant business data | PITR + logical dumps |
| Auth users | Supabase Auth export / Admin API (metadata includes `tenant_id`) |
| Secrets | Vault / CI secrets manager — never in dumps |
| Edge Functions | Git repository |

## Restore procedures

### 1. Full project restore (catastrophic)

1. Create new Supabase project or use dashboard restore to timestamp.
2. Verify extensions: `pgcrypto`, `uuid-ossp`, `pg_trgm`, etc. (`20250711000001_extensions.sql`).
3. If restoring from git only: `supabase db push` on empty database.
4. Replay storage sync.
5. Redeploy Edge Functions; rotate API keys if compromise suspected.

### 2. Point-in-time restore (oops delete)

1. Identify UTC timestamp **before** incident.
2. Supabase Dashboard → Database → Backups → Restore to new project or clone.
3. Validate row counts per tenant; swap connection strings during maintenance window.
4. Reconcile `sync_queue` / offline devices (force full resync).

### 3. Single-tenant export/import

For GDPR or tenant offboarding:

1. Export filtered data for `tenant_id` (tables in dependency order — see [RELATIONSHIPS.md](./RELATIONSHIPS.md)).
2. Export storage prefix `{tenant_id}/` from all buckets.
3. Import into dedicated project or archive cold storage.

### 4. Migration rollback

- Prefer **forward-fix** migrations over reversing DDL in production.
- Keep rollback SQL in PR description for manual use only.

## Testing backups

Quarterly:

- [ ] Restore staging from latest logical dump
- [ ] Spot-check `sale_orders` / `inventory_items` counts
- [ ] Open signed URL from restored storage object
- [ ] Measure wall-clock time to usable staging

## Security

- Encrypt dumps at rest (AES-256).
- Restrict dump access to break-glass roles.
- Audit access to `service_role` during restore operations.

## Compliance notes

- Receipts and customer PII may require regional retention — align `receipts` bucket lifecycle with legal hold flags in `file_attachments.metadata`.
