# Manufacturing Sync

## Processors (registered at bootstrap)

| Entity type | Remote table |
|-------------|--------------|
| `bill_of_material` | `bills_of_materials` |
| `bom_version` | `bom_versions` |
| `bom_line` | `bom_lines` |
| `production_order` | `production_orders` |
| `work_order` | `work_orders` |
| `material_issue` | `material_issues` |
| `production_output` | `production_outputs` |
| `quality_inspection` | `quality_inspections` |
| `capacity_plan` | `capacity_plans` |

## Remote datasource

`ManufacturingRemoteDataSource` — push by operation, pull delta by `updated_at`.

## Conflict resolution

Standard FashionOS LWW via `version` + `updated_at` on syncable records.

## Migration

`supabase/migrations/20250712000009_manufacturing_enterprise.sql`

## Tenant isolation

All tables include `tenant_id`; RLS policies on primary manufacturing tables.
