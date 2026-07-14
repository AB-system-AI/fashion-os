-- Phase 10: Enterprise HR & Payroll

ALTER TABLE public.employees
  ADD COLUMN IF NOT EXISTS department_id UUID,
  ADD COLUMN IF NOT EXISTS position_id UUID,
  ADD COLUMN IF NOT EXISTS store_id UUID REFERENCES public.stores (id) ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS first_name TEXT,
  ADD COLUMN IF NOT EXISTS last_name TEXT,
  ADD COLUMN IF NOT EXISTS email TEXT,
  ADD COLUMN IF NOT EXISTS phone TEXT,
  ADD COLUMN IF NOT EXISTS base_salary NUMERIC(14, 4) NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS currency CHAR(3) NOT NULL DEFAULT 'USD',
  ADD COLUMN IF NOT EXISTS version INTEGER NOT NULL DEFAULT 1;

CREATE TABLE IF NOT EXISTS public.departments (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id   UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  code        TEXT NOT NULL,
  name        TEXT NOT NULL,
  parent_id   UUID,
  manager_id  UUID REFERENCES public.employees (id) ON DELETE SET NULL,
  is_active   BOOLEAN NOT NULL DEFAULT true,
  version     INTEGER NOT NULL DEFAULT 1,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at  TIMESTAMPTZ
);

CREATE UNIQUE INDEX IF NOT EXISTS departments_tenant_code_uidx
  ON public.departments (tenant_id, code) WHERE deleted_at IS NULL;

CREATE TABLE IF NOT EXISTS public.positions (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  code            TEXT NOT NULL,
  name            TEXT NOT NULL,
  department_id   UUID REFERENCES public.departments (id) ON DELETE SET NULL,
  default_salary  NUMERIC(14, 4) NOT NULL DEFAULT 0,
  is_active       BOOLEAN NOT NULL DEFAULT true,
  version         INTEGER NOT NULL DEFAULT 1,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at      TIMESTAMPTZ
);

CREATE UNIQUE INDEX IF NOT EXISTS positions_tenant_code_uidx
  ON public.positions (tenant_id, code) WHERE deleted_at IS NULL;

