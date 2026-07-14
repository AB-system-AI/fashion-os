-- Enterprise performance indexes (additive only — skips indexes already in base migrations)

-- Product catalog: sync watermark and SKU family lookup
CREATE INDEX IF NOT EXISTS products_tenant_updated_active_idx
  ON public.products (tenant_id, updated_at DESC)
  WHERE deleted_at IS NULL;

CREATE INDEX IF NOT EXISTS products_tenant_base_sku_active_idx
  ON public.products (tenant_id, base_sku)
  WHERE deleted_at IS NULL AND base_sku IS NOT NULL;

-- Sale orders: high-volume list and order number search (1M+ invoices)
CREATE INDEX IF NOT EXISTS sale_orders_tenant_created_idx
  ON public.sale_orders (tenant_id, created_at DESC);

CREATE INDEX IF NOT EXISTS sale_orders_tenant_order_number_idx
  ON public.sale_orders (tenant_id, order_number);

CREATE INDEX IF NOT EXISTS sale_orders_store_status_created_idx
  ON public.sale_orders (store_id, status, created_at DESC);

-- Customers: POS phone lookup
CREATE INDEX IF NOT EXISTS customers_tenant_phone_active_idx
  ON public.customers (tenant_id, phone)
  WHERE deleted_at IS NULL AND phone IS NOT NULL;

CREATE INDEX IF NOT EXISTS customers_tenant_first_name_active_idx
  ON public.customers (tenant_id, first_name)
  WHERE deleted_at IS NULL;

-- Inventory: warehouse + variant hot path
CREATE INDEX IF NOT EXISTS inventory_items_warehouse_variant_qty_idx
  ON public.inventory_items (warehouse_id, variant_id, quantity_on_hand);

-- Audit: tenant timeline queries
CREATE INDEX IF NOT EXISTS audit_logs_tenant_created_idx
  ON public.audit_logs (tenant_id, created_at DESC);

-- Auth device sessions (Phase 3)
CREATE INDEX IF NOT EXISTS auth_device_sessions_employee_active_idx
  ON public.auth_device_sessions (employee_id, status, last_active_at DESC)
  WHERE status = 'active';

-- Sync queue: tenant pending operations
CREATE INDEX IF NOT EXISTS sync_queue_tenant_pending_created_idx
  ON public.sync_queue (tenant_id, created_at)
  WHERE status IN ('pending', 'failed');
