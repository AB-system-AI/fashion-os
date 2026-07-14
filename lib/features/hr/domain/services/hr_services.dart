import 'package:uuid/uuid.dart';

import 'package:fashion_pos_enterprise/core/audit/audit_action.dart';
import 'package:fashion_pos_enterprise/core/audit/audit_service.dart';
import 'package:fashion_pos_enterprise/core/business/domain/enums/business_enums.dart';
import 'package:fashion_pos_enterprise/core/business/engines/hr/hr_engine.dart';
import 'package:fashion_pos_enterprise/core/business/engines/number_generator_engine.dart';
import 'package:fashion_pos_enterprise/core/errors/failure.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/pagination/paginated_result.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/repository/repository_query.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_engine.dart';
import 'package:fashion_pos_enterprise/core/result/result.dart';
import 'package:fashion_pos_enterprise/features/auth/domain/entities/auth_user.dart';
import 'package:fashion_pos_enterprise/features/hr/domain/entities/attendance.dart';
import 'package:fashion_pos_enterprise/features/hr/domain/entities/documents.dart';
import 'package:fashion_pos_enterprise/features/hr/domain/entities/employee.dart';
import 'package:fashion_pos_enterprise/features/hr/domain/entities/leave.dart';
import 'package:fashion_pos_enterprise/features/hr/domain/entities/payroll.dart';
import 'package:fashion_pos_enterprise/features/hr/domain/enums/hr_enums.dart';
import 'package:fashion_pos_enterprise/features/hr/domain/repositories/hr_repositories.dart';

class EmployeeService {
  EmployeeService({
    required EmployeeRepository repository,
    required HREngine engine,
    required AuditService audit,
    required PermissionEngine permissions,
  })  : _repo = repository,
        _engine = engine,
        _audit = audit,
        _permissions = permissions;

  final EmployeeRepository _repo;
  final HREngine _engine;
  final AuditService _audit;
  final PermissionEngine _permissions;

