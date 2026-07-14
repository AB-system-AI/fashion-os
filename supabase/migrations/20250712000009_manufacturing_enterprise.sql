-- Phase 11: Enterprise Manufacturing (MRP) & Production

CREATE TABLE IF NOT EXISTS public.bills_of_materials (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id           UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  code                TEXT NOT NULL,
  name                TEXT NOT NULL,
  finished_product_id UUID NOT NULL,
  bom_type            TEXT NOT NULL DEFAULT 'standard',
  quantity            NUMERIC(14, 4) NOT NULL DEFAULT 1,
  is_active           BOOLEAN NOT NULL DEFAULT true,
  version             INTEGER NOT NULL DEFAULT 1,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at          TIMESTAMPTZ
);

CREATE UNIQUE INDEX IF NOT EXISTS bills_of_materials_tenant_code_uidx
  ON public.bills_of_materials (tenant_id, code) WHERE deleted_at IS NULL;

CREATE TABLE IF NOT EXISTS public.bom_lines (
  id                    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id             UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  bom_id                UUID NOT NULL REFERENCES public.bills_of_materials (id) ON DELETE CASCADE,
  component_product_id  UUID NOT NULL,
  line_number           INTEGER NOT NULL DEFAULT 1,
  quantity              NUMERIC(14, 4) NOT NULL DEFAULT 0,
  unit                  TEXT NOT NULL DEFAULT 'ea',
  consumption_method    TEXT NOT NULL DEFAULT 'manual',
  scrap_percent         NUMERIC(6, 2) NOT NULL DEFAULT 0,
  version               INTEGER NOT NULL DEFAULT 1,
  created_at            TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at            TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at            TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.bom_versions (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  bom_id          UUID NOT NULL REFERENCES public.bills_of_materials (id) ON DELETE CASCADE,
  version_number  INTEGER NOT NULL DEFAULT 1,
  effective_from  DATE,
  is_active       BOOLEAN NOT NULL DEFAULT true,
  version         INTEGER NOT NULL DEFAULT 1,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at      TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.production_orders (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  order_number    TEXT NOT NULL,
  product_id      UUID NOT NULL,
  bom_id          UUID REFERENCES public.bills_of_materials (id) ON DELETE SET NULL,
  status          TEXT NOT NULL DEFAULT 'draft',
  planned_qty     NUMERIC(14, 4) NOT NULL DEFAULT 0,
  completed_qty   NUMERIC(14, 4) NOT NULL DEFAULT 0,
  scrapped_qty    NUMERIC(14, 4) NOT NULL DEFAULT 0,
  warehouse_id    UUID REFERENCES public.warehouses (id) ON DELETE SET NULL,
  planned_start   TIMESTAMPTZ,
  planned_end     TIMESTAMPTZ,
  actual_start    TIMESTAMPTZ,
  actual_end      TIMESTAMPTZ,
  version         INTEGER NOT NULL DEFAULT 1,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at      TIMESTAMPTZ
);

CREATE UNIQUE INDEX IF NOT EXISTS production_orders_tenant_number_uidx
  ON public.production_orders (tenant_id, order_number);

CREATE TABLE IF NOT EXISTS public.production_order_lines (
  id                    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id             UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  production_order_id   UUID NOT NULL REFERENCES public.production_orders (id) ON DELETE CASCADE,
  component_product_id  UUID NOT NULL,
  required_qty          NUMERIC(14, 4) NOT NULL DEFAULT 0,
  issued_qty            NUMERIC(14, 4) NOT NULL DEFAULT 0,
  version               INTEGER NOT NULL DEFAULT 1,
  created_at            TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at            TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at            TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.work_orders (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id           UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  work_order_number   TEXT NOT NULL,
  production_order_id UUID NOT NULL REFERENCES public.production_orders (id) ON DELETE CASCADE,
  work_center_id      UUID,
  employee_id         UUID REFERENCES public.employees (id) ON DELETE SET NULL,
  status              TEXT NOT NULL DEFAULT 'draft',
  planned_hours       NUMERIC(10, 2) NOT NULL DEFAULT 0,
  actual_hours        NUMERIC(10, 2) NOT NULL DEFAULT 0,
  version             INTEGER NOT NULL DEFAULT 1,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at          TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.operations (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id           UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  work_order_id       UUID NOT NULL REFERENCES public.work_orders (id) ON DELETE CASCADE,
  name                TEXT NOT NULL,
  sequence            INTEGER NOT NULL DEFAULT 1,
  status              TEXT NOT NULL DEFAULT 'pending',
  setup_minutes       INTEGER NOT NULL DEFAULT 0,
  run_minutes_per_unit NUMERIC(10, 2) NOT NULL DEFAULT 0,
  version             INTEGER NOT NULL DEFAULT 1,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at          TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.work_centers (
  id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id               UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  code                    TEXT NOT NULL,
  name                    TEXT NOT NULL,
  capacity_hours_per_day  NUMERIC(8, 2) NOT NULL DEFAULT 8,
  cost_per_hour           NUMERIC(14, 4) NOT NULL DEFAULT 0,
  is_active               BOOLEAN NOT NULL DEFAULT true,
  version                 INTEGER NOT NULL DEFAULT 1,
  created_at              TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at              TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at              TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.machines (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  work_center_id  UUID NOT NULL REFERENCES public.work_centers (id) ON DELETE CASCADE,
  code            TEXT NOT NULL,
  name            TEXT NOT NULL,
  is_active       BOOLEAN NOT NULL DEFAULT true,
  version         INTEGER NOT NULL DEFAULT 1,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at      TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.material_issues (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id           UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  production_order_id UUID NOT NULL REFERENCES public.production_orders (id) ON DELETE CASCADE,
  product_id          UUID NOT NULL,
  quantity            NUMERIC(14, 4) NOT NULL DEFAULT 0,
  warehouse_id        UUID REFERENCES public.warehouses (id) ON DELETE SET NULL,
  issue_date          TIMESTAMPTZ,
  version             INTEGER NOT NULL DEFAULT 1,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at          TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.material_returns (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id           UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  production_order_id UUID NOT NULL REFERENCES public.production_orders (id) ON DELETE CASCADE,
  product_id          UUID NOT NULL,
  quantity            NUMERIC(14, 4) NOT NULL DEFAULT 0,
  warehouse_id        UUID REFERENCES public.warehouses (id) ON DELETE SET NULL,
  return_date         TIMESTAMPTZ,
  version             INTEGER NOT NULL DEFAULT 1,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at          TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.production_outputs (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id           UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  production_order_id UUID NOT NULL REFERENCES public.production_orders (id) ON DELETE CASCADE,
  product_id          UUID NOT NULL,
  quantity            NUMERIC(14, 4) NOT NULL DEFAULT 0,
  warehouse_id        UUID REFERENCES public.warehouses (id) ON DELETE SET NULL,
  output_date         TIMESTAMPTZ,
  version             INTEGER NOT NULL DEFAULT 1,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at          TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.production_scrap (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id           UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  production_order_id UUID NOT NULL REFERENCES public.production_orders (id) ON DELETE CASCADE,
  product_id          UUID NOT NULL,
  quantity            NUMERIC(14, 4) NOT NULL DEFAULT 0,
  reason              TEXT NOT NULL DEFAULT 'other',
  version             INTEGER NOT NULL DEFAULT 1,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at          TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.quality_inspections (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id           UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  production_order_id UUID NOT NULL REFERENCES public.production_orders (id) ON DELETE CASCADE,
  inspector_id        UUID REFERENCES public.employees (id) ON DELETE SET NULL,
  inspected_qty       NUMERIC(14, 4) NOT NULL DEFAULT 0,
  passed_qty          NUMERIC(14, 4) NOT NULL DEFAULT 0,
  failed_qty          NUMERIC(14, 4) NOT NULL DEFAULT 0,
  result              TEXT NOT NULL DEFAULT 'pass',
  notes               TEXT,
  version             INTEGER NOT NULL DEFAULT 1,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at          TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.maintenance_requests (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  machine_id      UUID NOT NULL REFERENCES public.machines (id) ON DELETE CASCADE,
  title           TEXT NOT NULL,
  description     TEXT,
  scheduled_date  TIMESTAMPTZ,
  is_completed    BOOLEAN NOT NULL DEFAULT false,
  version         INTEGER NOT NULL DEFAULT 1,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at      TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.capacity_plans (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  work_center_id  UUID NOT NULL REFERENCES public.work_centers (id) ON DELETE CASCADE,
  plan_date       DATE NOT NULL,
  available_hours NUMERIC(10, 2) NOT NULL DEFAULT 0,
  scheduled_hours NUMERIC(10, 2) NOT NULL DEFAULT 0,
  status          TEXT NOT NULL DEFAULT 'available',
  version         INTEGER NOT NULL DEFAULT 1,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at      TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.production_schedules (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id           UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  production_order_id UUID NOT NULL REFERENCES public.production_orders (id) ON DELETE CASCADE,
  work_center_id      UUID REFERENCES public.work_centers (id) ON DELETE SET NULL,
  scheduled_start     TIMESTAMPTZ NOT NULL,
  scheduled_end       TIMESTAMPTZ NOT NULL,
  version             INTEGER NOT NULL DEFAULT 1,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at          TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.manufacturing_settings (
  id                    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id             UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  planning_method       TEXT NOT NULL DEFAULT 'mrp',
  default_scrap_percent NUMERIC(6, 2) NOT NULL DEFAULT 0,
  auto_backflush        BOOLEAN NOT NULL DEFAULT false,
  version               INTEGER NOT NULL DEFAULT 1,
  created_at            TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at            TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at            TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS production_orders_updated_at_idx ON public.production_orders (updated_at DESC);
CREATE INDEX IF NOT EXISTS bills_of_materials_updated_at_idx ON public.bills_of_materials (updated_at DESC);
CREATE INDEX IF NOT EXISTS work_orders_updated_at_idx ON public.work_orders (updated_at DESC);
CREATE INDEX IF NOT EXISTS material_issues_updated_at_idx ON public.material_issues (updated_at DESC);

ALTER TABLE public.bills_of_materials ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.production_orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.work_orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.material_issues ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.quality_inspections ENABLE ROW LEVEL SECURITY;

CREATE POLICY bills_of_materials_tenant_select ON public.bills_of_materials
  FOR SELECT USING (tenant_id = (auth.jwt() ->> 'tenant_id')::uuid);

CREATE POLICY production_orders_tenant_select ON public.production_orders
  FOR SELECT USING (tenant_id = (auth.jwt() ->> 'tenant_id')::uuid);

CREATE POLICY work_orders_tenant_select ON public.work_orders
  FOR SELECT USING (tenant_id = (auth.jwt() ->> 'tenant_id')::uuid);

CREATE POLICY material_issues_tenant_select ON public.material_issues
  FOR SELECT USING (tenant_id = (auth.jwt() ->> 'tenant_id')::uuid);

CREATE POLICY quality_inspections_tenant_select ON public.quality_inspections
  FOR SELECT USING (tenant_id = (auth.jwt() ->> 'tenant_id')::uuid);
