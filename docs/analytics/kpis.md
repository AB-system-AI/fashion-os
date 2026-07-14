# KPIs

`AnalyticsEngine` provides pure calculations:

- Sales: margin, AOV, refund rate
- Inventory: turnover, coverage days
- CRM: churn rate
- HR: attendance rate
- Manufacturing: OEE, capacity utilization
- Accounting: current ratio

`KpiService.captureCategory` snapshots KPIs per category into `kpi_snapshots` via dashboard bundles.

Permission: `kpi.view`
