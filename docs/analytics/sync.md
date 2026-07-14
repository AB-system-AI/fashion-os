# Analytics Sync

## Processors

Registered in `analyticsModuleInitializerProvider`:

| Processor | Entity | Remote table |
|-----------|--------|--------------|
| Report | `report_definition` | `report_definitions` |
| Report | `report_template` | `report_templates` |
| Report | `report_export` | `report_exports` |
| Report | `report_snapshot` | `report_snapshots` |
| Dashboard | `dashboard_layout` | `dashboard_layouts` |
| Dashboard | `dashboard_widget` | `dashboard_widgets` |
| KPI | `analytics_snapshot` | `analytics_snapshots` |
| KPI | `kpi_snapshot` | `kpi_snapshots` |
| KPI | `scheduled_report` | `scheduled_reports` |
| KPI | `report_execution_history` | `report_execution_history` |

Migration: `20250712000011_reporting_analytics_enterprise.sql` with RLS tenant policies.
