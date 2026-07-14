# Extension Guide

1. Add workflow state → extend enums + `SalesOrderEngine.canTransition*`
2. New document type → `DocumentNumberType` + `NumberGeneratorEngine` format
3. New sync entity → migration table + processor provider + module initializer
4. Accounting posting → subscribe in `AccountingIntegrationService`

Reuse POS `SalesEngine` for line totals at checkout; use `SalesOrderEngine` for OMS lifecycle.