  Future<Result<Employee>> create({required AuthUser user, required Employee employee}) async {
    try {
      _permissions.require(user, EmployeePermissions.manage);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final availability = _engine.validateEmployeeAvailable(employee, DateTime.now().toUtc());
    if (availability.isFailure) return Error(availability.failureOrNull!);
    final saved = await _repo.create(employee);
    await _audit.log(
      action: AuditAction.create,
      entityType: Employee.entityTypeName,
      tenantId: saved.tenantId,
      employeeId: user.employeeId,
      entityId: saved.id,
    );
    return Success(saved);
  }

  Future<Result<Employee>> update({required AuthUser user, required Employee employee}) async {
    try {
      _permissions.require(user, EmployeePermissions.manage);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final saved = await _repo.update(employee);
    await _audit.log(
      action: AuditAction.update,
      entityType: Employee.entityTypeName,
      tenantId: saved.tenantId,
      employeeId: user.employeeId,
      entityId: saved.id,
    );
    return Success(saved);
  }

  Future<PaginatedResult<Employee>> list(String tenantId, {int page = 1}) =>
      _repo.getPage(RepositoryQuery(tenantId: tenantId, page: page, pageSize: 50));
}

class AttendanceService {
  AttendanceService({
    required AttendanceRepository repository,
    required EmployeeRepository employees,
    required HREngine engine,
    required AuditService audit,
    required PermissionEngine permissions,
    Uuid? uuid,
  })  : _repo = repository,
        _employees = employees,
        _engine = engine,
        _audit = audit,
        _permissions = permissions,
        _uuid = uuid ?? const Uuid();

  final AttendanceRepository _repo;
  final EmployeeRepository _employees;
  final HREngine _engine;
  final AuditService _audit;
  final PermissionEngine _permissions;
  final Uuid _uuid;

  Future<Result<AttendanceRecord>> clockIn({
    required AuthUser user,
    required String employeeId,
    required String storeId,
    DateTime? scheduledStart,
    DateTime? scheduledEnd,
  }) async {
    try {
      _permissions.require(user, AttendancePermissions.manage);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }

    final employee = await _employees.getById(employeeId, tenantId: user.tenantId!);
    if (employee == null) {
      return const Error(ValidationFailure(message: 'Employee not found', code: 'not_found'));
    }
    final availability = _engine.validateEmployeeAvailable(employee, DateTime.now().toUtc());
    if (availability.isFailure) return Error(availability.failureOrNull!);

    final now = DateTime.now().toUtc();
    final start = scheduledStart ?? now;
    final end = scheduledEnd ?? now.add(const Duration(hours: 8));
    final calc = _engine.calculateAttendance(scheduledStart: start, scheduledEnd: end, clockIn: now, clockOut: null);

    final record = AttendanceRecord(
      id: _uuid.v4(),
      tenantId: user.tenantId!,
      employeeId: employeeId,
      storeId: storeId,
      recordDate: DateTime.utc(now.year, now.month, now.day),
      clockIn: now,
      status: calc.status,
      lateMinutes: calc.lateMinutes,
      workedMinutes: calc.workedMinutes,
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    );

    final saved = await _repo.create(record);
    _engine.publishAttendanceRecorded(
      attendanceId: saved.id,
      employeeId: employeeId,
      tenantId: user.tenantId,
      storeId: storeId,
    );
    await _audit.log(
      action: AuditAction.create,
      entityType: AttendanceRecord.entityTypeName,
      tenantId: saved.tenantId,
      employeeId: user.employeeId,
      entityId: saved.id,
    );
    return Success(saved);
  }

  Future<List<AttendanceRecord>> history(String tenantId, String employeeId) =>
      _repo.listByEmployee(tenantId, employeeId);
}

class ShiftService {
  ShiftService({
    required AttendanceRepository repository,
    required HREngine engine,
    required AuditService audit,
    required PermissionEngine permissions,
  })  : _repo = repository,
        _engine = engine,
        _audit = audit,
        _permissions = permissions;

  final AttendanceRepository _repo;
  final HREngine _engine;
  final AuditService _audit;
  final PermissionEngine _permissions;

  Future<Result<Shift>> schedule({required AuthUser user, required Shift shift}) async {
    try {
      _permissions.require(user, AttendancePermissions.manage);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final validation = _engine.validateShift(shift);
    if (validation.isFailure) return Error(validation.failureOrNull!);
    final saved = await _repo.createShift(shift);
    await _audit.log(
      action: AuditAction.create,
      entityType: Shift.entityTypeName,
      tenantId: saved.tenantId,
      employeeId: user.employeeId,
      entityId: saved.id,
    );
    return Success(saved);
  }
}

class LeaveService {
  LeaveService({
    required LeaveRepository repository,
    required HREngine engine,
    required AuditService audit,
    required PermissionEngine permissions,
  })  : _repo = repository,
        _engine = engine,
        _audit = audit,
        _permissions = permissions;

  final LeaveRepository _repo;
  final HREngine _engine;
  final AuditService _audit;
  final PermissionEngine _permissions;

  Future<Result<LeaveRequest>> request({required AuthUser user, required LeaveRequest request}) async {
    try {
      _permissions.require(user, LeavePermissions.manage);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final saved = await _repo.create(request);
    await _audit.log(
      action: AuditAction.create,
      entityType: LeaveRequest.entityTypeName,
      tenantId: saved.tenantId,
      employeeId: user.employeeId,
      entityId: saved.id,
    );
    return Success(saved);
  }

  Future<Result<LeaveRequest>> approve({required AuthUser user, required LeaveRequest request}) async {
    try {
      _permissions.require(user, LeavePermissions.manage);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final now = DateTime.now().toUtc();
    final saved = await _repo.update(request.copyWith(
      status: LeaveStatus.approved,
      approvedBy: user.employeeId,
      approvedAt: now,
      version: request.version + 1,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    ));
    _engine.publishLeaveApproved(
      leaveRequestId: saved.id,
      employeeId: saved.employeeId,
      days: saved.days,
      tenantId: saved.tenantId,
    );
    await _audit.log(
      action: AuditAction.update,
      entityType: LeaveRequest.entityTypeName,
      tenantId: saved.tenantId,
      employeeId: user.employeeId,
      entityId: saved.id,
      metadata: {'status': 'approved'},
    );
    return Success(saved);
  }
}

class PayrollService {
  PayrollService({
    required PayrollRepository repository,
    required EmployeeRepository employees,
    required HREngine engine,
    required AuditService audit,
    required PermissionEngine permissions,
    required NumberGeneratorEngine numberGenerator,
    Uuid? uuid,
  })  : _repo = repository,
        _employees = employees,
        _engine = engine,
        _audit = audit,
        _permissions = permissions,
        _numbers = numberGenerator,
        _uuid = uuid ?? const Uuid();

  final PayrollRepository _repo;
  final EmployeeRepository _employees;
  final HREngine _engine;
  final AuditService _audit;
  final PermissionEngine _permissions;
  final NumberGeneratorEngine _numbers;
  final Uuid _uuid;

  Future<Result<PayrollRun>> calculateRun({
    required AuthUser user,
    required String payrollPeriodId,
    double taxRate = 0.1,
  }) async {
    try {
      _permissions.require(user, PayrollPermissions.manage);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }

    final tenantId = user.tenantId!;
    final numberResult = await _numbers.next(type: DocumentNumberType.payrollRun, tenantId: tenantId);
    if (numberResult.isFailure) return Error(numberResult.failureOrNull!);

    final now = DateTime.now().toUtc();
    final page = await _employees.getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    final calculations = <PayrollCalculationResult>[];

    for (final emp in page.items.where((e) => e.status == EmployeeStatus.active)) {
      final commissions = await _repo.listPendingCommissions(tenantId, emp.id);
      final commissionTotal = commissions.fold(0.0, (s, c) => s + c.amount);
      calculations.add(_engine.calculatePayroll(PayrollLineInput(
        employeeId: emp.id,
        baseSalary: emp.baseSalary,
        commissions: commissionTotal,
        taxRate: taxRate,
      )));
    }

    final totalGross = calculations.fold(0.0, (s, c) => s + c.gross);
    final totalDeductions = calculations.fold(0.0, (s, c) => s + c.deductions);
    final totalTax = calculations.fold(0.0, (s, c) => s + c.tax);
    final totalNet = calculations.fold(0.0, (s, c) => s + c.net);

    var run = PayrollRun(
      id: _uuid.v4(),
      tenantId: tenantId,
      payrollPeriodId: payrollPeriodId,
      runNumber: numberResult.dataOrNull!.value,
      status: PayrollRunStatus.calculated,
      totalGross: totalGross,
      totalDeductions: totalDeductions,
      totalTax: totalTax,
      totalNet: totalNet,
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    );

    final validation = _engine.validatePayrollRun(run, calculations);
    if (validation.isFailure) return Error(validation.failureOrNull!);

    run = await _repo.create(run);
    for (final calc in calculations) {
      for (final item in calc.items) {
        await _repo.createPayrollItem(PayrollItem(
          id: _uuid.v4(),
          tenantId: tenantId,
          payrollRunId: run.id,
          employeeId: calc.employeeId,
          itemType: item.type,
          amount: item.amount,
          description: item.description,
          version: 1,
          createdAt: now,
          updatedAt: now,
          syncStatus: LocalSyncStatus.pending,
          isDirty: true,
        ));
      }
    }

    _engine.publishPayrollCalculated(payrollRunId: run.id, totalNet: totalNet, tenantId: tenantId);
    await _audit.log(
      action: AuditAction.create,
      entityType: PayrollRun.entityTypeName,
      tenantId: tenantId,
      employeeId: user.employeeId,
      entityId: run.id,
      metadata: {'run_number': run.runNumber, 'total_net': totalNet},
    );
    return Success(run);
  }

  Future<Result<PayrollRun>> approve({required AuthUser user, required PayrollRun run}) async {
    try {
      _permissions.require(user, PayrollPermissions.approve);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final now = DateTime.now().toUtc();
    final saved = await _repo.update(run.copyWith(
      status: PayrollRunStatus.approved,
      approvedAt: now,
      approvedBy: user.employeeId,
      version: run.version + 1,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    ));
    _engine.publishPayrollApproved(
      payrollRunId: saved.id,
      totalGross: saved.totalGross,
      totalTax: saved.totalTax,
      totalNet: saved.totalNet,
      tenantId: saved.tenantId,
    );
    await _audit.log(
      action: AuditAction.update,
      entityType: PayrollRun.entityTypeName,
      tenantId: saved.tenantId,
      employeeId: user.employeeId,
      entityId: saved.id,
      metadata: {'status': 'approved'},
    );
    return Success(saved);
  }
}

class SalaryService {
  SalaryService({
    required EmployeeRepository repository,
    required AuditService audit,
    required PermissionEngine permissions,
  })  : _repo = repository,
        _audit = audit,
        _permissions = permissions;

  final EmployeeRepository _repo;
  final AuditService _audit;
  final PermissionEngine _permissions;

  Future<Result<SalaryStructure>> saveStructure({required AuthUser user, required SalaryStructure structure}) async {
    try {
      _permissions.require(user, PayrollPermissions.manage);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final saved = await _repo.createSalaryStructure(structure);
    await _audit.log(
      action: AuditAction.create,
      entityType: SalaryStructure.entityTypeName,
      tenantId: saved.tenantId,
      employeeId: user.employeeId,
      entityId: saved.id,
    );
    return Success(saved);
  }
}

class CommissionService {
  CommissionService({
    required PayrollRepository repository,
    required HREngine engine,
    required AuditService audit,
    required PermissionEngine permissions,
    Uuid? uuid,
  })  : _repo = repository,
        _engine = engine,
        _audit = audit,
        _permissions = permissions,
        _uuid = uuid ?? const Uuid();

  final PayrollRepository _repo;
  final HREngine _engine;
  final AuditService _audit;
  final PermissionEngine _permissions;
  final Uuid _uuid;

  Future<Result<Commission>> recordFromSale({
    required AuthUser user,
    required String employeeId,
    required String saleId,
    required double saleTotal,
    double? rate,
  }) async {
    try {
      _permissions.require(user, CommissionPermissions.manage);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final now = DateTime.now().toUtc();
    final amount = _engine.calculateCommission(saleTotal: saleTotal, rate: rate ?? HREngine.defaultCommissionRate);
    final saved = await _repo.createCommission(Commission(
      id: _uuid.v4(),
      tenantId: user.tenantId!,
      employeeId: employeeId,
      amount: amount,
      commissionDate: now,
      saleId: saleId,
      ratePercent: (rate ?? HREngine.defaultCommissionRate) * 100,
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    ));
    await _audit.log(
      action: AuditAction.create,
      entityType: Commission.entityTypeName,
      tenantId: saved.tenantId,
      employeeId: user.employeeId,
      entityId: saved.id,
      metadata: {'sale_id': saleId, 'amount': amount},
    );
    return Success(saved);
  }
}

class PerformanceService {
  PerformanceService({
    required EmployeeRepository repository,
    required AuditService audit,
    required PermissionEngine permissions,
  })  : _repo = repository,
        _audit = audit,
        _permissions = permissions;

  final EmployeeRepository _repo;
  final AuditService _audit;
  final PermissionEngine _permissions;

  Future<Result<PerformanceReview>> saveReview({required AuthUser user, required PerformanceReview review}) async {
    try {
      _permissions.require(user, PerformancePermissions.manage);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final saved = await _repo.createPerformanceReview(review);
    await _audit.log(
      action: AuditAction.create,
      entityType: PerformanceReview.entityTypeName,
      tenantId: saved.tenantId,
      employeeId: user.employeeId,
      entityId: saved.id,
    );
    return Success(saved);
  }
}

class DocumentService {
  DocumentService({
    required EmployeeRepository repository,
    required AuditService audit,
    required PermissionEngine permissions,
  })  : _repo = repository,
        _audit = audit,
        _permissions = permissions;

  final EmployeeRepository _repo;
  final AuditService _audit;
  final PermissionEngine _permissions;

  Future<Result<EmployeeDocument>> upload({required AuthUser user, required EmployeeDocument document}) async {
    try {
      _permissions.require(user, EmployeePermissions.manage);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final saved = await _repo.createDocument(document);
    await _audit.log(
      action: AuditAction.create,
      entityType: EmployeeDocument.entityTypeName,
      tenantId: saved.tenantId,
      employeeId: user.employeeId,
      entityId: saved.id,
    );
    return Success(saved);
  }
}
