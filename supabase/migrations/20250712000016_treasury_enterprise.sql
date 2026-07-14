-- Phase 14: Enterprise Treasury — Cash, Banks, Transfers, Cheques, Vouchers, Expenses, Forecast, Reconciliation

CREATE TABLE IF NOT EXISTS public.cash_boxes (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  name            TEXT NOT NULL,
  store_id        UUID,
  status          TEXT NOT NULL DEFAULT 'open',
  currency_code   TEXT NOT NULL DEFAULT 'USD',
  balance         NUMERIC(18, 4) NOT NULL DEFAULT 0,
  version         INTEGER NOT NULL DEFAULT 1,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at      TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.banks (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  name            TEXT NOT NULL,
  code            TEXT,
  swift_code      TEXT,
  country         TEXT,
  is_active       BOOLEAN NOT NULL DEFAULT true,
  version         INTEGER NOT NULL DEFAULT 1,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at      TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.bank_accounts (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  bank_id         UUID NOT NULL REFERENCES public.banks (id) ON DELETE CASCADE,
  account_number  TEXT NOT NULL,
  account_name    TEXT,
  iban            TEXT,
  currency_code   TEXT NOT NULL DEFAULT 'USD',
  balance         NUMERIC(18, 4) NOT NULL DEFAULT 0,
  status          TEXT NOT NULL DEFAULT 'active',
  interest_rate   NUMERIC(8, 4) NOT NULL DEFAULT 0,
  version         INTEGER NOT NULL DEFAULT 1,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at      TIMESTAMPTZ
);

CREATE UNIQUE INDEX IF NOT EXISTS bank_accounts_tenant_number_uidx ON public.bank_accounts (tenant_id, account_number) WHERE deleted_at IS NULL;

CREATE TABLE IF NOT EXISTS public.petty_cash_funds (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  name            TEXT NOT NULL,
  custodian_id    UUID NOT NULL,
  balance         NUMERIC(18, 4) NOT NULL DEFAULT 0,
  limit_amount    NUMERIC(18, 4) NOT NULL DEFAULT 0,
  currency_code   TEXT NOT NULL DEFAULT 'USD',
  version         INTEGER NOT NULL DEFAULT 1,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at      TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.treasury_transfers (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id         UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  transfer_number   TEXT NOT NULL,
  from_account_id   UUID NOT NULL,
  to_account_id     UUID NOT NULL,
  status            TEXT NOT NULL DEFAULT 'draft',
  amount            NUMERIC(18, 4) NOT NULL DEFAULT 0,
  currency_code     TEXT NOT NULL DEFAULT 'USD',
  exchange_rate     NUMERIC(12, 6) NOT NULL DEFAULT 1,
  notes             TEXT,
  version           INTEGER NOT NULL DEFAULT 1,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at        TIMESTAMPTZ
);

CREATE UNIQUE INDEX IF NOT EXISTS treasury_transfers_tenant_number_uidx ON public.treasury_transfers (tenant_id, transfer_number) WHERE deleted_at IS NULL;

CREATE TABLE IF NOT EXISTS public.cheques (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id         UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  cheque_number     TEXT NOT NULL,
  bank_account_id   UUID NOT NULL REFERENCES public.bank_accounts (id) ON DELETE CASCADE,
  cheque_book_id    UUID,
  status            TEXT NOT NULL DEFAULT 'issued',
  amount            NUMERIC(18, 4) NOT NULL DEFAULT 0,
  payee             TEXT NOT NULL,
  currency_code     TEXT NOT NULL DEFAULT 'USD',
  issue_date        TIMESTAMPTZ,
  due_date          TIMESTAMPTZ,
  version           INTEGER NOT NULL DEFAULT 1,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at        TIMESTAMPTZ
);

CREATE UNIQUE INDEX IF NOT EXISTS cheques_tenant_number_uidx ON public.cheques (tenant_id, cheque_number) WHERE deleted_at IS NULL;

CREATE TABLE IF NOT EXISTS public.cheque_books (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id         UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  bank_account_id   UUID NOT NULL REFERENCES public.bank_accounts (id) ON DELETE CASCADE,
  start_number      INTEGER NOT NULL,
  end_number        INTEGER NOT NULL,
  next_number       INTEGER,
  is_active         BOOLEAN NOT NULL DEFAULT true,
  version           INTEGER NOT NULL DEFAULT 1,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at        TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.payment_vouchers (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id         UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  voucher_number    TEXT NOT NULL,
  payee_name        TEXT NOT NULL,
  amount            NUMERIC(18, 4) NOT NULL DEFAULT 0,
  account_id        UUID NOT NULL,
  status            TEXT NOT NULL DEFAULT 'draft',
  currency_code     TEXT NOT NULL DEFAULT 'USD',
  reference         TEXT,
  notes             TEXT,
  version           INTEGER NOT NULL DEFAULT 1,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at        TIMESTAMPTZ
);

CREATE UNIQUE INDEX IF NOT EXISTS payment_vouchers_tenant_number_uidx ON public.payment_vouchers (tenant_id, voucher_number) WHERE deleted_at IS NULL;

CREATE TABLE IF NOT EXISTS public.receipt_vouchers (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id         UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  voucher_number    TEXT NOT NULL,
  payer_name        TEXT NOT NULL,
  amount            NUMERIC(18, 4) NOT NULL DEFAULT 0,
  account_id        UUID NOT NULL,
  status            TEXT NOT NULL DEFAULT 'draft',
  currency_code     TEXT NOT NULL DEFAULT 'USD',
  reference         TEXT,
  notes             TEXT,
  version           INTEGER NOT NULL DEFAULT 1,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at        TIMESTAMPTZ
);

CREATE UNIQUE INDEX IF NOT EXISTS receipt_vouchers_tenant_number_uidx ON public.receipt_vouchers (tenant_id, voucher_number) WHERE deleted_at IS NULL;

CREATE TABLE IF NOT EXISTS public.expense_requests (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id         UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  request_number    TEXT NOT NULL,
  description       TEXT NOT NULL,
  amount            NUMERIC(18, 4) NOT NULL DEFAULT 0,
  category          TEXT NOT NULL,
  requested_by      UUID NOT NULL,
  department_id     UUID,
  status            TEXT NOT NULL DEFAULT 'draft',
  currency_code     TEXT NOT NULL DEFAULT 'USD',
  version           INTEGER NOT NULL DEFAULT 1,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at        TIMESTAMPTZ
);

CREATE UNIQUE INDEX IF NOT EXISTS expense_requests_tenant_number_uidx ON public.expense_requests (tenant_id, request_number) WHERE deleted_at IS NULL;

CREATE TABLE IF NOT EXISTS public.cash_forecasts (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id           UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  period              TEXT NOT NULL DEFAULT 'monthly',
  forecast_date       TIMESTAMPTZ NOT NULL,
  projected_balance   NUMERIC(18, 4) NOT NULL DEFAULT 0,
  inflows             NUMERIC(18, 4) NOT NULL DEFAULT 0,
  outflows            NUMERIC(18, 4) NOT NULL DEFAULT 0,
  currency_code       TEXT NOT NULL DEFAULT 'USD',
  version             INTEGER NOT NULL DEFAULT 1,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at          TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.bank_reconciliations (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id           UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  bank_account_id     UUID NOT NULL REFERENCES public.bank_accounts (id) ON DELETE CASCADE,
  statement_date      TIMESTAMPTZ NOT NULL,
  book_balance        NUMERIC(18, 4) NOT NULL DEFAULT 0,
  statement_balance   NUMERIC(18, 4) NOT NULL DEFAULT 0,
  variance            NUMERIC(18, 4) NOT NULL DEFAULT 0,
  status              TEXT NOT NULL DEFAULT 'open',
  reconciled_by       UUID,
  version             INTEGER NOT NULL DEFAULT 1,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at          TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.treasury_settings (
  id                          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id                   UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  base_currency               TEXT NOT NULL DEFAULT 'USD',
  expense_approval_threshold  NUMERIC(18, 4) NOT NULL DEFAULT 500,
  auto_reconcile              BOOLEAN NOT NULL DEFAULT false,
  version                     INTEGER NOT NULL DEFAULT 1,
  created_at                  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at                  TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at                  TIMESTAMPTZ
);

CREATE UNIQUE INDEX IF NOT EXISTS treasury_settings_tenant_uidx ON public.treasury_settings (tenant_id) WHERE deleted_at IS NULL;

DO $$
DECLARE t text;
BEGIN
  FOREACH t IN ARRAY ARRAY[
    'cash_boxes', 'banks', 'bank_accounts', 'petty_cash_funds', 'treasury_transfers',
    'cheques', 'cheque_books', 'payment_vouchers', 'receipt_vouchers', 'expense_requests',
    'cash_forecasts', 'bank_reconciliations', 'treasury_settings'
  ]
  LOOP
    EXECUTE format('ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY', t);
  END LOOP;
END $$;

DO $$
DECLARE t text;
BEGIN
  FOREACH t IN ARRAY ARRAY[
    'cash_boxes', 'banks', 'bank_accounts', 'petty_cash_funds', 'treasury_transfers',
    'cheques', 'cheque_books', 'payment_vouchers', 'receipt_vouchers', 'expense_requests',
    'cash_forecasts', 'bank_reconciliations', 'treasury_settings'
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
