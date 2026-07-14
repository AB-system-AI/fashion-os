-- Phase 9: Enterprise Accounting & General Ledger

CREATE TABLE IF NOT EXISTS public.chart_of_accounts (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id         UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  code              TEXT NOT NULL,
  name              TEXT NOT NULL,
  account_type      TEXT NOT NULL,
  normal_balance    TEXT NOT NULL DEFAULT 'debit',
  group_id          UUID,
  currency          CHAR(3) NOT NULL DEFAULT 'USD',
  parent_account_id UUID,
  is_system         BOOLEAN NOT NULL DEFAULT false,
  is_active         BOOLEAN NOT NULL DEFAULT true,
  balance           NUMERIC(14, 4) NOT NULL DEFAULT 0,
  version           INTEGER NOT NULL DEFAULT 1,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at        TIMESTAMPTZ
);

CREATE UNIQUE INDEX IF NOT EXISTS chart_of_accounts_tenant_code_uidx
  ON public.chart_of_accounts (tenant_id, code) WHERE deleted_at IS NULL;

CREATE TABLE IF NOT EXISTS public.account_groups (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id   UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  name        TEXT NOT NULL,
  code        TEXT NOT NULL,
  parent_id   UUID,
  sort_order  INTEGER NOT NULL DEFAULT 0,
  is_active   BOOLEAN NOT NULL DEFAULT true,
  version     INTEGER NOT NULL DEFAULT 1,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at  TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.journal_entries (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id         UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  store_id          UUID REFERENCES public.stores (id) ON DELETE SET NULL,
  entry_number      TEXT NOT NULL,
  entry_date        DATE NOT NULL,
  status            TEXT NOT NULL DEFAULT 'draft',
  source            TEXT NOT NULL DEFAULT 'manual',
  reference_type    TEXT,
  reference_id      UUID,
  description       TEXT,
  fiscal_period_id  UUID,
  currency          CHAR(3) NOT NULL DEFAULT 'USD',
  total_debit       NUMERIC(14, 4) NOT NULL DEFAULT 0,
  total_credit      NUMERIC(14, 4) NOT NULL DEFAULT 0,
  posted_at         TIMESTAMPTZ,
  reversed_entry_id UUID,
  version           INTEGER NOT NULL DEFAULT 1,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at        TIMESTAMPTZ
);

CREATE UNIQUE INDEX IF NOT EXISTS journal_entries_tenant_number_uidx
  ON public.journal_entries (tenant_id, entry_number);

CREATE TABLE IF NOT EXISTS public.journal_lines (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  journal_entry_id UUID NOT NULL REFERENCES public.journal_entries (id) ON DELETE CASCADE,
  account_id      UUID NOT NULL,
  account_code    TEXT NOT NULL,
  debit           NUMERIC(14, 4) NOT NULL DEFAULT 0,
  credit          NUMERIC(14, 4) NOT NULL DEFAULT 0,
  description     TEXT,
  cost_center_id  UUID,
  tax_code_id     UUID,
  currency        CHAR(3) NOT NULL DEFAULT 'USD',
  exchange_rate   NUMERIC(14, 6) NOT NULL DEFAULT 1,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS journal_lines_entry_id_idx ON public.journal_lines (journal_entry_id);

CREATE TABLE IF NOT EXISTS public.ledger_transactions (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id         UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  store_id          UUID REFERENCES public.stores (id) ON DELETE SET NULL,
  account_id        UUID NOT NULL,
  account_code      TEXT,
  journal_entry_id  UUID NOT NULL REFERENCES public.journal_entries (id) ON DELETE RESTRICT,
  entry_date        DATE NOT NULL,
  debit             NUMERIC(14, 4) NOT NULL DEFAULT 0,
  credit            NUMERIC(14, 4) NOT NULL DEFAULT 0,
  description       TEXT,
  reference_type    TEXT,
  reference_id      UUID,
  cost_center_id    UUID,
  currency          CHAR(3) NOT NULL DEFAULT 'USD',
  running_balance   NUMERIC(14, 4),
  version           INTEGER NOT NULL DEFAULT 1,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at        TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS ledger_transactions_account_idx ON public.ledger_transactions (account_id, entry_date);
CREATE INDEX IF NOT EXISTS ledger_transactions_journal_idx ON public.ledger_transactions (journal_entry_id);

CREATE TABLE IF NOT EXISTS public.fiscal_years (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id   UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  name        TEXT NOT NULL,
  start_date  DATE NOT NULL,
  end_date    DATE NOT NULL,
  is_closed   BOOLEAN NOT NULL DEFAULT false,
  closed_at   TIMESTAMPTZ,
  version     INTEGER NOT NULL DEFAULT 1,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at  TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.fiscal_periods (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  fiscal_year_id  UUID NOT NULL REFERENCES public.fiscal_years (id) ON DELETE CASCADE,
  name            TEXT NOT NULL,
  period_number   INTEGER NOT NULL,
  start_date      DATE NOT NULL,
  end_date        DATE NOT NULL,
  status          TEXT NOT NULL DEFAULT 'open',
  closed_at       TIMESTAMPTZ,
  version         INTEGER NOT NULL DEFAULT 1,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at      TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.cost_centers (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id   UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  store_id    UUID REFERENCES public.stores (id) ON DELETE SET NULL,
  code        TEXT NOT NULL,
  name        TEXT NOT NULL,
  parent_id   UUID,
  is_active   BOOLEAN NOT NULL DEFAULT true,
  version     INTEGER NOT NULL DEFAULT 1,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at  TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.bank_accounts (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  name            TEXT NOT NULL,
  account_number  TEXT NOT NULL,
  currency        CHAR(3) NOT NULL DEFAULT 'USD',
  gl_account_id   UUID,
  bank_name       TEXT,
  iban            TEXT,
  balance         NUMERIC(14, 4) NOT NULL DEFAULT 0,
  is_active       BOOLEAN NOT NULL DEFAULT true,
  version         INTEGER NOT NULL DEFAULT 1,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at      TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.bank_transactions (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id         UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  bank_account_id   UUID NOT NULL REFERENCES public.bank_accounts (id) ON DELETE CASCADE,
  transaction_type  TEXT NOT NULL,
  amount            NUMERIC(14, 4) NOT NULL,
  transaction_date  DATE NOT NULL,
  reference         TEXT,
  description       TEXT,
  is_reconciled     BOOLEAN NOT NULL DEFAULT false,
  journal_entry_id  UUID,
  version           INTEGER NOT NULL DEFAULT 1,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.reconciliation_sessions (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id         UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  bank_account_id   UUID NOT NULL REFERENCES public.bank_accounts (id) ON DELETE CASCADE,
  statement_date    DATE NOT NULL,
  statement_balance NUMERIC(14, 4) NOT NULL,
  status            TEXT NOT NULL DEFAULT 'open',
  book_balance      NUMERIC(14, 4),
  difference        NUMERIC(14, 4),
  completed_at      TIMESTAMPTZ,
  version           INTEGER NOT NULL DEFAULT 1,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at        TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.exchange_rates (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  from_currency   CHAR(3) NOT NULL,
  to_currency     CHAR(3) NOT NULL,
  rate            NUMERIC(14, 6) NOT NULL,
  effective_date  DATE NOT NULL,
  source          TEXT,
  version         INTEGER NOT NULL DEFAULT 1,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at      TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.payment_terms (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id         UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  code              TEXT NOT NULL,
  name              TEXT NOT NULL,
  due_days          INTEGER NOT NULL DEFAULT 0,
  discount_percent  NUMERIC(6, 2),
  discount_days     INTEGER,
  is_active         BOOLEAN NOT NULL DEFAULT true,
  version           INTEGER NOT NULL DEFAULT 1,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at        TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.tax_codes (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id   UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  code        TEXT NOT NULL,
  name        TEXT NOT NULL,
  rate        NUMERIC(8, 4) NOT NULL DEFAULT 0,
  account_id  UUID,
  is_active   BOOLEAN NOT NULL DEFAULT true,
  version     INTEGER NOT NULL DEFAULT 1,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at  TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.tax_groups (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id     UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  code          TEXT NOT NULL,
  name          TEXT NOT NULL,
  tax_code_ids  JSONB NOT NULL DEFAULT '[]',
  is_active     BOOLEAN NOT NULL DEFAULT true,
  version       INTEGER NOT NULL DEFAULT 1,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at    TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.financial_reports (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id     UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  report_type   TEXT NOT NULL,
  report_name   TEXT NOT NULL,
  parameters    JSONB NOT NULL DEFAULT '{}',
  result_data   JSONB NOT NULL DEFAULT '{}',
  generated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  version       INTEGER NOT NULL DEFAULT 1,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS journal_entries_updated_at_idx ON public.journal_entries (updated_at DESC);
CREATE INDEX IF NOT EXISTS ledger_transactions_updated_at_idx ON public.ledger_transactions (updated_at DESC);
CREATE INDEX IF NOT EXISTS chart_of_accounts_updated_at_idx ON public.chart_of_accounts (updated_at DESC);

ALTER TABLE public.chart_of_accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.journal_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ledger_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bank_accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.fiscal_years ENABLE ROW LEVEL SECURITY;

CREATE POLICY chart_of_accounts_tenant_select ON public.chart_of_accounts
  FOR SELECT USING (tenant_id = (auth.jwt() ->> 'tenant_id')::uuid);

CREATE POLICY journal_entries_tenant_select ON public.journal_entries
  FOR SELECT USING (tenant_id = (auth.jwt() ->> 'tenant_id')::uuid);

CREATE POLICY ledger_transactions_tenant_select ON public.ledger_transactions
  FOR SELECT USING (tenant_id = (auth.jwt() ->> 'tenant_id')::uuid);

CREATE POLICY bank_accounts_tenant_select ON public.bank_accounts
  FOR SELECT USING (tenant_id = (auth.jwt() ->> 'tenant_id')::uuid);

CREATE POLICY fiscal_years_tenant_select ON public.fiscal_years
  FOR SELECT USING (tenant_id = (auth.jwt() ->> 'tenant_id')::uuid);
