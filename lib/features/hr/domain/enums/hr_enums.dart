enum EmployeeStatus {
  active,
  inactive,
  suspended,
  terminated;

  String get value => name;

  static EmployeeStatus fromValue(String? v) =>
      EmployeeStatus.values.firstWhere((e) => e.name == v, orElse: () => EmployeeStatus.active);
}

enum AttendanceStatus {
  present,
  absent,
  late,
  halfDay,
  onLeave,
  holiday;

  String get value => name;

  static AttendanceStatus fromValue(String? v) =>
      AttendanceStatus.values.firstWhere((e) => e.name == v, orElse: () => AttendanceStatus.present);
}

enum LeaveStatus {
  pending,
  approved,
  rejected,
  cancelled;

  String get value => name;

  static LeaveStatus fromValue(String? v) =>
      LeaveStatus.values.firstWhere((e) => e.name == v, orElse: () => LeaveStatus.pending);
}

enum LeaveType {
  annual,
  sick,
  unpaid,
  maternity,
  emergency;

  String get value => name;

  static LeaveType fromValue(String? v) =>
      LeaveType.values.firstWhere((e) => e.name == v, orElse: () => LeaveType.annual);
}

enum PayrollRunStatus {
  draft,
  calculated,
  approved,
  paid,
  cancelled;

  String get value => name;

  static PayrollRunStatus fromValue(String? v) =>
      PayrollRunStatus.values.firstWhere((e) => e.name == v, orElse: () => PayrollRunStatus.draft);
}

enum PayrollItemType {
  baseSalary,
  allowance,
  bonus,
  commission,
  overtime,
  deduction,
  tax,
  netPay;

  String get value => name;

  static PayrollItemType fromValue(String? v) =>
      PayrollItemType.values.firstWhere((e) => e.name == v, orElse: () => PayrollItemType.baseSalary);
}

enum ShiftStatus {
  scheduled,
  open,
  closed,
  cancelled;

  String get value => name;

  static ShiftStatus fromValue(String? v) =>
      ShiftStatus.values.firstWhere((e) => e.name == v, orElse: () => ShiftStatus.scheduled);
}

enum PerformanceRating {
  needsImprovement,
  meetsExpectations,
  exceedsExpectations,
  outstanding;

  String get value => name;

  static PerformanceRating fromValue(String? v) =>
      PerformanceRating.values.firstWhere((e) => e.name == v, orElse: () => PerformanceRating.meetsExpectations);
}

enum DocumentCategory {
  contract,
  id,
  certificate,
  policy,
  other;

  String get value => name;

  static DocumentCategory fromValue(String? v) =>
      DocumentCategory.values.firstWhere((e) => e.name == v, orElse: () => DocumentCategory.other);
}
