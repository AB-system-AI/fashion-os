# FashionOS Database Documentation

PostgreSQL schema for **FashionOS**, a multi-tenant fashion retail POS SaaS on **Supabase** (Auth, Postgres, RLS, Realtime, Storage).

## Scope

| Metric | Value |
|--------|------:|
| Public business tables | **70** |
| Tenant-scoped tables | **68** |
| Platform-global tables | **2** (subscription_plans, permissions) |
| SQL migrations | **17** (supabase/migrations/20250711000001 … 20250711000017) |
| Foreign keys | **189** |
| RLS policies | **92** (all public tables: RLS **enabled** and **forced**) |

## Architecture principles

1. **Tenant isolation** — Almost every row carries 	enant_id; RLS compares JWT pp_metadata.tenant_id via private.tenant_matches().
2. **Store-scoped operations** — POS, cash, and some inventory docs also enforce private.has_store_access(store_id).
3. **RBAC** — Mutations check private.has_permission('module.action') where appropriate.
4. **Soft delete** — Core masters use deleted_at with partial unique indexes for active rows.
5. **Auditability** — udit_logs and triggers (write_audit_log) capture sensitive changes.
6. **Offline-first sync** — sync_* tables coordinate device queues, conflicts, and checkpoints.

## Domain map

| Domain | Tables | Doc |
|--------|-------:|-----|
| Tenant & Organization | 7 | [TABLES.md](./TABLES.md#tenant--organization) |
| Identity & Access | 7 | [TABLES.md](./TABLES.md#identity--access) |
| Catalog | 10 | [TABLES.md](./TABLES.md#catalog) |
| Inventory | 6 | [TABLES.md](./TABLES.md#inventory) |
| Purchases | 5 | [TABLES.md](./TABLES.md#purchases) |
| Customers & Loyalty | 6 | [TABLES.md](./TABLES.md#customers--loyalty) |
| Sales & POS | 11 | [TABLES.md](./TABLES.md#sales--pos) |
| Returns & Exchanges | 5 | [TABLES.md](./TABLES.md#returns--exchanges) |
| Financial | 4 | [TABLES.md](./TABLES.md#financial) |
| System & Sync | 9 | [TABLES.md](./TABLES.md#system--sync) |

## Related documents

| File | Purpose |
|------|---------|
| [ERD.md](./ERD.md) | Entity-relationship diagram (Mermaid) by domain |
| [TABLES.md](./TABLES.md) | Table catalog with primary keys |
| [RELATIONSHIPS.md](./RELATIONSHIPS.md) | Foreign-key reference |
| [RLS_STRATEGY.md](./RLS_STRATEGY.md) | Row Level Security and JWT claims |
| [REALTIME.md](./REALTIME.md) | Realtime publication and channel filters |
| [STORAGE.md](./STORAGE.md) | Storage buckets and path conventions |
| [PERFORMANCE.md](./PERFORMANCE.md) | Indexes and query guidance |
| [BACKUP_STRATEGY.md](./BACKUP_STRATEGY.md) | Backup, PITR, and restore |
| [NAMING_CONVENTIONS.md](./NAMING_CONVENTIONS.md) | Schema naming standards |
| [SCALABILITY.md](./SCALABILITY.md) | Growth and scaling playbook |

## Source of truth

Schema changes are **migration-only**. Apply with Supabase CLI:

`ash
supabase db push
# or
supabase migration up
`

Never edit production DDL by hand; add a new timestamped file under supabase/migrations/.
