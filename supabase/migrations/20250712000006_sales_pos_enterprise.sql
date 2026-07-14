-- Phase 8: Enterprise POS extensions (sales, receipts, layaway, promotions)

ALTER TABLE public.sale_orders
  ADD COLUMN IF NOT EXISTS version INTEGER NOT NULL DEFAULT 1,
  ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ;

ALTER TABLE public.sale_payments
  ADD COLUMN IF NOT EXISTS version INTEGER NOT NULL DEFAULT 1,
  ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  ADD COLUMN IF NOT EXISTS method_kind TEXT;

ALTER TABLE public.cash_sessions
  ADD COLUMN IF NOT EXISTS version INTEGER NOT NULL DEFAULT 1,
  ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ;

CREATE TABLE IF NOT EXISTS public.receipt_templates (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  store_id        UUID REFERENCES public.stores (id) ON DELETE CASCADE,
  name            TEXT NOT NULL,
  template_type   TEXT NOT NULL DEFAULT 'thermal',
  body_html       TEXT,
  header_text     TEXT,
  footer_text     TEXT,
  show_qr_code    BOOLEAN NOT NULL DEFAULT true,
  show_barcode    BOOLEAN NOT NULL DEFAULT false,
  is_default      BOOLEAN NOT NULL DEFAULT false,
  version         INTEGER NOT NULL DEFAULT 1,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at      TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS receipt_templates_tenant_idx ON public.receipt_templates (tenant_id);

CREATE TABLE IF NOT EXISTS public.receipt_history (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  store_id        UUID REFERENCES public.stores (id) ON DELETE SET NULL,
  sale_order_id   UUID NOT NULL REFERENCES public.sale_orders (id) ON DELETE RESTRICT,
  receipt_number  TEXT NOT NULL,
  format          TEXT NOT NULL DEFAULT 'thermal',
  content         TEXT,
  qr_code         TEXT,
  barcode         TEXT,
  printed_at      TIMESTAMPTZ,
  reprint_count   INTEGER NOT NULL DEFAULT 0,
  version         INTEGER NOT NULL DEFAULT 1,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at      TIMESTAMPTZ
);

CREATE UNIQUE INDEX IF NOT EXISTS receipt_history_tenant_number_uidx
  ON public.receipt_history (tenant_id, receipt_number);

CREATE INDEX IF NOT EXISTS receipt_history_sale_order_idx ON public.receipt_history (sale_order_id);

CREATE TABLE IF NOT EXISTS public.gift_receipts (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  sale_order_id   UUID NOT NULL REFERENCES public.sale_orders (id) ON DELETE RESTRICT,
  gift_number     TEXT NOT NULL,
  recipient_name  TEXT,
  message         TEXT,
  hide_prices     BOOLEAN NOT NULL DEFAULT true,
  version         INTEGER NOT NULL DEFAULT 1,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at      TIMESTAMPTZ
);

CREATE UNIQUE INDEX IF NOT EXISTS gift_receipts_tenant_number_uidx
  ON public.gift_receipts (tenant_id, gift_number);

CREATE TABLE IF NOT EXISTS public.layaway_orders (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  store_id        UUID NOT NULL REFERENCES public.stores (id) ON DELETE RESTRICT,
  layaway_number  TEXT NOT NULL,
  sale_order_id   UUID NOT NULL REFERENCES public.sale_orders (id) ON DELETE RESTRICT,
  customer_id     UUID NOT NULL REFERENCES public.customers (id) ON DELETE RESTRICT,
  total_amount    NUMERIC(14, 4) NOT NULL,
  deposit_amount  NUMERIC(14, 4) NOT NULL DEFAULT 0,
  status          TEXT NOT NULL DEFAULT 'active',
  pickup_due_date TIMESTAMPTZ,
  completed_at    TIMESTAMPTZ,
  version         INTEGER NOT NULL DEFAULT 1,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at      TIMESTAMPTZ
);

CREATE UNIQUE INDEX IF NOT EXISTS layaway_orders_tenant_number_uidx
  ON public.layaway_orders (tenant_id, layaway_number);

CREATE TABLE IF NOT EXISTS public.layaway_payments (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  layaway_id      UUID NOT NULL REFERENCES public.layaway_orders (id) ON DELETE CASCADE,
  payment_method_id UUID REFERENCES public.payment_methods (id) ON DELETE SET NULL,
  amount          NUMERIC(14, 4) NOT NULL,
  processed_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  version         INTEGER NOT NULL DEFAULT 1,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS layaway_payments_layaway_idx ON public.layaway_payments (layaway_id);

CREATE TABLE IF NOT EXISTS public.promotion_logs (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  sale_order_id   UUID REFERENCES public.sale_orders (id) ON DELETE SET NULL,
  promotion_id    UUID,
  line_id         UUID,
  promotion_name  TEXT,
  discount_amount NUMERIC(14, 4) NOT NULL DEFAULT 0,
  applied_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  version         INTEGER NOT NULL DEFAULT 1,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS promotion_logs_sale_order_idx ON public.promotion_logs (sale_order_id);
CREATE INDEX IF NOT EXISTS promotion_logs_tenant_idx ON public.promotion_logs (tenant_id);

-- Sync-friendly indexes
CREATE INDEX IF NOT EXISTS sale_orders_updated_at_idx ON public.sale_orders (updated_at DESC);
CREATE INDEX IF NOT EXISTS cash_sessions_updated_at_idx ON public.cash_sessions (updated_at DESC);
CREATE INDEX IF NOT EXISTS receipt_history_updated_at_idx ON public.receipt_history (updated_at DESC);
CREATE INDEX IF NOT EXISTS layaway_orders_updated_at_idx ON public.layaway_orders (updated_at DESC);

-- RLS (tenant scoped)
ALTER TABLE public.receipt_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.receipt_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.gift_receipts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.layaway_orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.layaway_payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.promotion_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY receipt_templates_tenant_select ON public.receipt_templates
  FOR SELECT USING (tenant_id = (auth.jwt() ->> 'tenant_id')::uuid);

CREATE POLICY receipt_history_tenant_select ON public.receipt_history
  FOR SELECT USING (tenant_id = (auth.jwt() ->> 'tenant_id')::uuid);

CREATE POLICY gift_receipts_tenant_select ON public.gift_receipts
  FOR SELECT USING (tenant_id = (auth.jwt() ->> 'tenant_id')::uuid);

CREATE POLICY layaway_orders_tenant_select ON public.layaway_orders
  FOR SELECT USING (tenant_id = (auth.jwt() ->> 'tenant_id')::uuid);

CREATE POLICY promotion_logs_tenant_select ON public.promotion_logs
  FOR SELECT USING (tenant_id = (auth.jwt() ->> 'tenant_id')::uuid);
