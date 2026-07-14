# Organizations

Hierarchy (all syncable, tenant-scoped):

- `Company` → `Branch` → `Store` → `WarehouseAdmin`
- `Department` → `Team`
- `BusinessUnit` → `CostCenterAdmin`

Supabase tables: `admin_companies`, `admin_branches`, `admin_stores`, `admin_warehouses`, `admin_departments`, `admin_teams`, `admin_business_units`, `admin_cost_centers`.

Org units reference `tenants(id)`; may extend to shared org tables in future migrations.