CREATE TABLE IF NOT EXISTS public.shifts (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id     UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  employee_id   UUID NOT NULL REFERENCES public.employees (id) ON DELETE CASCADE,
  store_id      UUID NOT NULL REFERENCES public.stores (id) ON DELETE RESTRICT,
  start_time    TIMESTAMPTZ NOT NULL,
  end_time      TIMESTAMPTZ NOT NULL,
  status        TEXT NOT NULL DEFAULT 'scheduled',
  opened_at     TIMESTAMPTZ,
  closed_at     TIMESTAMPTZ,
  version       INTEGER NOT NULL DEFAULT 1,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at    TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS shifts_employee_idx ON public.shifts (employee_id, start_time);

CREATE TABLE IF NOT EXISTS public.attendance_records (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  employee_id     UUID NOT NULL REFERENCES public.employees (id) ON DELETE CASCADE,
  store_id        UUID REFERENCES public.stores (id) ON DELETE SET NULL,
  shift_id        UUID REFERENCES public.shifts (id) ON DELETE SET NULL,
  record_date     DATE NOT NULL,
  clock_in        TIMESTAMPTZ,
  clock_out       TIMESTAMPTZ,
  status          TEXT NOT NULL DEFAULT 'present',
  late_minutes    INTEGER NOT NULL DEFAULT 0,
  worked_minutes  INTEGER NOT NULL DEFAULT 0,
  notes           TEXT,
  version         INTEGER NOT NULL DEFAULT 1,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at      TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS attendance_records_employee_date_idx
  ON public.attendance_records (employee_id, record_date);

CREATE TABLE IF NOT EXISTS public.overtime_records (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  employee_id     UUID NOT NULL REFERENCES public.employees (id) ON DELETE CASCADE,
  attendance_id   UUID REFERENCES public.attendance_records (id) ON DELETE SET NULL,
  overtime_date   DATE NOT NULL,
  hours           NUMERIC(8, 2) NOT NULL DEFAULT 0,
  rate_multiplier NUMERIC(6, 2) NOT NULL DEFAULT 1.5,
  amount          NUMERIC(14, 4) NOT NULL DEFAULT 0,
  is_approved     BOOLEAN NOT NULL DEFAULT false,
  version         INTEGER NOT NULL DEFAULT 1,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at      TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.leave_requests (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id     UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  employee_id   UUID NOT NULL REFERENCES public.employees (id) ON DELETE CASCADE,
  leave_type    TEXT NOT NULL,
  start_date    DATE NOT NULL,
  end_date      DATE NOT NULL,
  days          NUMERIC(6, 2) NOT NULL DEFAULT 0,
  status        TEXT NOT NULL DEFAULT 'pending',
  reason        TEXT,
  approved_by   UUID REFERENCES public.employees (id) ON DELETE SET NULL,
  approved_at   TIMESTAMPTZ,
  version       INTEGER NOT NULL DEFAULT 1,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at    TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.leave_balances (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  employee_id     UUID NOT NULL REFERENCES public.employees (id) ON DELETE CASCADE,
  leave_type      TEXT NOT NULL,
  entitled_days   NUMERIC(6, 2) NOT NULL DEFAULT 0,
  used_days       NUMERIC(6, 2) NOT NULL DEFAULT 0,
  year            INTEGER,
  version         INTEGER NOT NULL DEFAULT 1,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at      TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.payroll_periods (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id   UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  name        TEXT NOT NULL,
  start_date  DATE NOT NULL,
  end_date    DATE NOT NULL,
  is_closed   BOOLEAN NOT NULL DEFAULT false,
  version     INTEGER NOT NULL DEFAULT 1,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at  TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.payroll_runs (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id         UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  payroll_period_id UUID NOT NULL REFERENCES public.payroll_periods (id) ON DELETE RESTRICT,
  run_number        TEXT NOT NULL,
  status            TEXT NOT NULL DEFAULT 'draft',
  total_gross       NUMERIC(14, 4) NOT NULL DEFAULT 0,
  total_deductions  NUMERIC(14, 4) NOT NULL DEFAULT 0,
  total_tax         NUMERIC(14, 4) NOT NULL DEFAULT 0,
  total_net         NUMERIC(14, 4) NOT NULL DEFAULT 0,
  approved_at       TIMESTAMPTZ,
  approved_by       UUID REFERENCES public.employees (id) ON DELETE SET NULL,
  version           INTEGER NOT NULL DEFAULT 1,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at        TIMESTAMPTZ
);

CREATE UNIQUE INDEX IF NOT EXISTS payroll_runs_tenant_number_uidx
  ON public.payroll_runs (tenant_id, run_number);

CREATE TABLE IF NOT EXISTS public.payroll_items (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  payroll_run_id  UUID NOT NULL REFERENCES public.payroll_runs (id) ON DELETE CASCADE,
  employee_id     UUID NOT NULL REFERENCES public.employees (id) ON DELETE CASCADE,
  item_type       TEXT NOT NULL,
  amount          NUMERIC(14, 4) NOT NULL DEFAULT 0,
  description     TEXT,
  version         INTEGER NOT NULL DEFAULT 1,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at      TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.salary_structures (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  employee_id     UUID NOT NULL REFERENCES public.employees (id) ON DELETE CASCADE,
  base_salary     NUMERIC(14, 4) NOT NULL DEFAULT 0,
  currency        CHAR(3) NOT NULL DEFAULT 'USD',
  pay_frequency   TEXT NOT NULL DEFAULT 'monthly',
  effective_from  DATE,
  is_active       BOOLEAN NOT NULL DEFAULT true,
  version         INTEGER NOT NULL DEFAULT 1,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at      TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.bonuses (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  employee_id     UUID NOT NULL REFERENCES public.employees (id) ON DELETE CASCADE,
  amount          NUMERIC(14, 4) NOT NULL DEFAULT 0,
  bonus_date      DATE NOT NULL,
  reason          TEXT,
  payroll_run_id  UUID REFERENCES public.payroll_runs (id) ON DELETE SET NULL,
  version         INTEGER NOT NULL DEFAULT 1,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at      TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.deductions (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  employee_id     UUID NOT NULL REFERENCES public.employees (id) ON DELETE CASCADE,
  code            TEXT NOT NULL,
  name            TEXT NOT NULL,
  amount          NUMERIC(14, 4) NOT NULL DEFAULT 0,
  is_percentage   BOOLEAN NOT NULL DEFAULT false,
  is_active       BOOLEAN NOT NULL DEFAULT true,
  version         INTEGER NOT NULL DEFAULT 1,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at      TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.commissions (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  employee_id     UUID NOT NULL REFERENCES public.employees (id) ON DELETE CASCADE,
  amount          NUMERIC(14, 4) NOT NULL DEFAULT 0,
  commission_date DATE NOT NULL,
  sale_id         UUID,
  rate_percent    NUMERIC(6, 2),
  payroll_run_id  UUID REFERENCES public.payroll_runs (id) ON DELETE SET NULL,
  version         INTEGER NOT NULL DEFAULT 1,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at      TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.performance_reviews (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id     UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  employee_id   UUID NOT NULL REFERENCES public.employees (id) ON DELETE CASCADE,
  reviewer_id   UUID REFERENCES public.employees (id) ON DELETE SET NULL,
  review_date   DATE NOT NULL,
  rating        TEXT NOT NULL,
  score         NUMERIC(5, 2),
  comments      TEXT,
  sales_count   INTEGER,
  sales_total   NUMERIC(14, 4),
  version       INTEGER NOT NULL DEFAULT 1,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at    TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.employee_documents (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id     UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  employee_id   UUID NOT NULL REFERENCES public.employees (id) ON DELETE CASCADE,
  title         TEXT NOT NULL,
  category      TEXT NOT NULL DEFAULT 'other',
  file_url      TEXT,
  file_name     TEXT,
  mime_type     TEXT,
  expires_at    TIMESTAMPTZ,
  version       INTEGER NOT NULL DEFAULT 1,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at    TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS employees_updated_at_idx ON public.employees (updated_at DESC);
CREATE INDEX IF NOT EXISTS attendance_records_updated_at_idx ON public.attendance_records (updated_at DESC);
CREATE INDEX IF NOT EXISTS payroll_runs_updated_at_idx ON public.payroll_runs (updated_at DESC);
CREATE INDEX IF NOT EXISTS leave_requests_updated_at_idx ON public.leave_requests (updated_at DESC);

ALTER TABLE public.employees ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.attendance_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payroll_runs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.leave_requests ENABLE ROW LEVEL SECURITY;

CREATE POLICY employees_tenant_select ON public.employees
  FOR SELECT USING (tenant_id = (auth.jwt() ->> 'tenant_id')::uuid);

CREATE POLICY attendance_records_tenant_select ON public.attendance_records
  FOR SELECT USING (tenant_id = (auth.jwt() ->> 'tenant_id')::uuid);

CREATE POLICY payroll_runs_tenant_select ON public.payroll_runs
  FOR SELECT USING (tenant_id = (auth.jwt() ->> 'tenant_id')::uuid);

CREATE POLICY leave_requests_tenant_select ON public.leave_requests
  FOR SELECT USING (tenant_id = (auth.jwt() ->> 'tenant_id')::uuid);
