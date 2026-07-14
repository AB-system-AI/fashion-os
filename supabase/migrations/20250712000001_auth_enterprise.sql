-- Fashion POS Enterprise — Phase 3: Enterprise Authentication
-- Adds invitations, device sessions, login protection, security events,
-- owner registration RPC, and employee lifecycle functions.

-- ---------------------------------------------------------------------------
-- Extend employee_status for suspension
-- ---------------------------------------------------------------------------
ALTER TYPE public.employee_status ADD VALUE IF NOT EXISTS 'suspended' BEFORE 'terminated';

-- ---------------------------------------------------------------------------
-- New enums
-- ---------------------------------------------------------------------------
CREATE TYPE public.invitation_status AS ENUM (
  'pending',
  'accepted',
  'expired',
  'revoked'
);

CREATE TYPE public.device_session_status AS ENUM (
  'active',
  'revoked',
  'expired'
);

CREATE TYPE public.security_event_type AS ENUM (
  'login_success',
  'login_failed',
  'logout',
  'logout_all',
  'password_changed',
  'password_reset_requested',
  'password_reset_completed',
  'email_verified',
  'invitation_sent',
  'invitation_accepted',
  'employee_suspended',
  'employee_activated',
  'employee_deactivated',
  'session_revoked',
  'device_registered',
  'device_trusted',
  'brute_force_blocked',
  'token_refreshed',
  'claims_updated',
  'account_locked'
);

-- ---------------------------------------------------------------------------
-- Employee Invitations
-- ---------------------------------------------------------------------------
CREATE TABLE public.employee_invitations (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES public.tenants (id) ON DELETE CASCADE,
  email           TEXT NOT NULL,
  role_id         UUID NOT NULL REFERENCES public.roles (id) ON DELETE RESTRICT,
  store_id        UUID REFERENCES public.stores (id) ON DELETE SET NULL,
  token_hash      TEXT NOT NULL,
  status          public.invitation_status NOT NULL DEFAULT 'pending',
  invited_by      UUID NOT NULL REFERENCES public.employees (id) ON DELETE RESTRICT,
  job_title       TEXT,
  employee_code   TEXT,
  expires_at      TIMESTAMPTZ NOT NULL,
  accepted_at     TIMESTAMPTZ,
  accepted_by     UUID REFERENCES auth.users (id) ON DELETE SET NULL,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),

  CONSTRAINT employee_invitations_email_format CHECK (email ~ '^[^@]+@[^@]+\.[^@]+$')
);

CREATE UNIQUE INDEX employee_invitations_pending_email_uidx
  ON public.employee_invitations (tenant_id, lower(email))
  WHERE status = 'pending';

CREATE INDEX employee_invitations_token_hash_idx ON public.employee_invitations (token_hash);
CREATE INDEX employee_invitations_tenant_id_idx ON public.employee_invitations (tenant_id);

