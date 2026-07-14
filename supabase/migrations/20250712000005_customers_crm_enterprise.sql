-- Phase 7: Customers, Loyalty & CRM enterprise extensions

ALTER TABLE public.customers
  ADD COLUMN IF NOT EXISTS mobile TEXT,
  ADD COLUMN IF NOT EXISTS address TEXT,
  ADD COLUMN IF NOT EXISTS city TEXT,
  ADD COLUMN IF NOT EXISTS country CHAR(2) DEFAULT 'US',
  ADD COLUMN IF NOT EXISTS tags JSONB NOT NULL DEFAULT '[]',
  ADD COLUMN IF NOT EXISTS group_id UUID,
  ADD COLUMN IF NOT EXISTS loyalty_tier TEXT,
  ADD COLUMN IF NOT EXISTS loyalty_points INTEGER NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS wallet_balance NUMERIC(14, 4) NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS credit_limit NUMERIC(14, 4) NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS outstanding_credit NUMERIC(14, 4) NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS membership_barcode TEXT,
  ADD COLUMN IF NOT EXISTS version INTEGER NOT NULL DEFAULT 1;

CREATE TABLE IF NOT EXISTS public.customer_groups (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  name TEXT NOT NULL,
  code TEXT,
  description TEXT,
  pricing_rule TEXT,
  discount_percent NUMERIC(6, 2) NOT NULL DEFAULT 0,
  loyalty_multiplier NUMERIC(6, 2) NOT NULL DEFAULT 1,
  credit_limit NUMERIC(14, 4) NOT NULL DEFAULT 0,
  badge_color TEXT,
  sort_order INTEGER NOT NULL DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT true,
  version INTEGER NOT NULL DEFAULT 1,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at TIMESTAMPTZ
);

CREATE UNIQUE INDEX IF NOT EXISTS customer_groups_tenant_code_uidx
  ON public.customer_groups (tenant_id, code)
  WHERE deleted_at IS NULL AND code IS NOT NULL;

CREATE TABLE IF NOT EXISTS public.customer_wallets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  customer_id UUID NOT NULL REFERENCES public.customers (id) ON DELETE CASCADE,
  balance NUMERIC(14, 4) NOT NULL DEFAULT 0,
  currency CHAR(3) NOT NULL DEFAULT 'USD',
  transactions JSONB NOT NULL DEFAULT '[]',
  version INTEGER NOT NULL DEFAULT 1,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at TIMESTAMPTZ
);

CREATE UNIQUE INDEX IF NOT EXISTS customer_wallets_customer_uidx
  ON public.customer_wallets (tenant_id, customer_id);

CREATE TABLE IF NOT EXISTS public.customer_credit_accounts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  customer_id UUID NOT NULL REFERENCES public.customers (id) ON DELETE CASCADE,
  credit_limit NUMERIC(14, 4) NOT NULL DEFAULT 0,
  outstanding_balance NUMERIC(14, 4) NOT NULL DEFAULT 0,
  transactions JSONB NOT NULL DEFAULT '[]',
  version INTEGER NOT NULL DEFAULT 1,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at TIMESTAMPTZ
);

CREATE UNIQUE INDEX IF NOT EXISTS customer_credit_accounts_customer_uidx
  ON public.customer_credit_accounts (tenant_id, customer_id);

CREATE TABLE IF NOT EXISTS public.customer_activities (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  customer_id UUID NOT NULL REFERENCES public.customers (id) ON DELETE CASCADE,
  activity_type TEXT NOT NULL,
  title TEXT NOT NULL,
  body TEXT,
  reference_type TEXT,
  reference_id UUID,
  favorite_product_ids JSONB NOT NULL DEFAULT '[]',
  employee_id UUID,
  occurred_at TIMESTAMPTZ,
  version INTEGER NOT NULL DEFAULT 1,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS customer_activities_customer_idx ON public.customer_activities (tenant_id, customer_id);

ALTER TABLE public.customer_loyalty_accounts ADD COLUMN IF NOT EXISTS version INTEGER NOT NULL DEFAULT 1;
ALTER TABLE public.loyalty_point_transactions ADD COLUMN IF NOT EXISTS customer_id UUID;
ALTER TABLE public.loyalty_point_transactions ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ NOT NULL DEFAULT now();
ALTER TABLE public.loyalty_point_transactions ADD COLUMN IF NOT EXISTS version INTEGER NOT NULL DEFAULT 1;

ALTER TABLE public.customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.customer_groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.customer_wallets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.customer_credit_accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.customer_activities ENABLE ROW LEVEL SECURITY;
