# Storage

Migration `20250711000016_storage.sql` defines **six buckets** and RLS policies on `storage.objects`.

## Path convention

All tenant-scoped objects use:

```
{tenant_id}/{entity_type}/{entity_id}/{filename}
```

| Segment | Description |
|---------|-------------|
| `tenant_id` | UUID string — must match `private.get_tenant_id()` on upload |
| `entity_type` | Logical folder: `products`, `stores`, `expenses`, `imports`, etc. |
| `entity_id` | UUID of the owning row |
| `filename` | Unique file name (include version or ULID to avoid collisions) |

**Employee avatars** use `{auth.uid()}/avatar.{ext}` (user id as first folder segment, not tenant).

`file_attachments.storage_path` and `product_images.url` should store the object key relative to bucket root.

## Buckets

| Bucket | Public | Max size | MIME types | Purpose |
|--------|:------:|---------:|------------|---------|
| `product-images` | yes | 5 MB | jpeg, png, webp, gif | Catalog imagery |
| `receipts` | no | 10 MB | pdf, png, jpeg, html | Sale receipt artifacts |
| `expense-receipts` | no | 10 MB | pdf, png, jpeg | Expense documentation |
| `store-assets` | yes | 2 MB | jpeg, png, webp, svg | Logos, signage, store branding |
| `employee-avatars` | no | 2 MB | jpeg, png, webp | Profile photos |
| `imports` | no | 50 MB | csv, xlsx, json | Bulk catalog/customer imports |

## Example paths

```
product-images/550e8400-e29b-41d4-a716-446655440000/products/8f14e45f-ceea-467a-9c0d-7d0b5c8e9f01/front.webp
receipts/550e8400-e29b-41d4-a716-446655440000/sales/a1b2c3d4-e5f6-7890-abcd-ef1234567890/receipt.pdf
expense-receipts/550e8400-e29b-41d4-a716-446655440000/expenses/cafe-receipt.jpg
store-assets/550e8400-e29b-41d4-a716-446655440000/stores/store-001/logo.svg
employee-avatars/6ba7b810-9dad-11d1-80b4-00c04fd430c8/avatar.png
imports/550e8400-e29b-41d4-a716-446655440000/catalog/import-20250711.csv
```

## Policy summary

| Bucket | SELECT | INSERT/UPDATE/DELETE |
|--------|--------|----------------------|
| `product-images` | Any authenticated | Tenant folder + `product.create` / `product.delete` |
| `receipts` | Tenant folder | Insert with `sale.create` |
| `expense-receipts` | Tenant folder | ALL with `expense.create` |
| `store-assets` | Public read | Tenant folder + `store.update` |
| `employee-avatars` | Own `auth.uid()` folder | Own folder only |
| `imports` | Tenant folder + `import.execute` | Same |

Policies use `(storage.foldername(name))[1]` for the first path segment.

## Client upload flow

1. Ensure user JWT includes `tenant_id` and required permission.
2. Build key: `$tenantId/products/$productId/${uuid}.webp`.
3. `supabase.storage.from('product-images').upload(path, bytes)`.
4. Persist path in `product_images` or `file_attachments`.

## CDN and public buckets

Public buckets (`product-images`, `store-assets`) are suitable for CDN caching. Use versioned filenames when replacing images to avoid stale cache.

## Lifecycle

- Soft-delete products should retain images until purge job runs.
- Define retention for `receipts` and `imports` per compliance (see [BACKUP_STRATEGY.md](./BACKUP_STRATEGY.md)).
