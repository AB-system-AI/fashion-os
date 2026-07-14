-- Phase 14: Enterprise Automation — rules, workflows, scheduling, approvals, templates

CREATE TABLE IF NOT EXISTS public.automation_rules (
  id                    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id             UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  name                  TEXT NOT NULL,
  description           TEXT,
  status                TEXT NOT NULL DEFAULT 'draft',
  trigger_event         TEXT NOT NULL DEFAULT 'manual',
  trigger_entity_type   TEXT,
  condition_field       TEXT,
  condition_operator    TEXT,
  condition_value       TEXT,
  action_type           TEXT,
  action_parameters     JSONB NOT NULL DEFAULT '{}',
  priority              INTEGER NOT NULL DEFAULT 0,
  created_by            UUID,
  version               INTEGER NOT NULL DEFAULT 1,
  created_at            TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at            TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at            TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS automation_rules_tenant_status_idx ON public.automation_rules (tenant_id, status) WHERE deleted_at IS NULL;

CREATE TABLE IF NOT EXISTS public.automation_workflows (
  id                    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id             UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  name                  TEXT NOT NULL,
  description           TEXT,
  status                TEXT NOT NULL DEFAULT 'draft',
  trigger_event         TEXT NOT NULL DEFAULT 'manual',
  trigger_entity_type   TEXT,
  created_by            UUID,
  version               INTEGER NOT NULL DEFAULT 1,
  created_at            TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at            TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at            TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.workflow_steps (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  workflow_id     UUID NOT NULL REFERENCES public.automation_workflows (id) ON DELETE CASCADE,
  name            TEXT NOT NULL,
  step_type       TEXT NOT NULL DEFAULT 'action',
  step_order      INTEGER NOT NULL DEFAULT 0,
  config          JSONB NOT NULL DEFAULT '{}',
  required_role   TEXT,
  version         INTEGER NOT NULL DEFAULT 1,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at      TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS workflow_steps_workflow_idx ON public.workflow_steps (tenant_id, workflow_id) WHERE deleted_at IS NULL;

CREATE TABLE IF NOT EXISTS public.scheduled_jobs (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id         UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  name              TEXT NOT NULL,
  description       TEXT,
  schedule_type     TEXT NOT NULL DEFAULT 'once',
  cron_expression   TEXT,
  interval_seconds  INTEGER,
  run_at            TIMESTAMPTZ,
  timezone          TEXT NOT NULL DEFAULT 'UTC',
  status            TEXT NOT NULL DEFAULT 'pending',
  last_run_at       TIMESTAMPTZ,
  next_run_at       TIMESTAMPTZ,
  rule_id           UUID REFERENCES public.automation_rules (id) ON DELETE SET NULL,
  workflow_id       UUID REFERENCES public.automation_workflows (id) ON DELETE SET NULL,
  payload           JSONB NOT NULL DEFAULT '{}',
  created_by        UUID,
  version           INTEGER NOT NULL DEFAULT 1,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at        TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS scheduled_jobs_next_run_idx ON public.scheduled_jobs (tenant_id, next_run_at) WHERE deleted_at IS NULL;

CREATE TABLE IF NOT EXISTS public.job_queue (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id         UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  scheduled_job_id  UUID NOT NULL REFERENCES public.scheduled_jobs (id) ON DELETE CASCADE,
  status            TEXT NOT NULL DEFAULT 'queued',
  priority          INTEGER NOT NULL DEFAULT 0,
  attempts          INTEGER NOT NULL DEFAULT 0,
  max_attempts      INTEGER NOT NULL DEFAULT 3,
  scheduled_for     TIMESTAMPTZ,
  started_at        TIMESTAMPTZ,
  completed_at      TIMESTAMPTZ,
  error_message     TEXT,
  payload           JSONB NOT NULL DEFAULT '{}',
  version           INTEGER NOT NULL DEFAULT 1,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at        TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS job_queue_pending_idx ON public.job_queue (tenant_id, status) WHERE deleted_at IS NULL;

CREATE TABLE IF NOT EXISTS public.automation_executions (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id         UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  rule_id           UUID REFERENCES public.automation_rules (id) ON DELETE SET NULL,
  workflow_id       UUID REFERENCES public.automation_workflows (id) ON DELETE SET NULL,
  scheduled_job_id  UUID REFERENCES public.scheduled_jobs (id) ON DELETE SET NULL,
  status            TEXT NOT NULL DEFAULT 'pending',
  trigger_event     TEXT NOT NULL DEFAULT 'manual',
  entity_type       TEXT,
  entity_id         UUID,
  started_at        TIMESTAMPTZ,
  completed_at      TIMESTAMPTZ,
  error_message     TEXT,
  result            JSONB NOT NULL DEFAULT '{}',
  version           INTEGER NOT NULL DEFAULT 1,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at        TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS automation_executions_tenant_idx ON public.automation_executions (tenant_id, updated_at DESC) WHERE deleted_at IS NULL;

CREATE TABLE IF NOT EXISTS public.automation_logs (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  execution_id    UUID NOT NULL REFERENCES public.automation_executions (id) ON DELETE CASCADE,
  level           TEXT NOT NULL DEFAULT 'info',
  message         TEXT NOT NULL,
  metadata        JSONB NOT NULL DEFAULT '{}',
  version         INTEGER NOT NULL DEFAULT 1,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at      TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS automation_logs_execution_idx ON public.automation_logs (tenant_id, execution_id) WHERE deleted_at IS NULL;

CREATE TABLE IF NOT EXISTS public.approval_workflows (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  name            TEXT NOT NULL,
  description     TEXT,
  entity_type     TEXT,
  min_approvers   INTEGER NOT NULL DEFAULT 1,
  required_roles  JSONB NOT NULL DEFAULT '[]',
  is_active       BOOLEAN NOT NULL DEFAULT true,
  created_by      UUID,
  version         INTEGER NOT NULL DEFAULT 1,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at      TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.approval_requests (
  id                    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id             UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  approval_workflow_id  UUID NOT NULL REFERENCES public.approval_workflows (id) ON DELETE CASCADE,
  entity_type           TEXT,
  entity_id             UUID,
  status                TEXT NOT NULL DEFAULT 'pending',
  requested_by          UUID,
  approved_by           UUID,
  rejected_by           UUID,
  comment               TEXT,
  expires_at            TIMESTAMPTZ,
  resolved_at           TIMESTAMPTZ,
  version               INTEGER NOT NULL DEFAULT 1,
  created_at            TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at            TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at            TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS approval_requests_pending_idx ON public.approval_requests (tenant_id, status) WHERE deleted_at IS NULL;

CREATE TABLE IF NOT EXISTS public.document_templates (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  name            TEXT NOT NULL,
  description     TEXT,
  template_type   TEXT NOT NULL DEFAULT 'document',
  subject         TEXT,
  body            TEXT,
  variables       JSONB NOT NULL DEFAULT '[]',
  is_active       BOOLEAN NOT NULL DEFAULT true,
  created_by      UUID,
  version         INTEGER NOT NULL DEFAULT 1,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at      TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.automation_settings (
  id                            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id                     UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  enable_rules                  BOOLEAN NOT NULL DEFAULT true,
  enable_workflows              BOOLEAN NOT NULL DEFAULT true,
  enable_scheduler              BOOLEAN NOT NULL DEFAULT true,
  enable_ai_assistant           BOOLEAN NOT NULL DEFAULT false,
  max_concurrent_jobs           INTEGER NOT NULL DEFAULT 5,
  default_approval_expiry_hours INTEGER NOT NULL DEFAULT 72,
  log_retention_days            INTEGER NOT NULL DEFAULT 90,
  version                       INTEGER NOT NULL DEFAULT 1,
  created_at                    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at                    TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at                    TIMESTAMPTZ
);

CREATE UNIQUE INDEX IF NOT EXISTS automation_settings_tenant_uidx ON public.automation_settings (tenant_id) WHERE deleted_at IS NULL;

DO $$
DECLARE t text;
BEGIN
  FOREACH t IN ARRAY ARRAY[
    'automation_rules', 'automation_workflows', 'workflow_steps', 'scheduled_jobs', 'job_queue',
    'automation_executions', 'automation_logs', 'approval_workflows', 'approval_requests',
    'document_templates', 'automation_settings'
  ]
  LOOP
    EXECUTE format('ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY', t);
  END LOOP;
END $$;

DO $$
DECLARE t text;
BEGIN
  FOREACH t IN ARRAY ARRAY[
    'automation_rules', 'automation_workflows', 'workflow_steps', 'scheduled_jobs', 'job_queue',
    'automation_executions', 'automation_logs', 'approval_workflows', 'approval_requests',
    'document_templates', 'automation_settings'
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
