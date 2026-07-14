# Reports

## Features

- Saved report definitions (`ReportDefinition`)
- System and custom templates (`ReportTemplate`)
- Report snapshots for point-in-time data
- Cross-module filters, grouping, sorting (stored in definition JSON)

## Routes

| Screen | Path |
|--------|------|
| Reports hub | `/reports` |
| Report detail | `/reports/:id` |
| Templates | `/reports/templates` |
| Scheduled | `/reports/scheduled` |
| Export | `/reports/export` |

## Service

`ReportDefinitionService` handles create, list, archive with audit + sync.
