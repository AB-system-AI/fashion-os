-- Phase 16 COMPLETE: Workflow designer, executions, notifications queue, scheduler

CREATE TABLE IF NOT EXISTS public.wf_templates (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  name            TEXT NOT NULL,
  description     TEXT,
  category_id     UUID,
  status          TEXT NOT NULL DEFAULT 'draft',
  created_by      UUID,
  version         INTEGER NOT NULL DEFAULT 1,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at      TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS wf_templates_tenant_idx ON public.wf_templates (tenant_id, status) WHERE deleted_at IS NULL;

CREATE TABLE IF NOT EXISTS public.wf_template_versions (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  template_id     UUID NOT NULL REFERENCES public.wf_templates (id) ON DELETE CASCADE,
  version_number  INTEGER NOT NULL DEFAULT 1,
  status          TEXT NOT NULL DEFAULT 'draft',
  steps           JSONB NOT NULL DEFAULT '[]',
  variables       JSONB NOT NULL DEFAULT '[]',
  conditions      JSONB NOT NULL DEFAULT '[]',
  published_at    TIMESTAMPTZ,
  archived_at     TIMESTAMPTZ,
  version         INTEGER NOT NULL DEFAULT 1,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at      TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS wf_template_versions_template_idx ON public.wf_template_versions (tenant_id, template_id, version_number) WHERE deleted_at IS NULL;

CREATE TABLE IF NOT EXISTS public.wf_categories (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  name            TEXT NOT NULL,
  description     TEXT,
  color           TEXT,
  version         INTEGER NOT NULL DEFAULT 1,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at      TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS wf_categories_tenant_idx ON public.wf_categories (tenant_id) WHERE deleted_at IS NULL;

CREATE TABLE IF NOT EXISTS public.wf_variables (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  template_id     UUID NOT NULL REFERENCES public.wf_templates (id) ON DELETE CASCADE,
  version_id      UUID REFERENCES public.wf_template_versions (id) ON DELETE CASCADE,
  key             TEXT NOT NULL,
  label           TEXT NOT NULL,
  default_value   JSONB,
  variable_type   TEXT NOT NULL DEFAULT 'string',
  is_required     BOOLEAN NOT NULL DEFAULT false,
  version         INTEGER NOT NULL DEFAULT 1,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at      TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS wf_variables_template_idx ON public.wf_variables (tenant_id, template_id) WHERE deleted_at IS NULL;

CREATE TABLE IF NOT EXISTS public.wf_executions (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id           UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  template_id         UUID NOT NULL REFERENCES public.wf_templates (id) ON DELETE RESTRICT,
  version_id          UUID NOT NULL REFERENCES public.wf_template_versions (id) ON DELETE RESTRICT,
  status              TEXT NOT NULL DEFAULT 'pending',
  current_step_index  INTEGER NOT NULL DEFAULT 0,
  context             JSONB NOT NULL DEFAULT '{}',
  started_at          TIMESTAMPTZ,
  completed_at        TIMESTAMPTZ,
  error_message       TEXT,
  version             INTEGER NOT NULL DEFAULT 1,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at          TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS wf_executions_tenant_template_idx ON public.wf_executions (tenant_id, template_id) WHERE deleted_at IS NULL;

CREATE TABLE IF NOT EXISTS public.wf_execution_logs (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  execution_id    UUID NOT NULL REFERENCES public.wf_executions (id) ON DELETE CASCADE,
  step_index      INTEGER,
  level           TEXT NOT NULL DEFAULT 'info',
  message         TEXT NOT NULL,
  data            JSONB NOT NULL DEFAULT '{}',
  occurred_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
  version         INTEGER NOT NULL DEFAULT 1,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at      TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS wf_execution_logs_execution_idx ON public.wf_execution_logs (tenant_id, execution_id) WHERE deleted_at IS NULL;

CREATE TABLE IF NOT EXISTS public.wf_statistics (
  id                    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id             UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  template_id           UUID NOT NULL REFERENCES public.wf_templates (id) ON DELETE CASCADE,
  period_start          TIMESTAMPTZ NOT NULL,
  period_end            TIMESTAMPTZ NOT NULL,
  total_executions      INTEGER NOT NULL DEFAULT 0,
  completed_count       INTEGER NOT NULL DEFAULT 0,
  failed_count          INTEGER NOT NULL DEFAULT 0,
  avg_duration_seconds  NUMERIC NOT NULL DEFAULT 0,
  version               INTEGER NOT NULL DEFAULT 1,
  created_at            TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at            TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at            TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS wf_statistics_template_period_idx ON public.wf_statistics (tenant_id, template_id, period_start) WHERE deleted_at IS NULL;

CREATE TABLE IF NOT EXISTS public.notification_queue (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  recipient_id    UUID NOT NULL,
  title           TEXT NOT NULL,
  body            TEXT NOT NULL,
  channel         TEXT NOT NULL DEFAULT 'inApp',
  status          TEXT NOT NULL DEFAULT 'pending',
  priority        TEXT NOT NULL DEFAULT 'normal',
  scheduled_at    TIMESTAMPTZ,
  attempt_count   INTEGER NOT NULL DEFAULT 0,
  max_attempts    INTEGER NOT NULL DEFAULT 3,
  last_error      TEXT,
  data            JSONB NOT NULL DEFAULT '{}',
  version         INTEGER NOT NULL DEFAULT 1,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at      TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS notification_queue_pending_idx ON public.notification_queue (tenant_id, status) WHERE deleted_at IS NULL;

CREATE TABLE IF NOT EXISTS public.notification_dead_letter (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id           UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  original_queue_id   UUID NOT NULL,
  reason              TEXT NOT NULL,
  payload             JSONB NOT NULL DEFAULT '{}',
  version             INTEGER NOT NULL DEFAULT 1,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at          TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS notification_dead_letter_tenant_idx ON public.notification_dead_letter (tenant_id) WHERE deleted_at IS NULL;

CREATE TABLE IF NOT EXISTS public.notification_preferences (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id         UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  user_id           UUID NOT NULL,
  enabled_channels  JSONB NOT NULL DEFAULT '{}',
  quiet_hours       JSONB,
  version           INTEGER NOT NULL DEFAULT 1,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at        TIMESTAMPTZ
);

CREATE UNIQUE INDEX IF NOT EXISTS notification_preferences_user_uidx ON public.notification_preferences (tenant_id, user_id) WHERE deleted_at IS NULL;

CREATE TABLE IF NOT EXISTS public.scheduler_jobs (
  id                    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id             UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  name                  TEXT NOT NULL,
  job_type              TEXT NOT NULL DEFAULT 'workflow',
  schedule_type         TEXT NOT NULL DEFAULT 'once',
  status                TEXT NOT NULL DEFAULT 'pending',
  cron_expression       TEXT,
  interval_seconds      INTEGER,
  run_at                TIMESTAMPTZ,
  next_run_at           TIMESTAMPTZ,
  last_run_at           TIMESTAMPTZ,
  retry_count           INTEGER NOT NULL DEFAULT 0,
  max_retries           INTEGER NOT NULL DEFAULT 3,
  retry_delay_seconds   INTEGER NOT NULL DEFAULT 60,
  payload               JSONB NOT NULL DEFAULT '{}',
  version               INTEGER NOT NULL DEFAULT 1,
  created_at            TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at            TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at            TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS scheduler_jobs_due_idx ON public.scheduler_jobs (tenant_id, status, next_run_at) WHERE deleted_at IS NULL;

CREATE TABLE IF NOT EXISTS public.scheduler_execution_logs (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  job_id          UUID NOT NULL REFERENCES public.scheduler_jobs (id) ON DELETE CASCADE,
  started_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  completed_at    TIMESTAMPTZ,
  success         BOOLEAN NOT NULL DEFAULT true,
  error_message   TEXT,
  version         INTEGER NOT NULL DEFAULT 1,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at      TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS scheduler_execution_logs_job_idx ON public.scheduler_execution_logs (tenant_id, job_id) WHERE deleted_at IS NULL;

DO $$
DECLARE t text;
BEGIN
  FOREACH t IN ARRAY ARRAY[
    'wf_templates', 'wf_template_versions', 'wf_categories', 'wf_variables',
    'wf_executions', 'wf_execution_logs', 'wf_statistics',
    'notification_queue', 'notification_dead_letter', 'notification_preferences',
    'scheduler_jobs', 'scheduler_execution_logs'
  ]
  LOOP
    EXECUTE format('ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY', t);
  END LOOP;
END $$;

DO $$
DECLARE t text;
BEGIN
  FOREACH t IN ARRAY ARRAY[
    'wf_templates', 'wf_template_versions', 'wf_categories', 'wf_variables',
    'wf_executions', 'wf_execution_logs', 'wf_statistics',
    'notification_queue', 'notification_dead_letter', 'notification_preferences',
    'scheduler_jobs', 'scheduler_execution_logs'
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
