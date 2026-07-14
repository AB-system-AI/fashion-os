# Maintenance

## Entities

- **MaintenanceRequest** — corrective/preventive work orders
- **MaintenanceSchedule** — recurring preventive intervals
- **MaintenanceTask** — checklist items per request
- **MaintenanceCost** — labor, parts, vendor costs

## Scheduling

`AssetsEngine.scheduleNextMaintenance` computes next due date from `intervalDays` and last completion.

## Costing

`AssetsEngine.summarizeMaintenanceCosts` aggregates labor, parts, and other costs per request.

## Permissions

- View open requests and due schedules: `assets.maintenance.view`
- Create and complete requests: `assets.maintenance.manage`
