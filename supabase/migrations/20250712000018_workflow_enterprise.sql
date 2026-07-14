-- Phase 16 PARTIAL: Enterprise Workflow, Approvals & Notifications

CREATE TABLE IF NOT EXISTS public.wf_definitions (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  name            TEXT NOT NULL,
  description     TEXT,
  workflow_type   TEXT NOT NULL DEFAULT 'approval',
  status          TEXT NOT NULL DEFAULT 'draft',
  steps           JSONB NOT NULL DEFAULT '[]',
  created_by      UUID,
  version         INTEGER NOT NULL DEFAULT 1,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at      TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS wf_definitions_tenant_status_idx ON public.wf_definitions (tenant_id, status) WHERE deleted_at IS NULL;

CREATE TABLE IF NOT EXISTS public.wf_instances (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id           UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  definition_id       UUID NOT NULL REFERENCES public.wf_definitions (id) ON DELETE CASCADE,
  entity_id           TEXT NOT NULL,
  status              TEXT NOT NULL DEFAULT 'pending',
  current_step_index  INTEGER NOT NULL DEFAULT 0,
  started_at          TIMESTAMPTZ,
  completed_at        TIMESTAMPTZ,
  metadata            JSONB NOT NULL DEFAULT '{}',
  version             INTEGER NOT NULL DEFAULT 1,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at          TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS wf_instances_tenant_entity_idx ON public.wf_instances (tenant_id, entity_id) WHERE deleted_at IS NULL;

CREATE TABLE IF NOT EXISTS public.wf_approval_templates (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  name            TEXT NOT NULL,
  description     TEXT,
  entity_type     TEXT,
  is_active       BOOLEAN NOT NULL DEFAULT true,
  min_approvers   INTEGER NOT NULL DEFAULT 1,
  created_by      UUID,
  version         INTEGER NOT NULL DEFAULT 1,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at      TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS wf_approval_templates_tenant_idx ON public.wf_approval_templates (tenant_id, is_active) WHERE deleted_at IS NULL;

CREATE TABLE IF NOT EXISTS public.wf_approval_matrices (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  template_id     UUID NOT NULL REFERENCES public.wf_approval_templates (id) ON DELETE CASCADE,
  step_order      INTEGER NOT NULL DEFAULT 0,
  required_role   TEXT NOT NULL,
  min_amount      NUMERIC,
  max_amount      NUMERIC,
  is_optional     BOOLEAN NOT NULL DEFAULT false,
  version         INTEGER NOT NULL DEFAULT 1,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at      TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS wf_approval_matrices_template_idx ON public.wf_approval_matrices (tenant_id, template_id) WHERE deleted_at IS NULL;

CREATE TABLE IF NOT EXISTS public.wf_approval_requests (
  id                    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id             UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  template_id           UUID NOT NULL REFERENCES public.wf_approval_templates (id) ON DELETE RESTRICT,
  workflow_instance_id  UUID REFERENCES public.wf_instances (id) ON DELETE SET NULL,
  entity_type           TEXT,
  entity_id             TEXT,
  status                TEXT NOT NULL DEFAULT 'pending',
  current_step_index    INTEGER NOT NULL DEFAULT 0,
  requested_by          UUID,
  assigned_to           UUID,
  comment               TEXT,
  amount                NUMERIC,
  expires_at            TIMESTAMPTZ,
  resolved_at           TIMESTAMPTZ,
  version               INTEGER NOT NULL DEFAULT 1,
  created_at            TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at            TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at            TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS wf_approval_requests_pending_idx ON public.wf_approval_requests (tenant_id, status) WHERE deleted_at IS NULL;

CREATE TABLE IF NOT EXISTS public.wf_approval_history (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  request_id      UUID NOT NULL REFERENCES public.wf_approval_requests (id) ON DELETE CASCADE,
  actor_id        UUID NOT NULL,
  decision        TEXT NOT NULL,
  occurred_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
  comment         TEXT,
  from_role       TEXT,
  to_user_id      UUID,
  version         INTEGER NOT NULL DEFAULT 1,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at      TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS wf_approval_history_request_idx ON public.wf_approval_history (tenant_id, request_id) WHERE deleted_at IS NULL;

CREATE TABLE IF NOT EXISTS public.wf_approval_delegations (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  from_user_id    UUID NOT NULL,
  to_user_id      UUID NOT NULL,
  effective_from  TIMESTAMPTZ NOT NULL DEFAULT now(),
  effective_until TIMESTAMPTZ,
  reason          TEXT,
  is_active       BOOLEAN NOT NULL DEFAULT true,
  version         INTEGER NOT NULL DEFAULT 1,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at      TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS wf_approval_delegations_active_idx ON public.wf_approval_delegations (tenant_id, from_user_id) WHERE deleted_at IS NULL AND is_active = true;

CREATE TABLE IF NOT EXISTS public.wf_notifications (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  recipient_id    UUID NOT NULL,
  title           TEXT NOT NULL,
  body            TEXT NOT NULL,
  status          TEXT NOT NULL DEFAULT 'unread',
  priority        TEXT NOT NULL DEFAULT 'normal',
  channel         TEXT NOT NULL DEFAULT 'in_app',
  source_type     TEXT,
  source_id       TEXT,
  read_at         TIMESTAMPTZ,
  data            JSONB NOT NULL DEFAULT '{}',
  version         INTEGER NOT NULL DEFAULT 1,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at      TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS wf_notifications_recipient_idx ON public.wf_notifications (tenant_id, recipient_id, status) WHERE deleted_at IS NULL;

CREATE TABLE IF NOT EXISTS public.wf_reminder_rules (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id           UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  name                TEXT NOT NULL,
  schedule_type       TEXT NOT NULL DEFAULT 'interval',
  interval_hours      INTEGER NOT NULL DEFAULT 24,
  cron_expression     TEXT,
  target_entity_type  TEXT,
  is_active           BOOLEAN NOT NULL DEFAULT true,
  version             INTEGER NOT NULL DEFAULT 1,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at          TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS wf_reminder_rules_active_idx ON public.wf_reminder_rules (tenant_id, is_active) WHERE deleted_at IS NULL;

CREATE TABLE IF NOT EXISTS public.wf_escalation_rules (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id           UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  name                TEXT NOT NULL,
  trigger_type        TEXT NOT NULL DEFAULT 'timeout',
  timeout_hours       INTEGER NOT NULL DEFAULT 48,
  escalate_to_role    TEXT,
  target_entity_type  TEXT,
  is_active           BOOLEAN NOT NULL DEFAULT true,
  version             INTEGER NOT NULL DEFAULT 1,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at          TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS wf_escalation_rules_active_idx ON public.wf_escalation_rules (tenant_id, is_active) WHERE deleted_at IS NULL;
