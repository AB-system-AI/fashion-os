import 'package:flutter_test/flutter_test.dart';

import 'package:fashion_pos_enterprise/core/business/engines/hr/hr_engine.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/features/hr/domain/entities/attendance.dart';
import 'package:fashion_pos_enterprise/features/hr/domain/entities/employee.dart';
import 'package:fashion_pos_enterprise/features/hr/domain/enums/hr_enums.dart';

void main() {
  late HREngine engine;

  setUp(() {
    engine = HREngine();
  });

  test('calculatePayroll computes gross, tax, and net', () {
    final result = engine.calculatePayroll(const PayrollLineInput(
      employeeId: 'e1',
      baseSalary: 3000,
      allowances: 200,
      commissions: 100,
      taxRate: 0.1,
    ));
    expect(result.gross, 3300);
    expect(result.tax, 330);
    expect(result.net, 2970);
  });

  test('calculateAttendance detects late arrival', () {
    final start = DateTime.utc(2025, 7, 1, 9);
    final end = DateTime.utc(2025, 7, 1, 17);
    final clockIn = DateTime.utc(2025, 7, 1, 9, 20);
    final calc = engine.calculateAttendance(
      scheduledStart: start,
      scheduledEnd: end,
      clockIn: clockIn,
      clockOut: end,
    );
    expect(calc.status, AttendanceStatus.late);
    expect(calc.lateMinutes, greaterThan(0));
  });

  test('validateShift rejects end before start', () {
    final shift = Shift(
      id: 's1',
      tenantId: 't1',
      employeeId: 'e1',
      storeId: 'st1',
      startTime: DateTime.utc(2025, 7, 1, 17),
      endTime: DateTime.utc(2025, 7, 1, 9),
      version: 1,
      createdAt: DateTime.utc(2025),
      updatedAt: DateTime.utc(2025),
      syncStatus: LocalSyncStatus.synced,
      isDirty: false,
    );
    expect(engine.validateShift(shift).isFailure, isTrue);
  });

  test('validateEmployeeAvailable rejects terminated employee', () {
    final employee = Employee(
      id: 'e1',
      tenantId: 't1',
      employeeCode: 'EMP-001',
      firstName: 'A',
      lastName: 'B',
      status: EmployeeStatus.terminated,
      terminatedAt: DateTime.utc(2025, 1, 1),
      version: 1,
      createdAt: DateTime.utc(2025),
      updatedAt: DateTime.utc(2025),
      syncStatus: LocalSyncStatus.synced,
      isDirty: false,
    );
    expect(engine.validateEmployeeAvailable(employee, DateTime.utc(2025, 6, 1)).isFailure, isTrue);
  });

  test('calculateCommission uses default rate', () {
    expect(engine.calculateCommission(saleTotal: 1000), 20);
  });
}
