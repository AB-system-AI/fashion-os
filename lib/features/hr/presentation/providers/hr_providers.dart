import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fashion_pos_enterprise/core/audit/audit_providers.dart';
import 'package:fashion_pos_enterprise/core/business/di/business_providers.dart';
import 'package:fashion_pos_enterprise/core/di/enterprise_providers.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/features/hr/data/datasources/hr_remote_datasource.dart';
import 'package:fashion_pos_enterprise/features/hr/data/repositories/hr_repository_impl.dart';
import 'package:fashion_pos_enterprise/features/hr/data/sync/hr_sync_processor.dart';
import 'package:fashion_pos_enterprise/features/hr/domain/entities/attendance.dart';
import 'package:fashion_pos_enterprise/features/hr/domain/entities/employee.dart';
import 'package:fashion_pos_enterprise/features/hr/domain/entities/leave.dart';
import 'package:fashion_pos_enterprise/features/hr/domain/entities/payroll.dart';
import 'package:fashion_pos_enterprise/features/hr/domain/repositories/hr_repositories.dart';
import 'package:fashion_pos_enterprise/features/hr/domain/services/hr_integration_service.dart';
import 'package:fashion_pos_enterprise/features/hr/domain/services/hr_services.dart';

final hrRemoteDataSourceProvider = Provider<HrRemoteDataSource>((ref) => HrRemoteDataSource());

final employeeRepositoryProvider = Provider<EmployeeRepository>((ref) {
  return EmployeeLocalRepository(
    database: ref.watch(appDatabaseProvider),
    syncQueue: ref.watch(syncQueueWriterProvider),
  );
});

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  return AttendanceLocalRepository(
    database: ref.watch(appDatabaseProvider),
    syncQueue: ref.watch(syncQueueWriterProvider),
  );
});

final payrollRepositoryProvider = Provider<PayrollRepository>((ref) {
  return PayrollLocalRepository(
    database: ref.watch(appDatabaseProvider),
    syncQueue: ref.watch(syncQueueWriterProvider),
  );
});

final leaveRepositoryProvider = Provider<LeaveRepository>((ref) {
  return LeaveLocalRepository(
    database: ref.watch(appDatabaseProvider),
    syncQueue: ref.watch(syncQueueWriterProvider),
  );
});

final employeeServiceProvider = Provider<EmployeeService>((ref) {
  return EmployeeService(
    repository: ref.watch(employeeRepositoryProvider),
    engine: ref.watch(hrEngineProvider),
    audit: ref.watch(auditServiceProvider),
    permissions: ref.watch(permissionEngineProvider),
  );
});

final attendanceServiceProvider = Provider<AttendanceService>((ref) {
  return AttendanceService(
    repository: ref.watch(attendanceRepositoryProvider),
    employees: ref.watch(employeeRepositoryProvider),
    engine: ref.watch(hrEngineProvider),
    audit: ref.watch(auditServiceProvider),
    permissions: ref.watch(permissionEngineProvider),
  );
});

final shiftServiceProvider = Provider<ShiftService>((ref) {
  return ShiftService(
    repository: ref.watch(attendanceRepositoryProvider),
    engine: ref.watch(hrEngineProvider),
    audit: ref.watch(auditServiceProvider),
    permissions: ref.watch(permissionEngineProvider),
  );
});

final leaveServiceProvider = Provider<LeaveService>((ref) {
  return LeaveService(
    repository: ref.watch(leaveRepositoryProvider),
    engine: ref.watch(hrEngineProvider),
    audit: ref.watch(auditServiceProvider),
    permissions: ref.watch(permissionEngineProvider),
  );
});

final payrollServiceProvider = Provider<PayrollService>((ref) {
  return PayrollService(
    repository: ref.watch(payrollRepositoryProvider),
    employees: ref.watch(employeeRepositoryProvider),
    engine: ref.watch(hrEngineProvider),
    audit: ref.watch(auditServiceProvider),
    permissions: ref.watch(permissionEngineProvider),
    numberGenerator: ref.watch(numberGeneratorEngineProvider),
  );
});

final salaryServiceProvider = Provider<SalaryService>((ref) {
  return SalaryService(
    repository: ref.watch(employeeRepositoryProvider),
    audit: ref.watch(auditServiceProvider),
    permissions: ref.watch(permissionEngineProvider),
  );
});

final commissionServiceProvider = Provider<CommissionService>((ref) {
  return CommissionService(
    repository: ref.watch(payrollRepositoryProvider),
    engine: ref.watch(hrEngineProvider),
    audit: ref.watch(auditServiceProvider),
    permissions: ref.watch(permissionEngineProvider),
  );
});

final performanceServiceProvider = Provider<PerformanceService>((ref) {
  return PerformanceService(
    repository: ref.watch(employeeRepositoryProvider),
    audit: ref.watch(auditServiceProvider),
    permissions: ref.watch(permissionEngineProvider),
  );
});

final documentServiceProvider = Provider<DocumentService>((ref) {
  return DocumentService(
    repository: ref.watch(employeeRepositoryProvider),
    audit: ref.watch(auditServiceProvider),
    permissions: ref.watch(permissionEngineProvider),
  );
});

final hrIntegrationServiceProvider = Provider<HrIntegrationService>((ref) {
  return HrIntegrationService(
    eventBus: ref.watch(domainEventBusProvider),
    employeeRepository: ref.watch(employeeRepositoryProvider),
    engine: ref.watch(hrEngineProvider),
  );
});

HrSyncProcessor _processor(Ref ref, String entityType, String table) => HrSyncProcessor(
      remote: ref.watch(hrRemoteDataSourceProvider),
      entityTypeName: entityType,
      remoteTable: table,
    );

final employeeSyncProcessorProvider = Provider<EmployeeSyncProcessor>(
  (ref) => _processor(ref, Employee.entityTypeName, 'employees'),
);

final attendanceSyncProcessorProvider = Provider<AttendanceSyncProcessor>(
  (ref) => _processor(ref, AttendanceRecord.entityTypeName, 'attendance_records'),
);

final payrollSyncProcessorProvider = Provider<PayrollSyncProcessor>(
  (ref) => _processor(ref, PayrollRun.entityTypeName, 'payroll_runs'),
);

final leaveSyncProcessorProvider = Provider<LeaveSyncProcessor>(
  (ref) => _processor(ref, LeaveRequest.entityTypeName, 'leave_requests'),
);
