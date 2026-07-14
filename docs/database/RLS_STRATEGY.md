# Row Level Security (RLS) Strategy

FashionOS uses **Postgres RLS** on every `public` table. Migration `20250711000015_rls_policies.sql` enables and **forces** RLS for all tables in `public`, so even table owners cannot bypass policies.

## Threat model

| Risk | Mitigation |
|------|------------|
| Cross-tenant data leak | `tenant_id` on rows + `private.tenant_matches()` |
| Store hopping (employee A opens store B) | `private.has_store_access(store_id)` on POS/inventory docs |
| Privilege escalation | `private.has_permission(code)` on INSERT/UPDATE/DELETE |
| Service automation | `service_role` JWT bypasses tenant checks via `private.is_service_role()` |

## JWT claims (Supabase Auth)

Set on the user via **app_metadata** (server-side only — never client-writable):

| Claim path | Type | Purpose |
|------------|------|---------|
| `app_metadata.tenant_id` | UUID string | Active tenant context for RLS |
| `app_metadata.employee_id` | UUID string | Links session to `employees` for store access & permissions |
| `role` (top-level JWT) | string | `service_role` for backend jobs |

Example hook payload after employee login:

```json
{
  "app_metadata": {
    "tenant_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
    "employee_id": "f0987654-3210-fedc-ba09-876543210fed"
  }
}
```

**Profiles** use `auth.uid()` directly (`profiles.id = auth.uid()`), not `tenant_id` on the JWT.

## Helper functions (`private` schema)

Defined in `20250711000014_rls_helpers.sql`. All are `STABLE`, `SECURITY DEFINER`, `search_path = public`, and executable only by `authenticated` and `service_role`.

| Function | Returns | Logic |
|----------|---------|--------|
| `private.get_tenant_id()` | UUID | `auth.jwt()->'app_metadata'->>'tenant_id'` |
| `private.get_employee_id()` | UUID | `auth.jwt()->'app_metadata'->>'employee_id'` |
| `private.is_service_role()` | boolean | JWT `role = service_role` |
| `private.tenant_matches(p_tenant_id)` | boolean | Service role OR `p_tenant_id = get_tenant_id()` |
| `private.has_store_access(p_store_id)` | boolean | Service role OR active row in `employee_store_assignments` |
| `private.has_permission(p_permission_code)` | boolean | Service role OR permission via `employee_roles` → `role_permissions` → `permissions` |

Public execute is revoked from `PUBLIC`; grants are limited to `authenticated` and `service_role`.

## Policy patterns

### 1. Platform read-only catalogs

| Table | Policy | Rule |
|-------|--------|------|
| `subscription_plans` | `subscription_plans_select_all` | `is_active = true` for `authenticated` |
| `permissions` | `permissions_select_all` | `USING (true)` for `authenticated` |

### 2. Self-service profile

| Operation | Policy | Rule |
|-----------|--------|------|
| SELECT/UPDATE | `profiles_select_own`, `profiles_update_own` | `id = auth.uid()` |

### 3. Tenant member read (default)

**66 SELECT policies** named `{table}_tenant_select` on tenant-scoped tables:

```sql
USING (private.tenant_matches(tenant_id))
```

**Exceptions** (join or extra scope):

- `role_permissions` — EXISTS on `roles` where `tenant_matches(r.tenant_id)`
- `stock_adjustments`, `purchase_orders` — also `has_store_access(store_id)`
- Line tables — tenant on header or direct `tenant_id` column

### 4. Tenant visibility for `tenants`

`tenants_select_member` — `USING (private.tenant_matches(id))`

### 5. Mutations (restricted write)

Writes are **not** open by default. Explicit INSERT/UPDATE/DELETE policies:

| Table | INSERT | UPDATE | DELETE |
|-------|:------:|:------:|:------:|
| `stores` | ✓ `store.create` | ✓ `store.update` | |
| `products` | ✓ `product.create` | ✓ `product.update` | ✓ `product.delete` |
| `product_variants` | ✓ `product.create` | ✓ `product.update` | |
| `customers` | ✓ `customer.create` | ✓ `customer.update` | ✓ `customer.delete` |
| `sale_orders` | ✓ `sale.create` + store access | ✓ `sale.update` + store access | |
| `sale_order_lines` | ✓ tenant match | | |
| `sale_payments` | ✓ `sale.create` | | |
| `cash_sessions` | ✓ `cash.open` + store access | ✓ `cash.close` + store access | |
| `inventory_movements` | ✓ `inventory.adjust` | | |
| `sync_queue` | ✓ tenant (device sync) | ✓ tenant | |
| `notifications` | | ✓ mark read (tenant) | |

Typical INSERT pattern:

```sql
WITH CHECK (
  private.tenant_matches(tenant_id)
  AND private.has_store_access(store_id)   -- when applicable
  AND private.has_permission('sale.create')
);
```

### 6. Storage objects

Bucket policies on `storage.objects` use the same helpers plus path prefix checks — see [STORAGE.md](./STORAGE.md).

## Service role usage

Use **service_role** only on trusted servers (Edge Functions, workers) for:

- Tenant onboarding and JWT metadata updates
- Billing webhooks writing `tenant_subscriptions`
- Bulk imports (`imports` bucket + `import.execute`)
- Conflict resolution and admin repair jobs

Never embed service_role in mobile or web clients.

## Testing RLS

```sql
-- As authenticated test user (set request.jwt.claims in SQL editor or use supabase test helpers)
SET request.jwt.claims TO '{"sub":"...", "role":"authenticated", "app_metadata":{"tenant_id":"...", "employee_id":"..."}}';
SELECT * FROM public.sale_orders LIMIT 5;
```

Verify:

1. Wrong `tenant_id` in JWT returns zero rows.
2. Employee without store assignment cannot insert `sale_orders` for that store.
3. Missing permission fails INSERT with RLS violation.

## Operational checklist

- [ ] Auth hook sets `tenant_id` and `employee_id` on every employee login
- [ ] Switching tenant requires new JWT (clear client cache)
- [ ] New tables: add `tenant_id`, index it, add `_tenant_select` + mutation policies
- [ ] Force RLS remains enabled after migrations
