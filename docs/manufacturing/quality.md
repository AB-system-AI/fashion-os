# Quality & Maintenance

## Quality results

`pass`, `fail`, `hold`, `rework`, `scrap` — see `QualityResult` enum.

## Inspection flow

`QualityInspectionService` records inspected/passed/failed quantities. `ManufacturingEngine.evaluateInspection` determines result. Events `quality.passed` / `quality.failed` published on disposition.

## Scrap

`ProductionScrap` entity with `ScrapReason` enum for variance tracking.

## Maintenance

`MaintenanceRequest` linked to `Machine`; `MaintenanceService` schedules and completes requests.

## Permissions

`quality.manage`, `manufacturing.maintenance.manage`
