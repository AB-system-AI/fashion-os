# Import / Export

`ImportJob` and `ExportJob` entities track bulk data operations.

## Service

`ImportExportIntegrationService` wraps `ImportExportService` and persists job status locally + sync.

## Flow

1. User starts import/export with `DataPortAdapter` for target entity
2. Job created with `running` status
3. On completion: row counts, errors, file name stored
4. Sync processor pushes to `import_jobs` / `export_jobs`

## Permissions

`integrations.manage` required.

## UI

`/integrations/import-export` — tabbed import/export job lists.
