-- Phase 13: Enterprise Sales Orders, Quotations & Order Management (OMS)

CREATE TABLE IF NOT EXISTS public.quotations (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id         UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  quotation_number  TEXT NOT NULL,
  customer_id       UUID,
  status            TEXT NOT NULL DEFAULT 'draft',
  valid_until       TIMESTAMPTZ,
  subtotal          NUMERIC(18, 4) NOT NULL DEFAULT 0,
  discount_total    NUMERIC(18, 4) NOT NULL DEFAULT 0,
  tax_total         NUMERIC(18, 4) NOT NULL DEFAULT 0,
  grand_total       NUMERIC(18, 4) NOT NULL DEFAULT 0,
  notes             TEXT,
  created_by        UUID,
  version           INTEGER NOT NULL DEFAULT 1,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at        TIMESTAMPTZ
);

CREATE UNIQUE INDEX IF NOT EXISTS quotations_tenant_number_uidx ON public.quotations (tenant_id, quotation_number) WHERE deleted_at IS NULL;

CREATE TABLE IF NOT EXISTS public.quotation_lines (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id         UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  quotation_id      UUID NOT NULL REFERENCES public.quotations (id) ON DELETE CASCADE,
  line_number       INTEGER NOT NULL DEFAULT 1,
  product_id        UUID NOT NULL,
  variant_id        UUID,
  quantity          NUMERIC(14, 4) NOT NULL DEFAULT 0,
  unit_price        NUMERIC(18, 4) NOT NULL DEFAULT 0,
  discount_percent  NUMERIC(6, 2) NOT NULL DEFAULT 0,
  tax_rate          NUMERIC(6, 2) NOT NULL DEFAULT 0,
  version           INTEGER NOT NULL DEFAULT 1,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at        TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.sales_orders (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id           UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  order_number        TEXT NOT NULL,
  customer_id         UUID,
  quotation_id        UUID REFERENCES public.quotations (id) ON DELETE SET NULL,
  status              TEXT NOT NULL DEFAULT 'draft',
  warehouse_id        UUID,
  subtotal            NUMERIC(18, 4) NOT NULL DEFAULT 0,
  discount_total      NUMERIC(18, 4) NOT NULL DEFAULT 0,
  tax_total           NUMERIC(18, 4) NOT NULL DEFAULT 0,
  grand_total         NUMERIC(18, 4) NOT NULL DEFAULT 0,
  planning_method     TEXT NOT NULL DEFAULT 'makeToStock',
  production_order_id UUID,
  notes               TEXT,
  created_by          UUID,
  version             INTEGER NOT NULL DEFAULT 1,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at          TIMESTAMPTZ
);

CREATE UNIQUE INDEX IF NOT EXISTS sales_orders_tenant_number_uidx ON public.sales_orders (tenant_id, order_number) WHERE deleted_at IS NULL;

CREATE TABLE IF NOT EXISTS public.sales_order_lines (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id     UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  order_id      UUID NOT NULL REFERENCES public.sales_orders (id) ON DELETE CASCADE,
  line_number   INTEGER NOT NULL DEFAULT 1,
  product_id    UUID NOT NULL,
  variant_id    UUID,
  quantity      NUMERIC(14, 4) NOT NULL DEFAULT 0,
  unit_price    NUMERIC(18, 4) NOT NULL DEFAULT 0,
  shipped_qty   NUMERIC(14, 4) NOT NULL DEFAULT 0,
  returned_qty  NUMERIC(14, 4) NOT NULL DEFAULT 0,
  version       INTEGER NOT NULL DEFAULT 1,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at    TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.sales_reservations (
  id                    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id             UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  order_id              UUID NOT NULL REFERENCES public.sales_orders (id) ON DELETE CASCADE,
  order_line_id         UUID NOT NULL,
  product_id            UUID NOT NULL,
  warehouse_id          UUID,
  quantity              NUMERIC(14, 4) NOT NULL DEFAULT 0,
  stock_reservation_id  UUID,
  released_at           TIMESTAMPTZ,
  version               INTEGER NOT NULL DEFAULT 1,
  created_at            TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at            TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at            TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.back_orders (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  order_id        UUID NOT NULL REFERENCES public.sales_orders (id) ON DELETE CASCADE,
  order_line_id   UUID NOT NULL,
  product_id      UUID NOT NULL,
  quantity        NUMERIC(14, 4) NOT NULL DEFAULT 0,
  fulfilled_qty   NUMERIC(14, 4) NOT NULL DEFAULT 0,
  status          TEXT NOT NULL DEFAULT 'open',
  version         INTEGER NOT NULL DEFAULT 1,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at      TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.shipments (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id         UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  shipment_number   TEXT NOT NULL,
  order_id          UUID NOT NULL REFERENCES public.sales_orders (id) ON DELETE CASCADE,
  status            TEXT NOT NULL DEFAULT 'pending',
  warehouse_id      UUID,
  carrier           TEXT,
  tracking_number   TEXT,
  shipped_at        TIMESTAMPTZ,
  delivered_at      TIMESTAMPTZ,
  version           INTEGER NOT NULL DEFAULT 1,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at        TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.shipment_lines (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  shipment_id     UUID NOT NULL REFERENCES public.shipments (id) ON DELETE CASCADE,
  order_line_id   UUID NOT NULL,
  product_id      UUID NOT NULL,
  quantity        NUMERIC(14, 4) NOT NULL DEFAULT 0,
  picked_qty      NUMERIC(14, 4) NOT NULL DEFAULT 0,
  version         INTEGER NOT NULL DEFAULT 1,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at      TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.deliveries (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id         UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  delivery_number   TEXT NOT NULL,
  shipment_id       UUID NOT NULL REFERENCES public.shipments (id) ON DELETE CASCADE,
  order_id          UUID NOT NULL REFERENCES public.sales_orders (id) ON DELETE CASCADE,
  status            TEXT NOT NULL DEFAULT 'pending',
  estimated_at      TIMESTAMPTZ,
  delivered_at      TIMESTAMPTZ,
  recipient_name    TEXT,
  address           TEXT,
  version           INTEGER NOT NULL DEFAULT 1,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at        TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.delivery_lines (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id         UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  delivery_id       UUID NOT NULL REFERENCES public.deliveries (id) ON DELETE CASCADE,
  shipment_line_id  UUID NOT NULL,
  product_id        UUID NOT NULL,
  quantity          NUMERIC(14, 4) NOT NULL DEFAULT 0,
  version           INTEGER NOT NULL DEFAULT 1,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at        TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.sales_return_requests (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  return_number   TEXT,
  order_id        UUID NOT NULL REFERENCES public.sales_orders (id) ON DELETE CASCADE,
  order_line_id   UUID NOT NULL,
  quantity        NUMERIC(14, 4) NOT NULL DEFAULT 0,
  status          TEXT NOT NULL DEFAULT 'draft',
  reason          TEXT,
  refund_amount   NUMERIC(18, 4) NOT NULL DEFAULT 0,
  version         INTEGER NOT NULL DEFAULT 1,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at      TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.exchange_requests (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id         UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  exchange_number   TEXT,
  order_id          UUID NOT NULL REFERENCES public.sales_orders (id) ON DELETE CASCADE,
  return_line_id    UUID,
  new_product_id    UUID,
  new_quantity      NUMERIC(14, 4) NOT NULL DEFAULT 1,
  status            TEXT NOT NULL DEFAULT 'draft',
  price_difference  NUMERIC(18, 4) NOT NULL DEFAULT 0,
  version           INTEGER NOT NULL DEFAULT 1,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at        TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.customer_order_timeline (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  customer_id     UUID NOT NULL,
  event_type      TEXT NOT NULL,
  title           TEXT NOT NULL,
  description     TEXT,
  reference_type  TEXT,
  reference_id    UUID,
  employee_id     UUID,
  version         INTEGER NOT NULL DEFAULT 1,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at      TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS customer_order_timeline_customer_idx ON public.customer_order_timeline (tenant_id, customer_id) WHERE deleted_at IS NULL;

CREATE TABLE IF NOT EXISTS public.sales_settings (
  id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id               UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  default_warehouse_id    UUID,
  approval_threshold      NUMERIC(18, 4) NOT NULL DEFAULT 0,
  quotation_validity_days INTEGER NOT NULL DEFAULT 30,
  auto_reserve_on_approve BOOLEAN NOT NULL DEFAULT true,
  version                 INTEGER NOT NULL DEFAULT 1,
  created_at              TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at              TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at              TIMESTAMPTZ
);

CREATE UNIQUE INDEX IF NOT EXISTS sales_settings_tenant_uidx ON public.sales_settings (tenant_id) WHERE deleted_at IS NULL;

DO $$
DECLARE t text;
BEGIN
  FOREACH t IN ARRAY ARRAY[
    'quotations', 'quotation_lines', 'sales_orders', 'sales_order_lines', 'sales_reservations',
    'back_orders', 'shipments', 'shipment_lines', 'deliveries', 'delivery_lines',
    'sales_return_requests', 'exchange_requests', 'customer_order_timeline', 'sales_settings'
  ]
  LOOP
    EXECUTE format('ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY', t);
  END LOOP;
END $$;

DO $$
DECLARE t text;
BEGIN
  FOREACH t IN ARRAY ARRAY[
    'quotations', 'quotation_lines', 'sales_orders', 'sales_order_lines', 'sales_reservations',
    'back_orders', 'shipments', 'shipment_lines', 'deliveries', 'delivery_lines',
    'sales_return_requests', 'exchange_requests', 'customer_order_timeline', 'sales_settings'
  ]
  LOOP
    EXECUTE format('DROP POLICY IF EXISTS %I_tenant_select ON public.%I', t, t);
    EXECUTE format('DROP POLICY IF EXISTS %I_tenant_insert ON public.%I', t, t);
    EXECUTE format('DROP POLICY IF EXISTS %I_tenant_update ON public.%I', t, t);
    EXECUTE format('DROP POLICY IF EXISTS %I_tenant_delete ON public.%I', t, t);
    EXECUTE format('CREATE POLICY %I_tenant_select ON public.%I FOR SELECT USING (tenant_id = (auth.jwt() ->> ''tenant_id'')::uuid)', t, t);
    EXECUTE format('CREATE POLICY %I_tenant_insert ON public.%I FOR INSERT WITH CHECK (tenant_id = (auth.jwt() ->> ''tenant_id'')::uuid)', t, t);
    EXECUTE format('CREATE POLICY %I_tenant_update ON public.%I FOR UPDATE USING (tenant_id = (auth.jwt() ->> ''tenant_id'')::uuid) WITH CHECK (tenant_id = (auth.jwt() ->> ''tenant_id'')::uuid)', t, t);
    EXECUTE format('CREATE POLICY %I_tenant_delete ON public.%I FOR DELETE USING (tenant_id = (auth.jwt() ->> ''tenant_id'')::uuid)', t, t);
  END LOOP;
END $$;
