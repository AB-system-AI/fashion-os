-- Phase 17: Enterprise Administration — org hierarchy, role templates, user groups, settings, usage metrics

CREATE TABLE IF NOT EXISTS public.admin_companies (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  name            TEXT NOT NULL,
  code            TEXT,
  legal_name      TEXT,
  tax_id          TEXT,
  status          TEXT NOT NULL DEFAULT 'active',
  version         INTEGER NOT NULL DEFAULT 1,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at      TIMESTAMPTZ
);

CREATE UNIQUE INDEX IF NOT EXISTS admin_companies_tenant_code_uidx ON public.admin_companies (tenant_id, code) WHERE deleted_at IS NULL AND code IS NOT NULL;

CREATE TABLE IF NOT EXISTS public.admin_branches (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  company_id      UUID NOT NULL REFERENCES public.admin_companies (id) ON DELETE CASCADE,
  name            TEXT NOT NULL,
  code            TEXT,
  address         TEXT,
  status          TEXT NOT NULL DEFAULT 'active',
  version         INTEGER NOT NULL DEFAULT 1,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at      TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.admin_stores (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  branch_id       UUID NOT NULL REFERENCES public.admin_branches (id) ON DELETE CASCADE,
  name            TEXT NOT NULL,
  code            TEXT,
  status          TEXT NOT NULL DEFAULT 'active',
  version         INTEGER NOT NULL DEFAULT 1,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at      TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.admin_warehouses (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  store_id        UUID REFERENCES public.admin_stores (id) ON DELETE SET NULL,
  name            TEXT NOT NULL,
  code            TEXT,
  status          TEXT NOT NULL DEFAULT 'active',
  version         INTEGER NOT NULL DEFAULT 1,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at      TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.admin_departments (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  company_id      UUID REFERENCES public.admin_companies (id) ON DELETE SET NULL,
  name            TEXT NOT NULL,
  manager_id      UUID,
  status          TEXT NOT NULL DEFAULT 'active',
  version         INTEGER NOT NULL DEFAULT 1,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at      TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.admin_teams (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  department_id   UUID REFERENCES public.admin_departments (id) ON DELETE SET NULL,
  name            TEXT NOT NULL,
  lead_id         UUID,
  status          TEXT NOT NULL DEFAULT 'active',
  version         INTEGER NOT NULL DEFAULT 1,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at      TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.admin_business_units (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  company_id      UUID REFERENCES public.admin_companies (id) ON DELETE SET NULL,
  name            TEXT NOT NULL,
  code            TEXT,
  status          TEXT NOT NULL DEFAULT 'active',
  version         INTEGER NOT NULL DEFAULT 1,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at      TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.admin_cost_centers (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id         UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  business_unit_id  UUID REFERENCES public.admin_business_units (id) ON DELETE SET NULL,
  name              TEXT NOT NULL,
  code              TEXT,
  status            TEXT NOT NULL DEFAULT 'active',
  version           INTEGER NOT NULL DEFAULT 1,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at        TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.admin_users (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  email           TEXT NOT NULL,
  display_name    TEXT NOT NULL,
  employee_id     UUID,
  role_ids        JSONB NOT NULL DEFAULT '[]',
  status          TEXT NOT NULL DEFAULT 'active',
  last_login_at   TIMESTAMPTZ,
  version         INTEGER NOT NULL DEFAULT 1,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at      TIMESTAMPTZ
);

CREATE UNIQUE INDEX IF NOT EXISTS admin_users_tenant_email_uidx ON public.admin_users (tenant_id, email) WHERE deleted_at IS NULL;

CREATE TABLE IF NOT EXISTS public.admin_role_templates (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id         UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  name              TEXT NOT NULL,
  description       TEXT,
  permission_codes  JSONB NOT NULL DEFAULT '[]',
  is_system         BOOLEAN NOT NULL DEFAULT false,
  version           INTEGER NOT NULL DEFAULT 1,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at        TIMESTAMPTZ
);

CREATE UNIQUE INDEX IF NOT EXISTS admin_role_templates_tenant_name_uidx ON public.admin_role_templates (tenant_id, name) WHERE deleted_at IS NULL;

CREATE TABLE IF NOT EXISTS public.admin_user_groups (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id         UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  name              TEXT NOT NULL,
  description       TEXT,
  member_ids        JSONB NOT NULL DEFAULT '[]',
  role_template_id  UUID REFERENCES public.admin_role_templates (id) ON DELETE SET NULL,
  version           INTEGER NOT NULL DEFAULT 1,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at        TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.admin_permission_assignments (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id         UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  subject_id        UUID NOT NULL,
  subject_type      TEXT NOT NULL DEFAULT 'user',
  permission_codes  JSONB NOT NULL DEFAULT '[]',
  version           INTEGER NOT NULL DEFAULT 1,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at        TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.admin_tenant_settings (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  scope           TEXT NOT NULL DEFAULT 'tenant',
  values          JSONB NOT NULL DEFAULT '{}',
  version         INTEGER NOT NULL DEFAULT 1,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at      TIMESTAMPTZ
);

CREATE UNIQUE INDEX IF NOT EXISTS admin_tenant_settings_scope_uidx ON public.admin_tenant_settings (tenant_id, scope) WHERE deleted_at IS NULL;

CREATE TABLE IF NOT EXISTS public.admin_tenant_branding (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  logo_url        TEXT,
  primary_color   TEXT,
  accent_color    TEXT,
  company_name    TEXT,
  version         INTEGER NOT NULL DEFAULT 1,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at      TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.admin_enterprise_config (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  config          JSONB NOT NULL DEFAULT '{}',
  version         INTEGER NOT NULL DEFAULT 1,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at      TIMESTAMPTZ
);

CREATE UNIQUE INDEX IF NOT EXISTS admin_enterprise_config_tenant_uidx ON public.admin_enterprise_config (tenant_id) WHERE deleted_at IS NULL;

CREATE TABLE IF NOT EXISTS public.admin_license_records (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  plan_id         UUID NOT NULL,
  status          TEXT NOT NULL DEFAULT 'trial',
  expires_at      TIMESTAMPTZ,
  seats           INTEGER NOT NULL DEFAULT 10,
  version         INTEGER NOT NULL DEFAULT 1,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at      TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.admin_subscription_plans (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id           UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  name                TEXT NOT NULL,
  tier                TEXT NOT NULL DEFAULT 'starter',
  max_users           INTEGER NOT NULL DEFAULT 10,
  max_storage_mb      INTEGER NOT NULL DEFAULT 1024,
  max_api_calls_daily INTEGER NOT NULL DEFAULT 10000,
  version             INTEGER NOT NULL DEFAULT 1,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at          TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.admin_usage_metrics (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  captured_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
  active_users    INTEGER NOT NULL DEFAULT 0,
  storage_used_mb NUMERIC(18, 4) NOT NULL DEFAULT 0,
  api_calls       INTEGER NOT NULL DEFAULT 0,
  version         INTEGER NOT NULL DEFAULT 1,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at      TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.admin_storage_usage (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  bucket          TEXT,
  used_mb         NUMERIC(18, 4) NOT NULL DEFAULT 0,
  limit_mb        NUMERIC(18, 4) NOT NULL DEFAULT 1024,
  version         INTEGER NOT NULL DEFAULT 1,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at      TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.admin_api_usage (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  endpoint        TEXT NOT NULL,
  call_count      INTEGER NOT NULL DEFAULT 0,
  period_start    TIMESTAMPTZ NOT NULL DEFAULT now(),
  period_end      TIMESTAMPTZ,
  version         INTEGER NOT NULL DEFAULT 1,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at      TIMESTAMPTZ
);

DO $$
DECLARE t text;
BEGIN
  FOREACH t IN ARRAY ARRAY[
    'admin_companies', 'admin_branches', 'admin_stores', 'admin_warehouses',
    'admin_departments', 'admin_teams', 'admin_business_units', 'admin_cost_centers',
    'admin_users', 'admin_role_templates', 'admin_user_groups', 'admin_permission_assignments',
    'admin_tenant_settings', 'admin_tenant_branding', 'admin_enterprise_config',
    'admin_license_records', 'admin_subscription_plans', 'admin_usage_metrics',
    'admin_storage_usage', 'admin_api_usage'
  ]
  LOOP
    EXECUTE format('ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY', t);
  END LOOP;
END $$;

DO $$
DECLARE t text;
BEGIN
  FOREACH t IN ARRAY ARRAY[
    'admin_companies', 'admin_branches', 'admin_stores', 'admin_warehouses',
    'admin_departments', 'admin_teams', 'admin_business_units', 'admin_cost_centers',
    'admin_users', 'admin_role_templates', 'admin_user_groups', 'admin_permission_assignments',
    'admin_tenant_settings', 'admin_tenant_branding', 'admin_enterprise_config',
    'admin_license_records', 'admin_subscription_plans', 'admin_usage_metrics',
    'admin_storage_usage', 'admin_api_usage'
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
