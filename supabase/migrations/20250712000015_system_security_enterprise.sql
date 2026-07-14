-- Phase 16: Enterprise System Administration, Security & Monitoring

CREATE TABLE IF NOT EXISTS public.feature_flags (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id     UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  key           TEXT NOT NULL,
  scope         TEXT NOT NULL DEFAULT 'tenant',
  enabled       BOOLEAN NOT NULL DEFAULT false,
  variant       TEXT,
  description   TEXT,
  payload       JSONB NOT NULL DEFAULT '{}',
  version       INTEGER NOT NULL DEFAULT 1,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at    TIMESTAMPTZ
);

CREATE UNIQUE INDEX IF NOT EXISTS feature_flags_tenant_key_uidx ON public.feature_flags (tenant_id, key) WHERE deleted_at IS NULL;

CREATE TABLE IF NOT EXISTS public.system_audit_entries (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id     UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  store_id      UUID,
  employee_id   UUID,
  device_id     TEXT,
  action        TEXT NOT NULL,
  entity_type   TEXT NOT NULL,
  entity_id     UUID,
  old_value     TEXT,
  new_value     TEXT,
  metadata      JSONB NOT NULL DEFAULT '{}',
  synced        BOOLEAN NOT NULL DEFAULT false,
  version       INTEGER NOT NULL DEFAULT 1,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at    TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS system_audit_entries_entity_idx ON public.system_audit_entries (tenant_id, entity_type, entity_id) WHERE deleted_at IS NULL;

CREATE TABLE IF NOT EXISTS public.role_definitions (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id     UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  code          TEXT NOT NULL,
  name          TEXT NOT NULL,
  description   TEXT,
  permissions   JSONB NOT NULL DEFAULT '[]',
  is_system     BOOLEAN NOT NULL DEFAULT false,
  version       INTEGER NOT NULL DEFAULT 1,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at    TIMESTAMPTZ
);

CREATE UNIQUE INDEX IF NOT EXISTS role_definitions_tenant_code_uidx ON public.role_definitions (tenant_id, code) WHERE deleted_at IS NULL;

CREATE TABLE IF NOT EXISTS public.permission_assignments (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id         UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  subject_type      TEXT NOT NULL,
  subject_id        UUID NOT NULL,
  permission_code   TEXT NOT NULL,
  granted_by        UUID,
  expires_at        TIMESTAMPTZ,
  version           INTEGER NOT NULL DEFAULT 1,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at        TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS permission_assignments_subject_idx ON public.permission_assignments (tenant_id, subject_type, subject_id) WHERE deleted_at IS NULL;

CREATE TABLE IF NOT EXISTS public.system_health_snapshots (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id           UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  captured_at         TIMESTAMPTZ NOT NULL DEFAULT now(),
  status              TEXT NOT NULL DEFAULT 'unknown',
  cpu_percent         NUMERIC(6, 2) NOT NULL DEFAULT 0,
  memory_mb           NUMERIC(12, 2) NOT NULL DEFAULT 0,
  disk_percent        NUMERIC(6, 2) NOT NULL DEFAULT 0,
  active_connections  INTEGER NOT NULL DEFAULT 0,
  details             JSONB NOT NULL DEFAULT '{}',
  version             INTEGER NOT NULL DEFAULT 1,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at          TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.error_log_entries (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id     UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  message       TEXT NOT NULL,
  severity      TEXT NOT NULL DEFAULT 'error',
  source        TEXT,
  stack_trace   TEXT,
  context       JSONB NOT NULL DEFAULT '{}',
  occurred_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  resolved      BOOLEAN NOT NULL DEFAULT false,
  version       INTEGER NOT NULL DEFAULT 1,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at    TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.background_job_status (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id     UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  job_name      TEXT NOT NULL,
  status        TEXT NOT NULL DEFAULT 'pending',
  last_run_at   TIMESTAMPTZ,
  next_run_at   TIMESTAMPTZ,
  last_error    TEXT,
  run_count     INTEGER NOT NULL DEFAULT 0,
  version       INTEGER NOT NULL DEFAULT 1,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at    TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.sync_monitor_snapshots (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id         UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  captured_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
  pending_count     INTEGER NOT NULL DEFAULT 0,
  failed_count      INTEGER NOT NULL DEFAULT 0,
  processing_count  INTEGER NOT NULL DEFAULT 0,
  last_sync_at      TIMESTAMPTZ,
  engine_state      TEXT NOT NULL DEFAULT 'idle',
  version           INTEGER NOT NULL DEFAULT 1,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at        TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.storage_usage_snapshots (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id     UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  captured_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  database_mb   NUMERIC(12, 2) NOT NULL DEFAULT 0,
  media_mb      NUMERIC(12, 2) NOT NULL DEFAULT 0,
  cache_mb      NUMERIC(12, 2) NOT NULL DEFAULT 0,
  total_mb      NUMERIC(12, 2) NOT NULL DEFAULT 0,
  version       INTEGER NOT NULL DEFAULT 1,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at    TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.license_records (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id     UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  license_key   TEXT NOT NULL,
  status        TEXT NOT NULL DEFAULT 'unknown',
  plan_code     TEXT,
  valid_from    TIMESTAMPTZ,
  valid_until   TIMESTAMPTZ,
  max_users     INTEGER NOT NULL DEFAULT 0,
  max_stores    INTEGER NOT NULL DEFAULT 0,
  features      JSONB NOT NULL DEFAULT '[]',
  version       INTEGER NOT NULL DEFAULT 1,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at    TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.subscription_records (
  id                    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id             UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  plan_code             TEXT NOT NULL,
  status                TEXT NOT NULL DEFAULT 'active',
  billing_cycle         TEXT,
  current_period_start  TIMESTAMPTZ,
  current_period_end    TIMESTAMPTZ,
  cancel_at             TIMESTAMPTZ,
  external_id           TEXT,
  version               INTEGER NOT NULL DEFAULT 1,
  created_at            TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at            TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at            TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.environment_settings (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id     UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  key           TEXT NOT NULL,
  value         TEXT NOT NULL DEFAULT '',
  environment   TEXT NOT NULL DEFAULT 'production',
  description   TEXT,
  is_secret     BOOLEAN NOT NULL DEFAULT false,
  version       INTEGER NOT NULL DEFAULT 1,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at    TIMESTAMPTZ
);

CREATE UNIQUE INDEX IF NOT EXISTS environment_settings_tenant_key_uidx ON public.environment_settings (tenant_id, key, environment) WHERE deleted_at IS NULL;

CREATE TABLE IF NOT EXISTS public.security_sessions (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id         UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  user_id           UUID NOT NULL,
  device_id         TEXT,
  ip_address        TEXT,
  user_agent        TEXT,
  status            TEXT NOT NULL DEFAULT 'active',
  last_activity_at  TIMESTAMPTZ,
  expires_at        TIMESTAMPTZ,
  version           INTEGER NOT NULL DEFAULT 1,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at        TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.device_registrations (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  device_name     TEXT NOT NULL,
  platform        TEXT,
  os_version      TEXT,
  app_version     TEXT,
  trust_level     TEXT NOT NULL DEFAULT 'unknown',
  last_seen_at    TIMESTAMPTZ,
  registered_by   UUID,
  version         INTEGER NOT NULL DEFAULT 1,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at      TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.login_history_entries (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  user_id         UUID NOT NULL,
  success         BOOLEAN NOT NULL DEFAULT true,
  ip_address      TEXT,
  device_id       TEXT,
  failure_reason  TEXT,
  occurred_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
  version         INTEGER NOT NULL DEFAULT 1,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at      TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.maintenance_modes (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id         UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  active            BOOLEAN NOT NULL DEFAULT false,
  scope             TEXT NOT NULL DEFAULT 'tenant',
  message           TEXT,
  scheduled_start   TIMESTAMPTZ,
  scheduled_end     TIMESTAMPTZ,
  affected_modules  JSONB NOT NULL DEFAULT '[]',
  version           INTEGER NOT NULL DEFAULT 1,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at        TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.system_configurations (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id     UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  settings      JSONB NOT NULL DEFAULT '{}',
  updated_by    UUID,
  version       INTEGER NOT NULL DEFAULT 1,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at    TIMESTAMPTZ
);

CREATE UNIQUE INDEX IF NOT EXISTS system_configurations_tenant_uidx ON public.system_configurations (tenant_id) WHERE deleted_at IS NULL;

CREATE TABLE IF NOT EXISTS public.release_notes (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id     UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  app_version   TEXT NOT NULL,
  title         TEXT NOT NULL,
  body          TEXT NOT NULL DEFAULT '',
  is_published  BOOLEAN NOT NULL DEFAULT true,
  tags          JSONB NOT NULL DEFAULT '[]',
  published_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  version       INTEGER NOT NULL DEFAULT 1,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at    TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.migration_history_entries (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  migration_name  TEXT NOT NULL,
  status          TEXT NOT NULL DEFAULT 'applied',
  applied_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  duration_ms     INTEGER NOT NULL DEFAULT 0,
  error_message   TEXT,
  version         INTEGER NOT NULL DEFAULT 1,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at      TIMESTAMPTZ
);

DO $$
DECLARE t text;
BEGIN
  FOREACH t IN ARRAY ARRAY[
    'feature_flags', 'system_audit_entries', 'role_definitions', 'permission_assignments',
    'system_health_snapshots', 'error_log_entries', 'background_job_status', 'sync_monitor_snapshots',
    'storage_usage_snapshots', 'license_records', 'subscription_records', 'environment_settings',
    'security_sessions', 'device_registrations', 'login_history_entries', 'maintenance_modes',
    'system_configurations', 'release_notes', 'migration_history_entries'
  ]
  LOOP
    EXECUTE format('ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY', t);
  END LOOP;
END $$;

DO $$
DECLARE t text;
BEGIN
  FOREACH t IN ARRAY ARRAY[
    'feature_flags', 'system_audit_entries', 'role_definitions', 'permission_assignments',
    'system_health_snapshots', 'error_log_entries', 'background_job_status', 'sync_monitor_snapshots',
    'storage_usage_snapshots', 'license_records', 'subscription_records', 'environment_settings',
    'security_sessions', 'device_registrations', 'login_history_entries', 'maintenance_modes',
    'system_configurations', 'release_notes', 'migration_history_entries'
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
