import 'package:fashion_pos_enterprise/core/business/events/business_events.dart';
import 'package:fashion_pos_enterprise/core/business/events/domain_event_bus.dart';
import 'package:fashion_pos_enterprise/core/errors/failure.dart';
import 'package:fashion_pos_enterprise/core/result/result.dart';
import 'package:fashion_pos_enterprise/features/hr/domain/entities/attendance.dart';
import 'package:fashion_pos_enterprise/features/hr/domain/entities/employee.dart';
import 'package:fashion_pos_enterprise/features/hr/domain/entities/leave.dart';
import 'package:fashion_pos_enterprise/features/hr/domain/entities/payroll.dart';
import 'package:fashion_pos_enterprise/features/hr/domain/enums/hr_enums.dart';
import 'package:uuid/uuid.dart';

class PayrollLineInput {
  const PayrollLineInput({
    required this.employeeId,
    required this.baseSalary,
    this.allowances = 0,
    this.bonuses = 0,
    this.commissions = 0,
    this.overtime = 0,
    this.deductions = 0,
    this.leaveDeduction = 0,
    this.taxRate = 0.1,
  });

  final String employeeId;
  final double baseSalary;
  final double allowances;
  final double bonuses;
  final double commissions;
  final double overtime;
  final double deductions;
  final double leaveDeduction;
  final double taxRate;
}

class PayrollCalculationResult {
  const PayrollCalculationResult({
    required this.employeeId,
    required this.gross,
    required this.deductions,
    required this.tax,
    required this.net,
    required this.items,
  });

  final String employeeId;
  final double gross;
  final double deductions;
  final double tax;
  final double net;
  final List<PayrollItemTypeAmount> items;
}

class PayrollItemTypeAmount {
  const PayrollItemTypeAmount({required this.type, required this.amount, this.description});

  final PayrollItemType type;
  final double amount;
  final String? description;
}

class AttendanceCalculation {
  const AttendanceCalculation({
    required this.lateMinutes,
    required this.workedMinutes,
    required this.overtimeHours,
    required this.status,
  });

  final int lateMinutes;
  final int workedMinutes;
  final double overtimeHours;
  final AttendanceStatus status;
}

/// Pure HR rules: attendance, payroll, shifts, leave, commissions.
class HREngine {
  HREngine({DomainEventBus? eventBus, Uuid? uuid})
      : _eventBus = eventBus,
        _uuid = uuid ?? const Uuid();

  final DomainEventBus? _eventBus;
  final Uuid _uuid;

  static const defaultShiftMinutes = 8 * 60;
  static const defaultLateGraceMinutes = 5;
  static const defaultOvertimeMultiplier = 1.5;
  static const defaultCommissionRate = 0.02;

  Result<void> validateShift(Shift shift) {
    if (shift.endTime.isBefore(shift.startTime)) {
      return const Error(ValidationFailure(message: 'Shift end must be after start', code: 'invalid_shift'));
    }
    if (shift.employeeId.isEmpty) {
      return const Error(ValidationFailure(message: 'Employee required', code: 'missing_employee'));
    }
    return const Success(null);
  }

  Result<void> validateEmployeeAvailable(Employee employee, DateTime on) {
    if (employee.status != EmployeeStatus.active) {
      return Error(ValidationFailure(message: 'Employee ${employee.employeeCode} is not active', code: 'inactive_employee'));
    }
    if (employee.terminatedAt != null && !on.isBefore(employee.terminatedAt!)) {
      return const Error(ValidationFailure(message: 'Employee is terminated', code: 'terminated_employee'));
    }
    return const Success(null);
  }

  AttendanceCalculation calculateAttendance({
    required DateTime scheduledStart,
    required DateTime scheduledEnd,
    required DateTime? clockIn,
    required DateTime? clockOut,
    int graceMinutes = defaultLateGraceMinutes,
  }) {
    if (clockIn == null) {
      return const AttendanceCalculation(lateMinutes: 0, workedMinutes: 0, overtimeHours: 0, status: AttendanceStatus.absent);
    }

    final late = clockIn.isAfter(scheduledStart.add(Duration(minutes: graceMinutes)))
        ? clockIn.difference(scheduledStart).inMinutes
        : 0;

    final effectiveOut = clockOut ?? scheduledEnd;
    final worked = effectiveOut.difference(clockIn).inMinutes.clamp(0, 24 * 60);
    final scheduledMinutes = scheduledEnd.difference(scheduledStart).inMinutes;
    final overtimeMinutes = (worked - scheduledMinutes).clamp(0, 24 * 60);
    final overtimeHours = overtimeMinutes / 60;

    final status = late > 0 ? AttendanceStatus.late : AttendanceStatus.present;
    return AttendanceCalculation(
      lateMinutes: late,
      workedMinutes: worked,
      overtimeHours: _round(overtimeHours),
      status: status,
    );
  }

  double calculateOvertimeAmount({required double hourlyRate, required double hours, double multiplier = defaultOvertimeMultiplier}) {
    return _round(hourlyRate * hours * multiplier);
  }