-- ---------------------------------------------------------------------------
-- Device Sessions (application-level session tracking)
-- ---------------------------------------------------------------------------
CREATE TABLE public.auth_device_sessions (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES public.tenants (id) ON DELETE CASCADE,
  employee_id     UUID NOT NULL REFERENCES public.employees (id) ON DELETE CASCADE,
  user_id         UUID NOT NULL REFERENCES auth.users (id) ON DELETE CASCADE,
  device_id       UUID NOT NULL,
  device_name     TEXT NOT NULL,
  platform        TEXT NOT NULL,
  app_version     TEXT,
  ip_address      INET,
  user_agent      TEXT,
  status          public.device_session_status NOT NULL DEFAULT 'active',
  is_trusted      BOOLEAN NOT NULL DEFAULT false,
  remember_me     BOOLEAN NOT NULL DEFAULT false,
  last_active_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  expires_at      TIMESTAMPTZ NOT NULL,
  revoked_at      TIMESTAMPTZ,
  revoked_reason  TEXT,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX auth_device_sessions_user_id_idx ON public.auth_device_sessions (user_id);
CREATE INDEX auth_device_sessions_employee_id_idx ON public.auth_device_sessions (employee_id);
CREATE INDEX auth_device_sessions_device_id_idx ON public.auth_device_sessions (device_id);
CREATE INDEX auth_device_sessions_active_idx ON public.auth_device_sessions (user_id, status)
  WHERE status = 'active';

-- ---------------------------------------------------------------------------
-- Login Attempts (brute-force protection)
-- ---------------------------------------------------------------------------
CREATE TABLE public.login_attempts (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email           TEXT NOT NULL,
  ip_address      INET,
  user_agent      TEXT,
  success         BOOLEAN NOT NULL DEFAULT false,
  failure_reason  TEXT,
  attempted_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX login_attempts_email_time_idx ON public.login_attempts (lower(email), attempted_at DESC);
CREATE INDEX login_attempts_ip_time_idx ON public.login_attempts (ip_address, attempted_at DESC);

-- ---------------------------------------------------------------------------
-- Security Events
-- ---------------------------------------------------------------------------
CREATE TABLE public.security_events (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID REFERENCES public.tenants (id) ON DELETE SET NULL,
  employee_id     UUID REFERENCES public.employees (id) ON DELETE SET NULL,
  user_id         UUID REFERENCES auth.users (id) ON DELETE SET NULL,
  event_type      public.security_event_type NOT NULL,
  ip_address      INET,
  user_agent      TEXT,
  device_id       UUID,
  metadata        JSONB NOT NULL DEFAULT '{}',
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX security_events_tenant_id_idx ON public.security_events (tenant_id);
CREATE INDEX security_events_user_id_idx ON public.security_events (user_id);
CREATE INDEX security_events_type_idx ON public.security_events (event_type);
CREATE INDEX security_events_created_at_idx ON public.security_events (created_at DESC);

-- ---------------------------------------------------------------------------
-- Remote Configuration (feature flags, maintenance, version gates)
-- ---------------------------------------------------------------------------
CREATE TABLE public.remote_config (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID REFERENCES public.tenants (id) ON DELETE CASCADE,
  key             TEXT NOT NULL,
  value           JSONB NOT NULL DEFAULT '{}',
  description     TEXT,
  is_active       BOOLEAN NOT NULL DEFAULT true,
  min_app_version TEXT,
  max_app_version TEXT,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX remote_config_global_key_uidx
  ON public.remote_config (key)
  WHERE tenant_id IS NULL;

CREATE UNIQUE INDEX remote_config_tenant_key_uidx
  ON public.remote_config (tenant_id, key)
  WHERE tenant_id IS NOT NULL;

-- ---------------------------------------------------------------------------
-- Helper: check brute force lockout
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.is_login_locked(p_email TEXT, p_max_attempts INT DEFAULT 5, p_window_minutes INT DEFAULT 15)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT COUNT(*) >= p_max_attempts
  FROM public.login_attempts
  WHERE lower(email) = lower(p_email)
    AND success = false
    AND attempted_at > now() - (p_window_minutes || ' minutes')::interval;
$$;

-- ---------------------------------------------------------------------------
-- Helper: record security event
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.record_security_event(
  p_tenant_id UUID,
  p_employee_id UUID,
  p_user_id UUID,
  p_event_type public.security_event_type,
  p_ip_address INET DEFAULT NULL,
  p_user_agent TEXT DEFAULT NULL,
  p_device_id UUID DEFAULT NULL,
  p_metadata JSONB DEFAULT '{}'
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE v_id UUID;
BEGIN
  INSERT INTO public.security_events (
    tenant_id, employee_id, user_id, event_type,
    ip_address, user_agent, device_id, metadata
  ) VALUES (
    p_tenant_id, p_employee_id, p_user_id, p_event_type,
    p_ip_address, p_user_agent, p_device_id, p_metadata
  ) RETURNING id INTO v_id;
  RETURN v_id;
END;
$$;

-- ---------------------------------------------------------------------------
-- Owner Registration (single transaction)
-- Called after Supabase Auth signUp; uses auth.uid()
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.register_owner_organization(
  p_tenant_name       TEXT,
  p_tenant_slug       TEXT,
  p_store_name        TEXT,
  p_store_code        TEXT DEFAULT 'MAIN',
  p_currency          CHAR(3) DEFAULT 'USD',
  p_timezone          TEXT DEFAULT 'UTC',
  p_country           CHAR(2) DEFAULT 'US',
  p_plan_code         TEXT DEFAULT 'professional',
  p_full_name         TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_user_id       UUID;
  v_user_email    TEXT;
  v_tenant_id     UUID;
  v_plan_id       UUID;
  v_store_id      UUID;
  v_warehouse_id  UUID;
  v_employee_id   UUID;
  v_owner_role_id UUID;
  v_program_id    UUID;
BEGIN
  v_user_id := auth.uid();
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  IF EXISTS (SELECT 1 FROM public.employees WHERE user_id = v_user_id) THEN
    RAISE EXCEPTION 'User already belongs to an organization';
  END IF;

  SELECT email INTO v_user_email FROM auth.users WHERE id = v_user_id;

  IF p_tenant_slug !~ '^[a-z0-9][a-z0-9-]{1,62}[a-z0-9]$' THEN
    RAISE EXCEPTION 'Invalid tenant slug format';
  END IF;

  SELECT id INTO v_plan_id FROM public.subscription_plans
  WHERE code = p_plan_code AND is_active = true LIMIT 1;
  IF v_plan_id IS NULL THEN
    SELECT id INTO v_plan_id FROM public.subscription_plans WHERE code = 'starter' LIMIT 1;
  END IF;

  UPDATE public.profiles
  SET full_name = COALESCE(p_full_name, full_name), updated_at = now()
  WHERE id = v_user_id;

  INSERT INTO public.tenants (name, slug, email, status, default_currency, default_timezone, trial_ends_at)
  VALUES (p_tenant_name, p_tenant_slug, v_user_email, 'trial', p_currency, p_timezone, now() + interval '14 days')
  RETURNING id INTO v_tenant_id;

  INSERT INTO public.tenant_subscriptions (tenant_id, plan_id, status, current_period_end)
  VALUES (v_tenant_id, v_plan_id, 'trialing', now() + interval '14 days');

  INSERT INTO public.stores (tenant_id, code, name, country, timezone, currency, is_default, status)
  VALUES (v_tenant_id, p_store_code, p_store_name, p_country, p_timezone, p_currency, true, 'active')
  RETURNING id INTO v_store_id;

  INSERT INTO public.warehouses (tenant_id, store_id, code, name, is_default, is_active)
  VALUES (v_tenant_id, v_store_id, 'WH-' || p_store_code, p_store_name || ' Warehouse', true, true)
  RETURNING id INTO v_warehouse_id;

  INSERT INTO public.numbering_sequences (tenant_id, store_id, sequence_type, prefix) VALUES
    (v_tenant_id, v_store_id, 'sale_order', 'SO-'),
    (v_tenant_id, v_store_id, 'return', 'RT-'),
    (v_tenant_id, v_store_id, 'purchase_order', 'PO-'),
    (v_tenant_id, v_store_id, 'cash_session', 'CS-'),
    (v_tenant_id, v_store_id, 'expense', 'EX-'),
    (v_tenant_id, v_store_id, 'exchange', 'EXC-'),
    (v_tenant_id, v_store_id, 'transfer', 'TR-');

  INSERT INTO public.roles (tenant_id, code, name, is_system) VALUES
    (v_tenant_id, 'owner', 'Owner', true),
    (v_tenant_id, 'manager', 'Store Manager', true),
    (v_tenant_id, 'cashier', 'Cashier', true);

  SELECT id INTO v_owner_role_id FROM public.roles
  WHERE tenant_id = v_tenant_id AND code = 'owner';

  INSERT INTO public.role_permissions (role_id, permission_id)
  SELECT r.id, p.id FROM public.roles r CROSS JOIN public.permissions p
  WHERE r.tenant_id = v_tenant_id AND r.code = 'owner';

  INSERT INTO public.role_permissions (role_id, permission_id)
  SELECT r.id, p.id FROM public.roles r CROSS JOIN public.permissions p
  WHERE r.tenant_id = v_tenant_id AND r.code = 'manager'
    AND p.code NOT IN ('store.delete', 'employee.delete', 'role.manage', 'settings.update');

  INSERT INTO public.role_permissions (role_id, permission_id)
  SELECT r.id, p.id FROM public.roles r CROSS JOIN public.permissions p
  WHERE r.tenant_id = v_tenant_id AND r.code = 'cashier'
    AND p.module IN ('sale', 'return', 'exchange', 'cash', 'customer', 'product')
    AND p.code NOT IN ('sale.void', 'sale.refund', 'return.approve');

  INSERT INTO public.employees (tenant_id, user_id, profile_id, employee_code, job_title, status, hired_at)
  VALUES (v_tenant_id, v_user_id, v_user_id, 'OWNER-001', 'Owner', 'active', CURRENT_DATE)
  RETURNING id INTO v_employee_id;

  INSERT INTO public.employee_store_assignments (tenant_id, employee_id, store_id, is_primary, is_active)
  VALUES (v_tenant_id, v_employee_id, v_store_id, true, true);

  INSERT INTO public.employee_roles (tenant_id, employee_id, role_id, store_id)
  VALUES (v_tenant_id, v_employee_id, v_owner_role_id, v_store_id);

  INSERT INTO public.taxes (tenant_id, name, code, rate, tax_type) VALUES
    (v_tenant_id, 'Sales Tax', 'SALES_TAX', 0, 'percentage');

  INSERT INTO public.payment_methods (tenant_id, code, name, method_type, sort_order) VALUES
    (v_tenant_id, 'CASH', 'Cash', 'cash', 1),
    (v_tenant_id, 'CARD', 'Credit/Debit Card', 'card', 2),
    (v_tenant_id, 'MOBILE', 'Mobile Wallet', 'mobile_wallet', 3),
    (v_tenant_id, 'STORE_CREDIT', 'Store Credit', 'store_credit', 4);

  INSERT INTO public.pos_registers (tenant_id, store_id, code, name) VALUES
    (v_tenant_id, v_store_id, 'REG-01', 'Register 1');

  INSERT INTO public.expense_categories (tenant_id, name, code) VALUES
    (v_tenant_id, 'Rent', 'RENT'),
    (v_tenant_id, 'Utilities', 'UTILITIES'),
    (v_tenant_id, 'Salaries', 'SALARIES'),
    (v_tenant_id, 'Supplies', 'SUPPLIES');

  INSERT INTO public.loyalty_programs (tenant_id, name, points_per_currency, currency_per_point, min_redeem_points)
  VALUES (v_tenant_id, 'Fashion Rewards', 1, 0.01, 100)
  RETURNING id INTO v_program_id;

  INSERT INTO public.loyalty_tiers (tenant_id, program_id, name, min_points, multiplier, sort_order)
  VALUES
    (v_tenant_id, v_program_id, 'Bronze', 0, 1.0, 1),
    (v_tenant_id, v_program_id, 'Silver', 500, 1.25, 2),
    (v_tenant_id, v_program_id, 'Gold', 2000, 1.5, 3);

  INSERT INTO public.receipt_templates (tenant_id, store_id, name, template_type, body_html, is_default) VALUES
    (v_tenant_id, v_store_id, 'Default Sale Receipt', 'sale',
     '<div class="receipt"><h1>{{store_name}}</h1><p>{{order_number}}</p>{{#items}}<div>{{name}} {{total}}</div>{{/items}}<p>Total: {{grand_total}}</p></div>',
     true);

  INSERT INTO public.settings (tenant_id, store_id, scope, key, value) VALUES
    (v_tenant_id, NULL, 'tenant', 'pos.auto_print', '{"enabled": true}'::jsonb),
    (v_tenant_id, NULL, 'tenant', 'inventory.low_stock_alert', '{"enabled": true}'::jsonb),
    (v_tenant_id, v_store_id, 'store', 'receipt.header', '{"show_logo": true}'::jsonb);

  PERFORM public.record_security_event(
    v_tenant_id, v_employee_id, v_user_id, 'invitation_accepted',
    NULL, NULL, NULL,
    jsonb_build_object('action', 'owner_registration')
  );

  RETURN jsonb_build_object(
    'tenant_id', v_tenant_id,
    'store_id', v_store_id,
    'warehouse_id', v_warehouse_id,
    'employee_id', v_employee_id,
    'role_id', v_owner_role_id
  );
END;
$$;

-- ---------------------------------------------------------------------------
-- Get employee context for JWT claims
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.get_employee_auth_context(p_user_id UUID DEFAULT auth.uid())
RETURNS JSONB
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT jsonb_build_object(
    'tenant_id', e.tenant_id,
    'employee_id', e.id,
    'employee_status', e.status,
    'store_ids', COALESCE(
      (SELECT jsonb_agg(esa.store_id) FROM public.employee_store_assignments esa
       WHERE esa.employee_id = e.id AND esa.is_active = true),
      '[]'::jsonb
    ),
    'permissions', COALESCE(
      (SELECT jsonb_agg(DISTINCT p.code)
       FROM public.employee_roles er
       JOIN public.role_permissions rp ON rp.role_id = er.role_id
       JOIN public.permissions p ON p.id = rp.permission_id
       WHERE er.employee_id = e.id),
      '[]'::jsonb
    )
  )
  FROM public.employees e
  WHERE e.user_id = p_user_id
    AND e.status = 'active'
    AND e.deleted_at IS NULL
  LIMIT 1;
$$;

-- ---------------------------------------------------------------------------
-- Invite employee
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.invite_employee(
  p_email TEXT,
  p_role_id UUID,
  p_store_id UUID DEFAULT NULL,
  p_job_title TEXT DEFAULT NULL,
  p_employee_code TEXT DEFAULT NULL,
  p_expires_days INT DEFAULT 7
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_tenant_id UUID;
  v_employee_id UUID;
  v_token TEXT;
  v_token_hash TEXT;
  v_invitation_id UUID;
BEGIN
  v_tenant_id := private.get_tenant_id();
  v_employee_id := private.get_employee_id();

  IF NOT private.has_permission('employee.create') THEN
    RAISE EXCEPTION 'Permission denied';
  END IF;

  v_token := encode(gen_random_bytes(32), 'hex');
  v_token_hash := encode(digest(v_token, 'sha256'), 'hex');

  INSERT INTO public.employee_invitations (
    tenant_id, email, role_id, store_id, token_hash,
    invited_by, job_title, employee_code, expires_at
  ) VALUES (
    v_tenant_id, lower(p_email), p_role_id, p_store_id, v_token_hash,
    v_employee_id, p_job_title, p_employee_code, now() + (p_expires_days || ' days')::interval
  ) RETURNING id INTO v_invitation_id;

  PERFORM public.record_security_event(
    v_tenant_id, v_employee_id, auth.uid(), 'invitation_sent',
    NULL, NULL, NULL, jsonb_build_object('email', p_email, 'invitation_id', v_invitation_id)
  );

  RETURN jsonb_build_object('invitation_id', v_invitation_id, 'token', v_token);
END;
$$;

-- ---------------------------------------------------------------------------
-- Accept employee invitation
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.accept_employee_invitation(p_token TEXT)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_user_id UUID;
  v_token_hash TEXT;
  v_inv RECORD;
  v_employee_id UUID;
  v_code TEXT;
BEGIN
  v_user_id := auth.uid();
  IF v_user_id IS NULL THEN RAISE EXCEPTION 'Not authenticated'; END IF;

  v_token_hash := encode(digest(p_token, 'sha256'), 'hex');

  SELECT * INTO v_inv FROM public.employee_invitations
  WHERE token_hash = v_token_hash AND status = 'pending' AND expires_at > now()
  FOR UPDATE;

  IF NOT FOUND THEN RAISE EXCEPTION 'Invalid or expired invitation'; END IF;

  IF EXISTS (SELECT 1 FROM public.employees WHERE tenant_id = v_inv.tenant_id AND user_id = v_user_id) THEN
    RAISE EXCEPTION 'Already a member of this organization';
  END IF;

  v_code := COALESCE(v_inv.employee_code, 'EMP-' || upper(substr(gen_random_uuid()::text, 1, 8)));

  INSERT INTO public.employees (tenant_id, user_id, profile_id, employee_code, job_title, status, hired_at)
  VALUES (v_inv.tenant_id, v_user_id, v_user_id, v_code, v_inv.job_title, 'active', CURRENT_DATE)
  RETURNING id INTO v_employee_id;

  IF v_inv.store_id IS NOT NULL THEN
    INSERT INTO public.employee_store_assignments (tenant_id, employee_id, store_id, is_primary, is_active)
    VALUES (v_inv.tenant_id, v_employee_id, v_inv.store_id, true, true);
  END IF;

  INSERT INTO public.employee_roles (tenant_id, employee_id, role_id, store_id, granted_by)
  VALUES (v_inv.tenant_id, v_employee_id, v_inv.role_id, v_inv.store_id, v_inv.invited_by);

  UPDATE public.employee_invitations
  SET status = 'accepted', accepted_at = now(), accepted_by = v_user_id, updated_at = now()
  WHERE id = v_inv.id;

  PERFORM public.record_security_event(
    v_inv.tenant_id, v_employee_id, v_user_id, 'invitation_accepted',
    NULL, NULL, NULL, jsonb_build_object('invitation_id', v_inv.id)
  );

  RETURN jsonb_build_object('tenant_id', v_inv.tenant_id, 'employee_id', v_employee_id);
END;
$$;

-- ---------------------------------------------------------------------------
-- Register device session
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.register_device_session(
  p_device_id UUID,
  p_device_name TEXT,
  p_platform TEXT,
  p_app_version TEXT DEFAULT NULL,
  p_ip_address INET DEFAULT NULL,
  p_user_agent TEXT DEFAULT NULL,
  p_remember_me BOOLEAN DEFAULT false,
  p_session_days INT DEFAULT 30
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_tenant_id UUID;
  v_employee_id UUID;
  v_user_id UUID;
  v_session_id UUID;
  v_days INT;
BEGIN
  v_user_id := auth.uid();
  v_tenant_id := private.get_tenant_id();
  v_employee_id := private.get_employee_id();

  IF v_user_id IS NULL OR v_employee_id IS NULL THEN
    RAISE EXCEPTION 'Not authenticated or no employee context';
  END IF;

  v_days := CASE WHEN p_remember_me THEN 90 ELSE p_session_days END;

  INSERT INTO public.auth_device_sessions (
    tenant_id, employee_id, user_id, device_id, device_name, platform,
    app_version, ip_address, user_agent, remember_me, expires_at
  ) VALUES (
    v_tenant_id, v_employee_id, v_user_id, p_device_id, p_device_name, p_platform,
    p_app_version, p_ip_address, p_user_agent, p_remember_me, now() + (v_days || ' days')::interval
  ) RETURNING id INTO v_session_id;

  PERFORM public.record_security_event(
    v_tenant_id, v_employee_id, v_user_id, 'device_registered',
    p_ip_address, p_user_agent, p_device_id,
    jsonb_build_object('session_id', v_session_id)
  );

  RETURN v_session_id;
END;
$$;

-- ---------------------------------------------------------------------------
-- Revoke sessions
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.revoke_device_session(p_session_id UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  UPDATE public.auth_device_sessions
  SET status = 'revoked', revoked_at = now(), revoked_reason = 'user_revoked', updated_at = now()
  WHERE id = p_session_id AND user_id = auth.uid() AND status = 'active';

  PERFORM public.record_security_event(
    private.get_tenant_id(), private.get_employee_id(), auth.uid(), 'session_revoked',
    NULL, NULL, NULL, jsonb_build_object('session_id', p_session_id)
  );
END;
$$;

CREATE OR REPLACE FUNCTION public.revoke_all_device_sessions(p_except_session_id UUID DEFAULT NULL)
RETURNS INT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE v_count INT;
BEGIN
  UPDATE public.auth_device_sessions
  SET status = 'revoked', revoked_at = now(), revoked_reason = 'logout_all', updated_at = now()
  WHERE user_id = auth.uid() AND status = 'active'
    AND (p_except_session_id IS NULL OR id <> p_except_session_id);

  GET DIAGNOSTICS v_count = ROW_COUNT;

  PERFORM public.record_security_event(
    private.get_tenant_id(), private.get_employee_id(), auth.uid(), 'logout_all',
    NULL, NULL, NULL, jsonb_build_object('revoked_count', v_count)
  );

  RETURN v_count;
END;
$$;

-- ---------------------------------------------------------------------------
-- Employee status management
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.set_employee_status(
  p_employee_id UUID,
  p_status public.employee_status
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE v_event public.security_event_type;
BEGIN
  IF NOT private.has_permission('employee.update') THEN
    RAISE EXCEPTION 'Permission denied';
  END IF;

  UPDATE public.employees
  SET status = p_status,
      terminated_at = CASE WHEN p_status = 'terminated' THEN CURRENT_DATE ELSE terminated_at END,
      updated_at = now()
  WHERE id = p_employee_id AND tenant_id = private.get_tenant_id();

  v_event := CASE p_status
    WHEN 'active' THEN 'employee_activated'::public.security_event_type
    WHEN 'suspended' THEN 'employee_suspended'::public.security_event_type
    ELSE 'employee_deactivated'::public.security_event_type
  END;

  PERFORM public.record_security_event(
    private.get_tenant_id(), p_employee_id, NULL, v_event,
    NULL, NULL, NULL, jsonb_build_object('new_status', p_status)
  );
END;
$$;

-- ---------------------------------------------------------------------------
-- RLS for new tables
-- ---------------------------------------------------------------------------
ALTER TABLE public.employee_invitations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.employee_invitations FORCE ROW LEVEL SECURITY;
ALTER TABLE public.auth_device_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.auth_device_sessions FORCE ROW LEVEL SECURITY;
ALTER TABLE public.login_attempts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.login_attempts FORCE ROW LEVEL SECURITY;
ALTER TABLE public.security_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.security_events FORCE ROW LEVEL SECURITY;
ALTER TABLE public.remote_config ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.remote_config FORCE ROW LEVEL SECURITY;

CREATE POLICY employee_invitations_tenant_select ON public.employee_invitations
  FOR SELECT TO authenticated USING (private.tenant_matches(tenant_id));

CREATE POLICY employee_invitations_tenant_insert ON public.employee_invitations
  FOR INSERT TO authenticated WITH CHECK (
    private.tenant_matches(tenant_id) AND private.has_permission('employee.create')
  );

CREATE POLICY auth_device_sessions_own_select ON public.auth_device_sessions
  FOR SELECT TO authenticated USING (user_id = auth.uid());

CREATE POLICY auth_device_sessions_own_update ON public.auth_device_sessions
  FOR UPDATE TO authenticated USING (user_id = auth.uid());

CREATE POLICY security_events_tenant_select ON public.security_events
  FOR SELECT TO authenticated USING (
    private.tenant_matches(tenant_id) AND private.has_permission('audit.read')
  );

CREATE POLICY remote_config_select ON public.remote_config
  FOR SELECT TO authenticated USING (
    tenant_id IS NULL OR private.tenant_matches(tenant_id)
  );

-- login_attempts: no direct client access (functions only via service role)
CREATE POLICY login_attempts_deny_all ON public.login_attempts
  FOR ALL TO authenticated USING (false);

-- Grant execute on functions
GRANT EXECUTE ON FUNCTION public.register_owner_organization TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_employee_auth_context TO authenticated;
GRANT EXECUTE ON FUNCTION public.invite_employee TO authenticated;
GRANT EXECUTE ON FUNCTION public.accept_employee_invitation TO authenticated;
GRANT EXECUTE ON FUNCTION public.register_device_session TO authenticated;
GRANT EXECUTE ON FUNCTION public.revoke_device_session TO authenticated;
GRANT EXECUTE ON FUNCTION public.revoke_all_device_sessions TO authenticated;
GRANT EXECUTE ON FUNCTION public.set_employee_status TO authenticated;
GRANT EXECUTE ON FUNCTION public.is_login_locked TO authenticated, anon;
GRANT EXECUTE ON FUNCTION public.record_security_event TO authenticated, service_role;

-- Seed global remote config
INSERT INTO public.remote_config (key, value, description) VALUES
  ('maintenance_mode', '{"enabled": false, "message": ""}', 'Global maintenance mode'),
  ('min_app_version', '{"android": "0.1.0", "ios": "0.1.0", "force_update": false}', 'Minimum supported app versions'),
  ('feature_flags', '{"offline_mode": true, "loyalty": true, "multi_store": true}', 'Global feature flags')
ON CONFLICT DO NOTHING;
