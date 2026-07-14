import 'package:flutter_test/flutter_test.dart';

import 'package:fashion_pos_enterprise/features/hr/data/datasources/hr_remote_datasource.dart';
import 'package:fashion_pos_enterprise/features/hr/data/sync/hr_sync_processor.dart';
import 'package:fashion_pos_enterprise/features/hr/domain/entities/attendance.dart';
import 'package:fashion_pos_enterprise/features/hr/domain/entities/employee.dart';
import 'package:fashion_pos_enterprise/features/hr/domain/entities/leave.dart';
import 'package:fashion_pos_enterprise/features/hr/domain/entities/payroll.dart';

void main() {
  test('HR sync processors map entity types to remote tables', () {
    final remote = HrRemoteDataSource();
    final employees = HrSyncProcessor(remote: remote, entityTypeName: Employee.entityTypeName, remoteTable: 'employees');
    final attendance = HrSyncProcessor(remote: remote, entityTypeName: AttendanceRecord.entityTypeName, remoteTable: 'attendance_records');
    final payroll = HrSyncProcessor(remote: remote, entityTypeName: PayrollRun.entityTypeName, remoteTable: 'payroll_runs');
    final leave = HrSyncProcessor(remote: remote, entityTypeName: LeaveRequest.entityTypeName, remoteTable: 'leave_requests');

    expect(employees.entityType, 'employee');
    expect(attendance.entityType, 'attendance_record');
    expect(payroll.entityType, 'payroll_run');
    expect(leave.entityType, 'leave_request');
  });
}