  double calculateLeaveDeduction({required double baseSalary, required double leaveDays, int workingDaysPerMonth = 22}) {
    if (leaveDays <= 0 || workingDaysPerMonth <= 0) return 0;
    return _round((baseSalary / workingDaysPerMonth) * leaveDays);
  }

  double calculateCommission({required double saleTotal, double rate = defaultCommissionRate}) {
    return _round(saleTotal * rate);
  }

  PayrollCalculationResult calculatePayroll(PayrollLineInput input) {
    final gross = _round(
      input.baseSalary + input.allowances + input.bonuses + input.commissions + input.overtime,
    );
    final totalDeductions = _round(input.deductions + input.leaveDeduction);
    final taxable = (gross - totalDeductions).clamp(0, double.infinity);
    final tax = _round(taxable * input.taxRate);
    final net = _round(gross - totalDeductions - tax);

    final items = <PayrollItemTypeAmount>[
      PayrollItemTypeAmount(type: PayrollItemType.baseSalary, amount: input.baseSalary),
      if (input.allowances > 0) PayrollItemTypeAmount(type: PayrollItemType.allowance, amount: input.allowances),
      if (input.bonuses > 0) PayrollItemTypeAmount(type: PayrollItemType.bonus, amount: input.bonuses),
      if (input.commissions > 0) PayrollItemTypeAmount(type: PayrollItemType.commission, amount: input.commissions),
      if (input.overtime > 0) PayrollItemTypeAmount(type: PayrollItemType.overtime, amount: input.overtime),
      if (totalDeductions > 0) PayrollItemTypeAmount(type: PayrollItemType.deduction, amount: totalDeductions),
      if (tax > 0) PayrollItemTypeAmount(type: PayrollItemType.tax, amount: tax),
      PayrollItemTypeAmount(type: PayrollItemType.netPay, amount: net),
    ];

    return PayrollCalculationResult(
      employeeId: input.employeeId,
      gross: gross,
      deductions: totalDeductions,
      tax: tax,
      net: net,
      items: items,
    );
  }

  Result<void> validatePayrollRun(PayrollRun run, List<PayrollCalculationResult> lines) {
    if (lines.isEmpty) {
      return const Error(ValidationFailure(message: 'Payroll run has no employees', code: 'empty_payroll'));
    }
    final computedGross = _round(lines.fold(0.0, (s, l) => s + l.gross));
    final computedNet = _round(lines.fold(0.0, (s, l) => s + l.net));
    if ((computedGross - run.totalGross).abs() > 0.05 || (computedNet - run.totalNet).abs() > 0.05) {
      return const Error(ValidationFailure(message: 'Payroll totals do not match line items', code: 'payroll_mismatch'));
    }
    return const Success(null);
  }

  double sumDeductions(List<Deduction> deductions, double gross) {
    var total = 0.0;
    for (final d in deductions.where((x) => x.active)) {
      total += d.isPercentage ? gross * (d.amount / 100) : d.amount;
    }
    return _round(total);
  }

  void publishAttendanceRecorded({
    required String attendanceId,
    required String employeeId,
    String? tenantId,
    String? storeId,
  }) {
    _eventBus?.publish(AttendanceRecordedEvent(
      eventId: _uuid.v4(),
      occurredAt: DateTime.now().toUtc(),
      attendanceId: attendanceId,
      employeeId: employeeId,
      tenantId: tenantId,
      storeId: storeId,
    ));
  }

  void publishPayrollCalculated({
    required String payrollRunId,
    required double totalNet,
    String? tenantId,
  }) {
    _eventBus?.publish(PayrollCalculatedEvent(
      eventId: _uuid.v4(),
      occurredAt: DateTime.now().toUtc(),
      payrollRunId: payrollRunId,
      totalNetMinor: (totalNet * 100).round(),
      tenantId: tenantId,
    ));
  }

  void publishPayrollApproved({
    required String payrollRunId,
    required double totalGross,
    required double totalTax,
    required double totalNet,
    String? tenantId,
  }) {
    _eventBus?.publish(PayrollApprovedEvent(
      eventId: _uuid.v4(),
      occurredAt: DateTime.now().toUtc(),
      payrollRunId: payrollRunId,
      totalGrossMinor: (totalGross * 100).round(),
      totalTaxMinor: (totalTax * 100).round(),
      totalNetMinor: (totalNet * 100).round(),
      tenantId: tenantId,
    ));
  }

  void publishLeaveApproved({
    required String leaveRequestId,
    required String employeeId,
    required double days,
    String? tenantId,
  }) {
    _eventBus?.publish(LeaveApprovedEvent(
      eventId: _uuid.v4(),
      occurredAt: DateTime.now().toUtc(),
      leaveRequestId: leaveRequestId,
      employeeId: employeeId,
      days: days,
      tenantId: tenantId,
    ));
  }

  double _round(double v) => double.parse(v.toStringAsFixed(2));
}
