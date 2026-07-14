-- Phase 11.1: Manufacturing hardening — full RLS + finished goods receipts

CREATE TABLE IF NOT EXISTS public.finished_goods_receipts (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id           UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  production_order_id UUID NOT NULL REFERENCES public.production_orders (id) ON DELETE CASCADE,
  product_id          UUID NOT NULL,
  quantity            NUMERIC(14, 4) NOT NULL DEFAULT 0,
  warehouse_id        UUID REFERENCES public.warehouses (id) ON DELETE SET NULL,
  receipt_date        TIMESTAMPTZ,
  version             INTEGER NOT NULL DEFAULT 1,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at          TIMESTAMPTZ
);

-- Enable RLS on all manufacturing tables
DO $$
DECLARE
  t text;
BEGIN
  FOREACH t IN ARRAY ARRAY[
    'bills_of_materials', 'bom_lines', 'bom_versions', 'production_orders', 'production_order_lines',
    'work_orders', 'operations', 'work_centers', 'machines', 'material_issues', 'material_returns',
    'production_outputs', 'production_scrap', 'quality_inspections', 'maintenance_requests',
    'capacity_plans', 'production_schedules', 'manufacturing_settings', 'finished_goods_receipts'
  ]
  LOOP
    EXECUTE format('ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY', t);
  END LOOP;
END $$;

-- Tenant isolation policies (SELECT, INSERT, UPDATE, DELETE)
DO $$
DECLARE
  t text;
BEGIN
  FOREACH t IN ARRAY ARRAY[
    'bills_of_materials', 'bom_lines', 'bom_versions', 'production_orders', 'production_order_lines',
    'work_orders', 'operations', 'work_centers', 'machines', 'material_issues', 'material_returns',
    'production_outputs', 'production_scrap', 'quality_inspections', 'maintenance_requests',
    'capacity_plans', 'production_schedules', 'manufacturing_settings', 'finished_goods_receipts'
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
