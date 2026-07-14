# HR Extension Guide

## Add commission on sale complete

1. Read `employeeId` from POS sale in `HrIntegrationService._onSaleCompleted`.
2. Call `CommissionService.recordFromSale`.

## Add new payroll line type

1. Extend `PayrollItemType` enum.
2. Add calculation in `HREngine.calculatePayroll`.
3. Persist via `PayrollRepository.createPayrollItem`.

## Add new sync entity

1. Add table to migration with RLS and version columns.
2. Create entity with `entityTypeName`.
3. Register processor in `hr_providers.dart` and `hrModuleInitializerProvider`.

## Export reports

Wire report data from services into shared PDF/Excel/CSV export layer (planned on Reports page).
