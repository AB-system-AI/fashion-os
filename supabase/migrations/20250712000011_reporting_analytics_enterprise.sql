-- Phase 12: Enterprise Reporting, BI & Analytics

CREATE TABLE IF NOT EXISTS public.report_definitions (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  name            TEXT NOT NULL,
  module          TEXT NOT NULL DEFAULT 'executive',
  description     TEXT,
  status          TEXT NOT NULL DEFAULT 'draft',
  filters         JSONB NOT NULL DEFAULT '{}'::jsonb,
  columns         JSONB NOT NULL DEFAULT '[]'::jsonb,
  group_by        TEXT,
  sort_by         TEXT,
  template_id     UUID,
  created_by      UUID,
  version         INTEGER NOT NULL DEFAULT 1,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at      TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS report_definitions_tenant_module_idx
  ON public.report_definitions (tenant_id, module) WHERE deleted_at IS NULL;

CREATE TABLE IF NOT EXISTS public.report_templates (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  name            TEXT NOT NULL,
  module          TEXT NOT NULL DEFAULT 'executive',
  definition      JSONB NOT NULL DEFAULT '{}'::jsonb,
  is_system       BOOLEAN NOT NULL DEFAULT false,
  version         INTEGER NOT NULL DEFAULT 1,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at      TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.report_exports (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  report_id       UUID NOT NULL REFERENCES public.report_definitions (id) ON DELETE CASCADE,
  format          TEXT NOT NULL DEFAULT 'csv',
  file_name       TEXT,
  filters_used    JSONB NOT NULL DEFAULT '{}'::jsonb,
  generated_by    UUID,
  version         INTEGER NOT NULL DEFAULT 1,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at      TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.report_snapshots (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  report_id       UUID NOT NULL REFERENCES public.report_definitions (id) ON DELETE CASCADE,
  data            JSONB NOT NULL DEFAULT '{}'::jsonb,
  snapshot_at     TIMESTAMPTZ,
  version         INTEGER NOT NULL DEFAULT 1,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at      TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.dashboard_layouts (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  name            TEXT NOT NULL,
  dashboard_type  TEXT NOT NULL DEFAULT 'executive',
  is_default      BOOLEAN NOT NULL DEFAULT false,
  store_id        UUID,
  version         INTEGER NOT NULL DEFAULT 1,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at      TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.dashboard_widgets (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  layout_id       UUID NOT NULL REFERENCES public.dashboard_layouts (id) ON DELETE CASCADE,
  title           TEXT NOT NULL,
  widget_type     TEXT NOT NULL DEFAULT 'metric',
  chart_type      TEXT NOT NULL DEFAULT 'bar',
  config          JSONB NOT NULL DEFAULT '{}'::jsonb,
  position        INTEGER NOT NULL DEFAULT 0,
  version         INTEGER NOT NULL DEFAULT 1,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at      TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.analytics_snapshots (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  snapshot_type   TEXT NOT NULL,
  metrics         JSONB NOT NULL DEFAULT '{}'::jsonb,
  store_id        UUID,
  version         INTEGER NOT NULL DEFAULT 1,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at      TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.kpi_snapshots (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  category        TEXT NOT NULL,
  kpi_code        TEXT NOT NULL,
  value           NUMERIC(18, 4) NOT NULL DEFAULT 0,
  unit            TEXT,
  period_start    TIMESTAMPTZ,
  period_end      TIMESTAMPTZ,
  version         INTEGER NOT NULL DEFAULT 1,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at      TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS kpi_snapshots_tenant_category_idx
  ON public.kpi_snapshots (tenant_id, category) WHERE deleted_at IS NULL;

CREATE TABLE IF NOT EXISTS public.scheduled_reports (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id           UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  report_id           UUID NOT NULL REFERENCES public.report_definitions (id) ON DELETE CASCADE,
  frequency           TEXT NOT NULL DEFAULT 'manual',
  is_active           BOOLEAN NOT NULL DEFAULT true,
  recipient_email     TEXT,
  last_executed_at    TIMESTAMPTZ,
  next_execution_at   TIMESTAMPTZ,
  version             INTEGER NOT NULL DEFAULT 1,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at          TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.report_execution_history (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id           UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  scheduled_report_id UUID NOT NULL REFERENCES public.scheduled_reports (id) ON DELETE CASCADE,
  status              TEXT NOT NULL DEFAULT 'pending',
  executed_at         TIMESTAMPTZ,
  error_message       TEXT,
  version             INTEGER NOT NULL DEFAULT 1,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at          TIMESTAMPTZ
);

-- Enable RLS
DO $$
DECLARE
  t text;
BEGIN
  FOREACH t IN ARRAY ARRAY[
    'report_definitions', 'report_templates', 'report_exports', 'report_snapshots',
    'dashboard_layouts', 'dashboard_widgets', 'analytics_snapshots', 'kpi_snapshots',
    'scheduled_reports', 'report_execution_history'
  ]
  LOOP
    EXECUTE format('ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY', t);
  END LOOP;
END $$;

-- Tenant isolation policies
DO $$
DECLARE
  t text;
BEGIN
  FOREACH t IN ARRAY ARRAY[
    'report_definitions', 'report_templates', 'report_exports', 'report_snapshots',
    'dashboard_layouts', 'dashboard_widgets', 'analytics_snapshots', 'kpi_snapshots',
    'scheduled_reports', 'report_execution_history'
  ]
  LOOP
    EXECUTE format('DROP POLICY IF EXISTS %I_tenant_select ON public.%I', t, t);
    EXECUTE format('DROP POLICY IF EXISTS %I_tenant_insert ON public.%I', t, t);
    EXECUTE format('DROP POLICY IF EXISTS %I_tenant_update ON public.%I', t, t);
    EXECUTE format('DROP POLICY IF EXISTS %I_tenant_delete ON public.%I', t, t);

    EXECUTE format(
      'CREATE POLICY %I_tenant_select ON public.%I FOR SELECT USING (tenant_id = (auth.jwt() ->> ''tenant_id'')::uuid)',
      t, t
    );
    EXECUTE format(
      'CREATE POLICY %I_tenant_insert ON public.%I FOR INSERT WITH CHECK (tenant_id = (auth.jwt() ->> ''tenant_id'')::uuid)',
      t, t
    );
    EXECUTE format(
      'CREATE POLICY %I_tenant_update ON public.%I FOR UPDATE USING (tenant_id = (auth.jwt() ->> ''tenant_id'')::uuid) WITH CHECK (tenant_id = (auth.jwt() ->> ''tenant_id'')::uuid)',
      t, t
    );
    EXECUTE format(
      'CREATE POLICY %I_tenant_delete ON public.%I FOR DELETE USING (tenant_id = (auth.jwt() ->> ''tenant_id'')::uuid)',
      t, t
    );
  END LOOP;
END $$;
