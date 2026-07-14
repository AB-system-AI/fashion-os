-- Phase 15: Enterprise Assets & Maintenance — register, depreciation, transfers, disposal, maintenance, contracts

CREATE TABLE IF NOT EXISTS public.asset_categories (
  id                            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id                     UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  name                          TEXT NOT NULL,
  code                          TEXT,
  description                   TEXT,
  parent_id                     UUID REFERENCES public.asset_categories (id) ON DELETE SET NULL,
  default_useful_life_months    INTEGER NOT NULL DEFAULT 60,
  default_depreciation_method   TEXT NOT NULL DEFAULT 'straight_line',
  version                       INTEGER NOT NULL DEFAULT 1,
  created_at                    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at                    TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at                    TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS asset_categories_tenant_idx ON public.asset_categories (tenant_id) WHERE deleted_at IS NULL;

CREATE TABLE IF NOT EXISTS public.asset_locations (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  name            TEXT NOT NULL,
  code            TEXT,
  address         TEXT,
  store_id        UUID,
  warehouse_id    UUID,
  version         INTEGER NOT NULL DEFAULT 1,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at      TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS asset_locations_tenant_idx ON public.asset_locations (tenant_id) WHERE deleted_at IS NULL;

CREATE TABLE IF NOT EXISTS public.assets (
  id                        UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id                 UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  name                      TEXT NOT NULL,
  asset_tag                 TEXT,
  serial_number             TEXT,
  description               TEXT,
  category_id               UUID NOT NULL REFERENCES public.asset_categories (id) ON DELETE RESTRICT,
  location_id               UUID NOT NULL REFERENCES public.asset_locations (id) ON DELETE RESTRICT,
  status                    TEXT NOT NULL DEFAULT 'active',
  acquisition_cost          NUMERIC(18, 2) NOT NULL DEFAULT 0,
  book_value                NUMERIC(18, 2) NOT NULL DEFAULT 0,
  accumulated_depreciation  NUMERIC(18, 2) NOT NULL DEFAULT 0,
  acquisition_date          TIMESTAMPTZ,
  useful_life_months        INTEGER NOT NULL DEFAULT 60,
  salvage_value             NUMERIC(18, 2) NOT NULL DEFAULT 0,
  depreciation_method       TEXT NOT NULL DEFAULT 'straight_line',
  last_maintenance_at       TIMESTAMPTZ,
  version                   INTEGER NOT NULL DEFAULT 1,
  created_at                TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at                TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at                TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS assets_tenant_status_idx ON public.assets (tenant_id, status) WHERE deleted_at IS NULL;
CREATE UNIQUE INDEX IF NOT EXISTS assets_tenant_tag_uidx ON public.assets (tenant_id, asset_tag) WHERE deleted_at IS NULL AND asset_tag IS NOT NULL;

CREATE TABLE IF NOT EXISTS public.asset_depreciation (
  id                        UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id                 UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  asset_id                  UUID NOT NULL REFERENCES public.assets (id) ON DELETE CASCADE,
  period                    INTEGER NOT NULL,
  depreciation_amount       NUMERIC(18, 2) NOT NULL DEFAULT 0,
  accumulated_depreciation  NUMERIC(18, 2) NOT NULL DEFAULT 0,
  book_value                NUMERIC(18, 2) NOT NULL DEFAULT 0,
  posted_at                 TIMESTAMPTZ,
  journal_entry_id          UUID,
  version                   INTEGER NOT NULL DEFAULT 1,
  created_at                TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at                TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at                TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS asset_depreciation_asset_idx ON public.asset_depreciation (tenant_id, asset_id) WHERE deleted_at IS NULL;

CREATE TABLE IF NOT EXISTS public.asset_transfers (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id         UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  asset_id          UUID NOT NULL REFERENCES public.assets (id) ON DELETE CASCADE,
  from_location_id  UUID REFERENCES public.asset_locations (id) ON DELETE SET NULL,
  to_location_id    UUID NOT NULL REFERENCES public.asset_locations (id) ON DELETE RESTRICT,
  status            TEXT NOT NULL DEFAULT 'pending',
  notes             TEXT,
  transferred_at    TIMESTAMPTZ,
  transferred_by    UUID,
  version           INTEGER NOT NULL DEFAULT 1,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at        TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS asset_transfers_asset_idx ON public.asset_transfers (tenant_id, asset_id) WHERE deleted_at IS NULL;

CREATE TABLE IF NOT EXISTS public.asset_disposals (
  id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id               UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  asset_id                UUID NOT NULL REFERENCES public.assets (id) ON DELETE CASCADE,
  method                  TEXT NOT NULL DEFAULT 'write_off',
  proceeds                NUMERIC(18, 2) NOT NULL DEFAULT 0,
  book_value_at_disposal  NUMERIC(18, 2) NOT NULL DEFAULT 0,
  gain_loss               NUMERIC(18, 2) NOT NULL DEFAULT 0,
  notes                   TEXT,
  disposed_at             TIMESTAMPTZ,
  disposed_by             UUID,
  journal_entry_id        UUID,
  version                 INTEGER NOT NULL DEFAULT 1,
  created_at              TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at              TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at              TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS asset_disposals_asset_idx ON public.asset_disposals (tenant_id, asset_id) WHERE deleted_at IS NULL;

CREATE TABLE IF NOT EXISTS public.maintenance_requests (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  asset_id        UUID NOT NULL REFERENCES public.assets (id) ON DELETE CASCADE,
  title           TEXT NOT NULL,
  description     TEXT,
  status          TEXT NOT NULL DEFAULT 'open',
  priority        INTEGER NOT NULL DEFAULT 1,
  schedule_type   TEXT NOT NULL DEFAULT 'corrective',
  requested_by    UUID,
  assigned_to     UUID,
  completed_at    TIMESTAMPTZ,
  version         INTEGER NOT NULL DEFAULT 1,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at      TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS maintenance_requests_asset_idx ON public.maintenance_requests (tenant_id, asset_id) WHERE deleted_at IS NULL;

CREATE TABLE IF NOT EXISTS public.maintenance_schedules (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id           UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  asset_id            UUID NOT NULL REFERENCES public.assets (id) ON DELETE CASCADE,
  name                TEXT NOT NULL,
  schedule_type       TEXT NOT NULL DEFAULT 'preventive',
  interval_days       INTEGER NOT NULL DEFAULT 90,
  next_due_at         TIMESTAMPTZ,
  last_completed_at   TIMESTAMPTZ,
  is_active           BOOLEAN NOT NULL DEFAULT true,
  version             INTEGER NOT NULL DEFAULT 1,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at          TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS maintenance_schedules_due_idx ON public.maintenance_schedules (tenant_id, next_due_at) WHERE deleted_at IS NULL;

CREATE TABLE IF NOT EXISTS public.maintenance_tasks (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  request_id      UUID NOT NULL REFERENCES public.maintenance_requests (id) ON DELETE CASCADE,
  name            TEXT NOT NULL,
  description     TEXT,
  is_completed    BOOLEAN NOT NULL DEFAULT false,
  completed_at    TIMESTAMPTZ,
  version         INTEGER NOT NULL DEFAULT 1,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at      TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS maintenance_tasks_request_idx ON public.maintenance_tasks (tenant_id, request_id) WHERE deleted_at IS NULL;

CREATE TABLE IF NOT EXISTS public.maintenance_costs (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  request_id      UUID NOT NULL REFERENCES public.maintenance_requests (id) ON DELETE CASCADE,
  cost_type       TEXT NOT NULL DEFAULT 'labor',
  amount          NUMERIC(18, 2) NOT NULL DEFAULT 0,
  description     TEXT,
  vendor_id       UUID,
  version         INTEGER NOT NULL DEFAULT 1,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at      TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS maintenance_costs_request_idx ON public.maintenance_costs (tenant_id, request_id) WHERE deleted_at IS NULL;

CREATE TABLE IF NOT EXISTS public.service_contracts (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id         UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  name              TEXT NOT NULL,
  asset_id          UUID REFERENCES public.assets (id) ON DELETE SET NULL,
  vendor_id         UUID,
  status            TEXT NOT NULL DEFAULT 'active',
  start_date        TIMESTAMPTZ,
  end_date          TIMESTAMPTZ,
  annual_cost       NUMERIC(18, 2) NOT NULL DEFAULT 0,
  coverage_details  TEXT,
  version           INTEGER NOT NULL DEFAULT 1,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at        TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS service_contracts_tenant_idx ON public.service_contracts (tenant_id, status) WHERE deleted_at IS NULL;

CREATE TABLE IF NOT EXISTS public.warranties (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id   UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  asset_id    UUID NOT NULL REFERENCES public.assets (id) ON DELETE CASCADE,
  provider    TEXT NOT NULL,
  status      TEXT NOT NULL DEFAULT 'active',
  start_date  TIMESTAMPTZ,
  end_date    TIMESTAMPTZ,
  terms       TEXT,
  version     INTEGER NOT NULL DEFAULT 1,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at  TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS warranties_asset_idx ON public.warranties (tenant_id, asset_id) WHERE deleted_at IS NULL;

CREATE TABLE IF NOT EXISTS public.asset_audits (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id     UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  name          TEXT NOT NULL,
  status        TEXT NOT NULL DEFAULT 'planned',
  location_id   UUID REFERENCES public.asset_locations (id) ON DELETE SET NULL,
  scheduled_at  TIMESTAMPTZ,
  completed_at  TIMESTAMPTZ,
  auditor_id    UUID,
  findings      TEXT,
  version       INTEGER NOT NULL DEFAULT 1,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at    TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS asset_audits_tenant_idx ON public.asset_audits (tenant_id, status) WHERE deleted_at IS NULL;

CREATE TABLE IF NOT EXISTS public.asset_settings (
  id                              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id                       UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  default_depreciation_method     TEXT NOT NULL DEFAULT 'straight_line',
  default_useful_life_months      INTEGER NOT NULL DEFAULT 60,
  enable_auto_depreciation        BOOLEAN NOT NULL DEFAULT true,
  enable_maintenance_alerts       BOOLEAN NOT NULL DEFAULT true,
  maintenance_alert_days          INTEGER NOT NULL DEFAULT 7,
  require_approval_for_disposal   BOOLEAN NOT NULL DEFAULT true,
  version                         INTEGER NOT NULL DEFAULT 1,
  created_at                      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at                      TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at                      TIMESTAMPTZ
);

CREATE UNIQUE INDEX IF NOT EXISTS asset_settings_tenant_uidx ON public.asset_settings (tenant_id) WHERE deleted_at IS NULL;

DO $$
DECLARE t text;
BEGIN
  FOREACH t IN ARRAY ARRAY[
    'asset_categories', 'asset_locations', 'assets', 'asset_depreciation', 'asset_transfers',
    'asset_disposals', 'maintenance_requests', 'maintenance_schedules', 'maintenance_tasks',
    'maintenance_costs', 'service_contracts', 'warranties', 'asset_audits', 'asset_settings'
  ]
  LOOP
    EXECUTE format('ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY', t);
  END LOOP;
END $$;

DO $$
DECLARE t text;
BEGIN
  FOREACH t IN ARRAY ARRAY[
    'asset_categories', 'asset_locations', 'assets', 'asset_depreciation', 'asset_transfers',
    'asset_disposals', 'maintenance_requests', 'maintenance_schedules', 'maintenance_tasks',
    'maintenance_costs', 'service_contracts', 'warranties', 'asset_audits', 'asset_settings'
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
