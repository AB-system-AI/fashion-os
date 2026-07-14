# Database Naming Conventions

Standards for FashionOS Postgres schema on Supabase.

## Schemas

| Schema | Purpose |
|--------|---------|
| `public` | Application tables, views exposed to PostgREST |
| `private` | RLS helpers and security-definer functions (not exposed via API) |
| `auth` | Managed by Supabase Auth |
| `storage` | Managed bucket metadata and object policies |

## Tables

- **Plural snake_case**: `sale_orders`, `product_variants`, `employee_store_assignments`.
- **Domain prefix** for clarity when needed: `sale_*`, `purchase_*`, `sync_*`.
- **Line tables** suffix `_lines`: header `purchase_orders` → `purchase_order_lines`.
- **Junction tables**: `{entity1}_{entity2}` e.g. `role_permissions`, `product_taxes`.

## Columns

| Pattern | Example | Notes |
|---------|---------|-------|
| Primary key | `id UUID` | `gen_random_uuid()` default |
| Tenant scope | `tenant_id UUID NOT NULL` | FK → `tenants` |
| Store scope | `store_id UUID` | Nullable when tenant-wide |
| Natural codes | `code TEXT` | Unique per tenant with soft-delete partial index |
| Money | `NUMERIC(12,2)` | Never float |
| Quantities | `NUMERIC(12,3)` | Allows fractional units if needed |
| Status | `{domain}_status` enum | Defined in `20250711000002_enums.sql` |
| Timestamps | `created_at`, `updated_at` | `TIMESTAMPTZ`, UTC |
| Soft delete | `deleted_at TIMESTAMPTZ` | Null = active |
| Audit actors | `created_by`, `updated_by` | FK → `employees` where used |
| External refs | `external_*_id TEXT` | Payment/billing provider ids |
| Flexible config | `metadata JSONB` | Default `'{}'`, not for large payloads |

## Constraints

- `{table}_{column}_fkey` for foreign keys (implicit or named).
- `{table}_{business}_check` for CHECK constraints.
- Partial unique: `{table}_{cols}_active_uidx` with `WHERE deleted_at IS NULL`.

## Indexes

- `{table}_{column(s)}_idx` — btree secondary indexes.
- `{table}_{cols}_uidx` — unique (full or partial).
- Order columns: equality filters first (`tenant_id`, `store_id`), then range (`created_at`).

## Enums

- Type name: `{concept}_status` or `{concept}_type` in snake_case.
- Values: lowercase snake_case (`pending`, `partially_received`).

## Functions and triggers

- **Public business logic**: `public.set_updated_at`, `public.next_sequence_number`, `public.apply_inventory_movement`.
- **RLS**: `private.tenant_matches`, `private.has_permission` — never `public.*` for security helpers.
- Trigger functions: verb_noun — `write_audit_log`, `maintain_category_path`.

## RLS policies

`{table}_tenant_{operation}` or `{table}_{scope}_{operation}`:

- `products_tenant_select`
- `sale_orders_tenant_insert`
- `subscription_plans_select_all`

## Storage

- Bucket id equals bucket name: `product-images`, `expense-receipts`.
- Object keys: `{tenant_id}/{entity_type}/{entity_id}/{filename}`.

## Migrations

- File: `YYYYMMDDHHMMSS_snake_description.sql` under `supabase/migrations/`.
- One logical concern per file when possible (enums, tenant, RLS batch).
- Idempotent seeds: `ON CONFLICT DO NOTHING`.

## Permissions (RBAC codes)

`{module}.{action}` lowercase:

- `sale.create`, `sale.update`, `product.delete`, `cash.open`, `import.execute`

Stored in `permissions.code`; referenced from RLS and Storage policies.
