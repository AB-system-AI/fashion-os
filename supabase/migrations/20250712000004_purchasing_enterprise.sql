-- Phase 6: Purchasing & Suppliers enterprise extensions

DO $$ BEGIN
  CREATE TYPE public.purchase_order_status AS ENUM (
    'draft',
    'pending_approval',
    'approved',
    'sent',
    'partially_received',
    'received',
    'closed',
    'cancelled'
  );
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

ALTER TABLE public.suppliers
  ADD COLUMN IF NOT EXISTS mobile TEXT,
  ADD COLUMN IF NOT EXISTS commercial_registration TEXT,
  ADD COLUMN IF NOT EXISTS credit_limit NUMERIC(14, 4) NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS current_balance NUMERIC(14, 4) NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS version INTEGER NOT NULL DEFAULT 1;

ALTER TABLE public.purchase_orders
  ADD COLUMN IF NOT EXISTS version INTEGER NOT NULL DEFAULT 1,
  ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS lines JSONB NOT NULL DEFAULT '[]';

ALTER TABLE public.purchase_receipts
  ADD COLUMN IF NOT EXISTS version INTEGER NOT NULL DEFAULT 1,
  ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS lines JSONB NOT NULL DEFAULT '[]';

CREATE TABLE IF NOT EXISTS public.purchase_returns (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  supplier_id UUID NOT NULL REFERENCES public.suppliers (id) ON DELETE RESTRICT,
  warehouse_id UUID NOT NULL REFERENCES public.warehouses (id) ON DELETE RESTRICT,
  purchase_order_id UUID REFERENCES public.purchase_orders (id) ON DELETE SET NULL,
  return_number TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'DRAFT',
  lines JSONB NOT NULL DEFAULT '[]',
  total_amount NUMERIC(14, 4) NOT NULL DEFAULT 0,
  notes TEXT,
  approved_by UUID REFERENCES public.employees (id) ON DELETE SET NULL,
  completed_at TIMESTAMPTZ,
  version INTEGER NOT NULL DEFAULT 1,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at TIMESTAMPTZ
);

CREATE UNIQUE INDEX IF NOT EXISTS purchase_returns_tenant_number_uidx
  ON public.purchase_returns (tenant_id, return_number);

CREATE TABLE IF NOT EXISTS public.supplier_payments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  supplier_id UUID NOT NULL REFERENCES public.suppliers (id) ON DELETE RESTRICT,
  purchase_order_id UUID REFERENCES public.purchase_orders (id) ON DELETE SET NULL,
  amount NUMERIC(14, 4) NOT NULL,
  currency CHAR(3) NOT NULL DEFAULT 'USD',
  type TEXT NOT NULL DEFAULT 'PAYMENT',
  reference TEXT,
  notes TEXT,
  paid_at TIMESTAMPTZ,
  version INTEGER NOT NULL DEFAULT 1,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS supplier_payments_supplier_idx ON public.supplier_payments (tenant_id, supplier_id);

CREATE TABLE IF NOT EXISTS public.supplier_statements (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  supplier_id UUID NOT NULL REFERENCES public.suppliers (id) ON DELETE RESTRICT,
  period_start TIMESTAMPTZ,
  period_end TIMESTAMPTZ,
  opening_balance NUMERIC(14, 4) NOT NULL DEFAULT 0,
  closing_balance NUMERIC(14, 4) NOT NULL DEFAULT 0,
  entries JSONB NOT NULL DEFAULT '[]',
  version INTEGER NOT NULL DEFAULT 1,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS supplier_statements_supplier_idx ON public.supplier_statements (tenant_id, supplier_id);

ALTER TABLE public.suppliers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.purchase_orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.purchase_receipts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.purchase_returns ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.supplier_payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.supplier_statements ENABLE ROW LEVEL SECURITY;
