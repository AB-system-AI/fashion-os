# Analytics Integration

`SalesReportService` exposes KPIs for Phase 12 dashboards:
- Conversion rate (quotations → orders)
- Fulfillment rate
- Open backorders
- Pending shipments

Feed into `DashboardService` by injecting `salesReportServiceProvider` (future wiring).
