-- Phase 15: Enterprise Integrations — connectors, webhooks, API keys, logs, import/export, OAuth, printers

CREATE TABLE IF NOT EXISTS public.integration_connectors (
  id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id               UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  name                    TEXT NOT NULL,
  connector_type          TEXT NOT NULL DEFAULT 'custom',
  status                  TEXT NOT NULL DEFAULT 'inactive',
  provider_key            TEXT,
  config                  JSONB NOT NULL DEFAULT '{}',
  is_enabled              BOOLEAN NOT NULL DEFAULT true,
  last_success_at         TIMESTAMPTZ,
  last_failure_at         TIMESTAMPTZ,
  consecutive_failures    INTEGER NOT NULL DEFAULT 0,
  rate_limit_per_minute   INTEGER NOT NULL DEFAULT 60,
  version                 INTEGER NOT NULL DEFAULT 1,
  created_at              TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at              TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at              TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS integration_connectors_tenant_idx ON public.integration_connectors (tenant_id) WHERE deleted_at IS NULL;

CREATE TABLE IF NOT EXISTS public.webhooks (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id         UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  name              TEXT NOT NULL,
  url               TEXT NOT NULL,
  status            TEXT NOT NULL DEFAULT 'inactive',
  events            JSONB NOT NULL DEFAULT '[]',
  secret_hash       TEXT,
  failure_count     INTEGER NOT NULL DEFAULT 0,
  last_triggered_at TIMESTAMPTZ,
  version           INTEGER NOT NULL DEFAULT 1,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at        TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS webhooks_tenant_idx ON public.webhooks (tenant_id) WHERE deleted_at IS NULL;

CREATE TABLE IF NOT EXISTS public.api_keys (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id     UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  name          TEXT NOT NULL,
  key_prefix    TEXT NOT NULL,
  status        TEXT NOT NULL DEFAULT 'active',
  scopes        JSONB NOT NULL DEFAULT '[]',
  expires_at    TIMESTAMPTZ,
  last_used_at  TIMESTAMPTZ,
  created_by    UUID,
  version       INTEGER NOT NULL DEFAULT 1,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at    TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS api_keys_tenant_idx ON public.api_keys (tenant_id) WHERE deleted_at IS NULL;

CREATE TABLE IF NOT EXISTS public.integration_logs (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id     UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  level         TEXT NOT NULL DEFAULT 'info',
  message       TEXT NOT NULL,
  connector_id  UUID REFERENCES public.integration_connectors (id) ON DELETE SET NULL,
  webhook_id    UUID REFERENCES public.webhooks (id) ON DELETE SET NULL,
  event_type    TEXT,
  metadata      JSONB NOT NULL DEFAULT '{}',
  version       INTEGER NOT NULL DEFAULT 1,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at    TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS integration_logs_tenant_idx ON public.integration_logs (tenant_id, created_at DESC) WHERE deleted_at IS NULL;

CREATE TABLE IF NOT EXISTS public.import_jobs (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  entity_type     TEXT NOT NULL,
  status          TEXT NOT NULL DEFAULT 'pending',
  file_name       TEXT,
  total_rows      INTEGER NOT NULL DEFAULT 0,
  imported_rows   INTEGER NOT NULL DEFAULT 0,
  failed_rows     INTEGER NOT NULL DEFAULT 0,
  errors          JSONB NOT NULL DEFAULT '[]',
  created_by      UUID,
  completed_at    TIMESTAMPTZ,
  version         INTEGER NOT NULL DEFAULT 1,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at      TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS import_jobs_tenant_idx ON public.import_jobs (tenant_id) WHERE deleted_at IS NULL;

CREATE TABLE IF NOT EXISTS public.export_jobs (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id     UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  entity_type   TEXT NOT NULL,
  status        TEXT NOT NULL DEFAULT 'pending',
  format        TEXT NOT NULL DEFAULT 'csv',
  file_name     TEXT,
  row_count     INTEGER NOT NULL DEFAULT 0,
  created_by    UUID,
  completed_at  TIMESTAMPTZ,
  version       INTEGER NOT NULL DEFAULT 1,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at    TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS export_jobs_tenant_idx ON public.export_jobs (tenant_id) WHERE deleted_at IS NULL;

CREATE TABLE IF NOT EXISTS public.oauth_connections (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  provider        TEXT NOT NULL,
  status          TEXT NOT NULL DEFAULT 'pending',
  account_label   TEXT,
  scopes          JSONB NOT NULL DEFAULT '[]',
  expires_at      TIMESTAMPTZ,
  connector_id    UUID REFERENCES public.integration_connectors (id) ON DELETE SET NULL,
  version         INTEGER NOT NULL DEFAULT 1,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at      TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS oauth_connections_tenant_provider_idx ON public.oauth_connections (tenant_id, provider) WHERE deleted_at IS NULL;

CREATE TABLE IF NOT EXISTS public.printer_profiles (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  name            TEXT NOT NULL,
  connection_type TEXT NOT NULL DEFAULT 'network',
  address         TEXT,
  is_default      BOOLEAN NOT NULL DEFAULT false,
  paper_width_mm  INTEGER NOT NULL DEFAULT 80,
  config          JSONB NOT NULL DEFAULT '{}',
  version         INTEGER NOT NULL DEFAULT 1,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at      TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS printer_profiles_tenant_idx ON public.printer_profiles (tenant_id) WHERE deleted_at IS NULL;

DO $$
DECLARE t text;
BEGIN
  FOREACH t IN ARRAY ARRAY[
    'integration_connectors', 'webhooks', 'api_keys', 'integration_logs',
    'import_jobs', 'export_jobs', 'oauth_connections', 'printer_profiles'
  ]
  LOOP
    EXECUTE format('ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY', t);
  END LOOP;
END $$;

DO $$
DECLARE t text;
BEGIN
  FOREACH t IN ARRAY ARRAY[
    'integration_connectors', 'webhooks', 'api_keys', 'integration_logs',
    'import_jobs', 'export_jobs', 'oauth_connections', 'printer_profiles'
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
