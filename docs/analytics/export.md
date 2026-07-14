# Export

`AnalyticsExportService` uses `ImportExportService` for:

- CSV
- Excel (XML spreadsheet)
- PDF (minimal catalog PDF with title and generated timestamp)

Each export creates a `report_export` record with filters used and generator employee id.

Permission: `reports.export`
