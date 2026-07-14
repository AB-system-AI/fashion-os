import 'package:fashion_pos_enterprise/core/infrastructure/pagination/paginated_result.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/repository/base_local_repository.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/repository/repository_query.dart';
import 'package:fashion_pos_enterprise/features/hr/domain/entities/attendance.dart';
import 'package:fashion_pos_enterprise/features/hr/domain/entities/documents.dart';
import 'package:fashion_pos_enterprise/features/hr/domain/entities/employee.dart';
import 'package:fashion_pos_enterprise/features/hr/domain/entities/leave.dart';
import 'package:fashion_pos_enterprise/features/hr/domain/entities/organization.dart';
import 'package:fashion_pos_enterprise/features/hr/domain/entities/payroll.dart';
import 'package:fashion_pos_enterprise/features/hr/domain/enums/hr_enums.dart';

abstract class EmployeeRepository implements BaseLocalRepository<Employee> {
  Future<Employee?> findByCode(String tenantId, String employeeCode);
  Future<PaginatedResult<Employee>> getPage(RepositoryQuery query);
  Future<Department> createDepartment(Department department);
  Future<Position> createPosition(Position position);
  Future<Department?> findDepartmentByCode(String tenantId, String code);
  Future<List<Employee>> listByDepartment(String tenantId, String departmentId);
  Future<SalaryStructure> createSalaryStructure(SalaryStructure structure);
  Future<PerformanceReview> createPerformanceReview(PerformanceReview review);
  Future<EmployeeDocument> createDocument(EmployeeDocument document);
}

abstract class AttendanceRepository implements BaseLocalRepository<AttendanceRecord> {
  Future<List<AttendanceRecord>> listByEmployee(String tenantId, String employeeId, {int limit = 100});
  Future<List<AttendanceRecord>> listByDateRange(String tenantId, DateTime from, DateTime to);
  Future<Shift> createShift(Shift shift);
  Future<List<Shift>> listShiftsForEmployee(String tenantId, String employeeId);
  Future<OvertimeRecord> createOvertime(OvertimeRecord record);
  Future<List<OvertimeRecord>> listOvertime(String tenantId, String employeeId);
}

abstract class PayrollRepository implements BaseLocalRepository<PayrollRun> {
  Future<PayrollRun?> findByRunNumber(String tenantId, String runNumber);
  Future<List<PayrollRun>> listByPeriod(String tenantId, String payrollPeriodId);
  Future<PayrollPeriod> createPeriod(PayrollPeriod period);
  Future<PayrollItem> createPayrollItem(PayrollItem item);
  Future<List<PayrollItem>> listItemsForRun(String tenantId, String payrollRunId);
  Future<Bonus> createBonus(Bonus bonus);
  Future<Deduction> createDeduction(Deduction deduction);
  Future<Allowance> createAllowance(Allowance allowance);
  Future<Commission> createCommission(Commission commission);
  Future<List<Commission>> listPendingCommissions(String tenantId, String employeeId);
}

abstract class LeaveRepository implements BaseLocalRepository<LeaveRequest> {
  Future<List<LeaveRequest>> listByEmployee(String tenantId, String employeeId);
  Future<List<LeaveRequest>> listByStatus(String tenantId, LeaveStatus status);
  Future<LeaveBalance?> findBalance(String tenantId, String employeeId, LeaveType type, int year);
  Future<LeaveBalance> upsertBalance(LeaveBalance balance);
}
