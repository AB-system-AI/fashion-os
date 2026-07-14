# Capacity & MRP Planning

## Planning method

Configured per tenant in `ManufacturingSettings.planningMethod` (`mrp`, `reorder`, `manual`).

## Engine capabilities

- `detectShortages` — compare requirements vs available stock
- `suggestPurchases` — auto purchase request quantities
- `calculateCapacity` — work center load vs `capacityHoursPerDay`
- `machineUtilization` — utilized / available hours
- `expectedCompletion` — schedule end from operation duration

## Entities

- `WorkCenter`, `Machine`
- `CapacityPlan`, `ProductionSchedule`

## Services

- `ProductionPlanningService` — MRP run from production demand
- `CapacityPlanningService` — plan and schedule by work center

## Permissions

`planning.manage`
