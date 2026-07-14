# Attendance

## Clock in

`AttendanceService.clockIn` validates employee availability, calculates late minutes via `HREngine.calculateAttendance`, persists record, publishes `AttendanceRecordedEvent`, and audits.

## Overtime

`HREngine.calculateOvertimeAmount` uses hourly rate × hours × multiplier (default 1.5).

## Shifts

`ShiftService.schedule` validates shift window with `HREngine.validateShift`.

## POS integration

Cashier attendance and shift open/close validation hook into `HrIntegrationService` via `sale.created` events.
