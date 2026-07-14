import 'package:fashion_pos_enterprise/core/infrastructure/database/app_database.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/pagination/paginated_result.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/repository/base_local_repository.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/repository/repository_query.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/sync/sync_queue_writer.dart';
import 'package:fashion_pos_enterprise/features/hr/domain/entities/attendance.dart';
import 'package:fashion_pos_enterprise/features/hr/domain/entities/documents.dart';
import 'package:fashion_pos_enterprise/features/hr/domain/entities/employee.dart';
import 'package:fashion_pos_enterprise/features/hr/domain/entities/leave.dart';
import 'package:fashion_pos_enterprise/features/hr/domain/entities/organization.dart';
import 'package:fashion_pos_enterprise/features/hr/domain/entities/payroll.dart';
import 'package:fashion_pos_enterprise/features/hr/domain/enums/hr_enums.dart';
import 'package:fashion_pos_enterprise/features/hr/domain/repositories/hr_repositories.dart';

typedef HrEntityMapper<T> = T Function(Map<String, dynamic> json, LocalRecord record);

class HrRepositoryImpl<T extends SyncableEntity> extends BaseLocalRepository<T> {
  HrRepositoryImpl({
    required AppDatabase database,
    required SyncQueueWriter syncQueue,
    required String entityType,
    required this.fromPayload,
    required this.toSearchFields,
  }) : super(database: database, entityType: entityType, syncQueue: syncQueue);

  final HrEntityMapper<T> fromPayload;
  final ({String? name, String? sku, String? barcode, String? storeId}) Function(T entity) toSearchFields;

  @override
  T mapFromLocalRecord(LocalRecord record) => fromPayload(record.payload, record);

  @override
  LocalRecord mapToLocalRecord(T entity) {
    final search = toSearchFields(entity);
    return LocalRecord(
      id: entity.id,
      tenantId: entity.tenantId,
      entityType: entity.entityType,
      storeId: search.storeId,
      payload: entity.toPayload(),
      version: entity.version,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      deletedAt: entity.deletedAt,
      syncStatus: entity.syncStatus,
      isDirty: entity.isDirty,
      searchName: search.name,
      searchSku: search.sku,
      searchBarcode: search.barcode,
    );
  }
}

class EmployeeLocalRepository extends HrRepositoryImpl<Employee> implements EmployeeRepository {
  EmployeeLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : _db = database,
        _syncQueue = syncQueue,
        super(
          database: database,
          syncQueue: syncQueue,
          entityType: Employee.entityTypeName,
          fromPayload: Employee.fromPayload,
          toSearchFields: (e) => (name: e.fullName, sku: e.employeeCode, barcode: null, storeId: e.storeId),
        );

  final AppDatabase _db;
  final SyncQueueWriter _syncQueue;

  @override
  Future<Employee?> findByCode(String tenantId, String employeeCode) async {
    final records = await _db.syncableRecordDao.getPage(
      RepositoryQuery(tenantId: tenantId, entityType: Employee.entityTypeName, search: employeeCode, pageSize: 20),
    );
    for (final r in records) {
      final e = mapFromLocalRecord(r);
      if (e.employeeCode == employeeCode) return e;
    }
    return null;
  }

  @override
  Future<PaginatedResult<Employee>> getPage(RepositoryQuery query) => super.getPage(query);

  @override
  Future<List<Employee>> listByDepartment(String tenantId, String departmentId) async {
    final records = await _db.syncableRecordDao.getPage(
      RepositoryQuery(tenantId: tenantId, entityType: Employee.entityTypeName, pageSize: 500),
    );
    return records.map(mapFromLocalRecord).where((e) => e.departmentId == departmentId).toList();
  }

  @override
  Future<Department> createDepartment(Department department) => HrRepositoryImpl<Department>(
        database: _db,
        syncQueue: _syncQueue,
        entityType: Department.entityTypeName,
        fromPayload: Department.fromPayload,
        toSearchFields: (e) => (name: e.name, sku: e.code, barcode: null, storeId: null),
      ).create(department);

  @override
  Future<Position> createPosition(Position position) => HrRepositoryImpl<Position>(
        database: _db,
        syncQueue: _syncQueue,
        entityType: Position.entityTypeName,
        fromPayload: Position.fromPayload,
        toSearchFields: (e) => (name: e.name, sku: e.code, barcode: null, storeId: null),
      ).create(position);

  @override
  Future<Department?> findDepartmentByCode(String tenantId, String code) async {
    final records = await _db.syncableRecordDao.getPage(
      RepositoryQuery(tenantId: tenantId, entityType: Department.entityTypeName, search: code, pageSize: 20),
    );
    for (final r in records) {
      final d = Department.fromPayload(r.payload, r);
      if (d.code == code) return d;
    }
    return null;
  }

  @override
  Future<SalaryStructure> createSalaryStructure(SalaryStructure structure) => HrRepositoryImpl<SalaryStructure>(
        database: _db,
        syncQueue: _syncQueue,
        entityType: SalaryStructure.entityTypeName,
        fromPayload: SalaryStructure.fromPayload,
        toSearchFields: (e) => (name: e.employeeId, sku: null, barcode: null, storeId: null),
      ).create(structure);

  @override
  Future<PerformanceReview> createPerformanceReview(PerformanceReview review) => HrRepositoryImpl<PerformanceReview>(
        database: _db,
        syncQueue: _syncQueue,
        entityType: PerformanceReview.entityTypeName,
        fromPayload: PerformanceReview.fromPayload,
        toSearchFields: (e) => (name: e.employeeId, sku: null, barcode: null, storeId: null),
      ).create(review);

  @override
  Future<EmployeeDocument> createDocument(EmployeeDocument document) => HrRepositoryImpl<EmployeeDocument>(
        database: _db,
        syncQueue: _syncQueue,
        entityType: EmployeeDocument.entityTypeName,
        fromPayload: EmployeeDocument.fromPayload,
        toSearchFields: (e) => (name: e.title, sku: e.employeeId, barcode: null, storeId: null),
      ).create(document);
}

class AttendanceLocalRepository extends HrRepositoryImpl<AttendanceRecord> implements AttendanceRepository {
  AttendanceLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : _db = database,
        _syncQueue = syncQueue,
        super(
          database: database,
          syncQueue: syncQueue,
          entityType: AttendanceRecord.entityTypeName,
          fromPayload: AttendanceRecord.fromPayload,
          toSearchFields: (e) => (name: e.employeeId, sku: null, barcode: null, storeId: e.storeId),
        );

  final AppDatabase _db;
  final SyncQueueWriter _syncQueue;

  @override
  Future<List<AttendanceRecord>> listByEmployee(String tenantId, String employeeId, {int limit = 100}) async {
    final records = await _db.syncableRecordDao.getPage(
      RepositoryQuery(tenantId: tenantId, entityType: AttendanceRecord.entityTypeName, pageSize: limit),
    );
    return records.map(mapFromLocalRecord).where((a) => a.employeeId == employeeId).toList();
  }

  @override
  Future<List<AttendanceRecord>> listByDateRange(String tenantId, DateTime from, DateTime to) async {
    final records = await _db.syncableRecordDao.getPage(
      RepositoryQuery(tenantId: tenantId, entityType: AttendanceRecord.entityTypeName, pageSize: 1000),
    );
    return records
        .map(mapFromLocalRecord)
        .where((a) => !a.recordDate.isBefore(from) && !a.recordDate.isAfter(to))
        .toList();
  }

  @override
  Future<Shift> createShift(Shift shift) => HrRepositoryImpl<Shift>(
        database: _db,
        syncQueue: _syncQueue,
        entityType: Shift.entityTypeName,
        fromPayload: Shift.fromPayload,
        toSearchFields: (e) => (name: e.employeeId, sku: null, barcode: null, storeId: e.storeId),
      ).create(shift);

  @override
  Future<List<Shift>> listShiftsForEmployee(String tenantId, String employeeId) async {
    final records = await _db.syncableRecordDao.getPage(
      RepositoryQuery(tenantId: tenantId, entityType: Shift.entityTypeName, pageSize: 200),
    );
    return records.map((r) => Shift.fromPayload(r.payload, r)).where((s) => s.employeeId == employeeId).toList();
  }

  @override
  Future<OvertimeRecord> createOvertime(OvertimeRecord record) => HrRepositoryImpl<OvertimeRecord>(
        database: _db,
        syncQueue: _syncQueue,
        entityType: OvertimeRecord.entityTypeName,
        fromPayload: OvertimeRecord.fromPayload,
        toSearchFields: (e) => (name: e.employeeId, sku: null, barcode: null, storeId: null),
      ).create(record);

  @override
  Future<List<OvertimeRecord>> listOvertime(String tenantId, String employeeId) async {
    final records = await _db.syncableRecordDao.getPage(
      RepositoryQuery(tenantId: tenantId, entityType: OvertimeRecord.entityTypeName, pageSize: 200),
    );
    return records.map((r) => OvertimeRecord.fromPayload(r.payload, r)).where((o) => o.employeeId == employeeId).toList();
  }
}

class PayrollLocalRepository extends HrRepositoryImpl<PayrollRun> implements PayrollRepository {
  PayrollLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : _db = database,
        _syncQueue = syncQueue,
        super(
          database: database,
          syncQueue: syncQueue,
          entityType: PayrollRun.entityTypeName,
          fromPayload: PayrollRun.fromPayload,
          toSearchFields: (e) => (name: e.runNumber, sku: e.payrollPeriodId, barcode: null, storeId: null),
        );

  final AppDatabase _db;
  final SyncQueueWriter _syncQueue;

  @override
  Future<PayrollRun?> findByRunNumber(String tenantId, String runNumber) async {
    final records = await _db.syncableRecordDao.getPage(
      RepositoryQuery(tenantId: tenantId, entityType: PayrollRun.entityTypeName, search: runNumber, pageSize: 20),
    );
    for (final r in records) {
      final run = mapFromLocalRecord(r);
      if (run.runNumber == runNumber) return run;
    }
    return null;
  }

  @override
  Future<List<PayrollRun>> listByPeriod(String tenantId, String payrollPeriodId) async {
    final records = await _db.syncableRecordDao.getPage(
      RepositoryQuery(tenantId: tenantId, entityType: PayrollRun.entityTypeName, pageSize: 100),
    );
    return records.map(mapFromLocalRecord).where((r) => r.payrollPeriodId == payrollPeriodId).toList();
  }

  @override
  Future<PayrollPeriod> createPeriod(PayrollPeriod period) => HrRepositoryImpl<PayrollPeriod>(
        database: _db,
        syncQueue: _syncQueue,
        entityType: PayrollPeriod.entityTypeName,
        fromPayload: PayrollPeriod.fromPayload,
        toSearchFields: (e) => (name: e.name, sku: null, barcode: null, storeId: null),
      ).create(period);

  @override
  Future<PayrollItem> createPayrollItem(PayrollItem item) => HrRepositoryImpl<PayrollItem>(
        database: _db,
        syncQueue: _syncQueue,
        entityType: PayrollItem.entityTypeName,
        fromPayload: PayrollItem.fromPayload,
        toSearchFields: (e) => (name: e.employeeId, sku: e.payrollRunId, barcode: null, storeId: null),
      ).create(item);

  @override
  Future<List<PayrollItem>> listItemsForRun(String tenantId, String payrollRunId) async {
    final records = await _db.syncableRecordDao.getPage(
      RepositoryQuery(tenantId: tenantId, entityType: PayrollItem.entityTypeName, pageSize: 500),
    );
    return records.map((r) => PayrollItem.fromPayload(r.payload, r)).where((i) => i.payrollRunId == payrollRunId).toList();
  }

  @override
  Future<Bonus> createBonus(Bonus bonus) => HrRepositoryImpl<Bonus>(
        database: _db,
        syncQueue: _syncQueue,
        entityType: Bonus.entityTypeName,
        fromPayload: Bonus.fromPayload,
        toSearchFields: (e) => (name: e.employeeId, sku: null, barcode: null, storeId: null),
      ).create(bonus);

  @override
  Future<Deduction> createDeduction(Deduction deduction) => HrRepositoryImpl<Deduction>(
        database: _db,
        syncQueue: _syncQueue,
        entityType: Deduction.entityTypeName,
        fromPayload: Deduction.fromPayload,
        toSearchFields: (e) => (name: e.code, sku: e.employeeId, barcode: null, storeId: null),
      ).create(deduction);

  @override
  Future<Allowance> createAllowance(Allowance allowance) => HrRepositoryImpl<Allowance>(
        database: _db,
        syncQueue: _syncQueue,
        entityType: Allowance.entityTypeName,
        fromPayload: Allowance.fromPayload,
        toSearchFields: (e) => (name: e.code, sku: e.employeeId, barcode: null, storeId: null),
      ).create(allowance);

  @override
  Future<Commission> createCommission(Commission commission) => HrRepositoryImpl<Commission>(
        database: _db,
        syncQueue: _syncQueue,
        entityType: Commission.entityTypeName,
        fromPayload: Commission.fromPayload,
        toSearchFields: (e) => (name: e.employeeId, sku: e.saleId, barcode: null, storeId: null),
      ).create(commission);

  @override
  Future<List<Commission>> listPendingCommissions(String tenantId, String employeeId) async {
    final records = await _db.syncableRecordDao.getPage(
      RepositoryQuery(tenantId: tenantId, entityType: Commission.entityTypeName, pageSize: 200),
    );
    return records
        .map((r) => Commission.fromPayload(r.payload, r))
        .where((c) => c.employeeId == employeeId && c.payrollRunId == null)
        .toList();
  }
}

class LeaveLocalRepository extends HrRepositoryImpl<LeaveRequest> implements LeaveRepository {
  LeaveLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : _db = database,
        _syncQueue = syncQueue,
        super(
          database: database,
          syncQueue: syncQueue,
          entityType: LeaveRequest.entityTypeName,
          fromPayload: LeaveRequest.fromPayload,
          toSearchFields: (e) => (name: e.employeeId, sku: e.leaveType.value, barcode: null, storeId: null),
        );

  final AppDatabase _db;
  final SyncQueueWriter _syncQueue;

  @override
  Future<List<LeaveRequest>> listByEmployee(String tenantId, String employeeId) async {
    final records = await _db.syncableRecordDao.getPage(
      RepositoryQuery(tenantId: tenantId, entityType: LeaveRequest.entityTypeName, pageSize: 200),
    );
    return records.map(mapFromLocalRecord).where((l) => l.employeeId == employeeId).toList();
  }

  @override
  Future<List<LeaveRequest>> listByStatus(String tenantId, LeaveStatus status) async {
    final records = await _db.syncableRecordDao.getPage(
      RepositoryQuery(tenantId: tenantId, entityType: LeaveRequest.entityTypeName, pageSize: 200),
    );
    return records.map(mapFromLocalRecord).where((l) => l.status == status).toList();
  }

  @override
  Future<LeaveBalance?> findBalance(String tenantId, String employeeId, LeaveType type, int year) async {
    final records = await _db.syncableRecordDao.getPage(
      RepositoryQuery(tenantId: tenantId, entityType: LeaveBalance.entityTypeName, pageSize: 100),
    );
    for (final r in records) {
      final b = LeaveBalance.fromPayload(r.payload, r);
      if (b.employeeId == employeeId && b.leaveType == type && b.year == year) return b;
    }
    return null;
  }

  @override
  Future<LeaveBalance> upsertBalance(LeaveBalance balance) {
    final repo = HrRepositoryImpl<LeaveBalance>(
      database: _db,
      syncQueue: _syncQueue,
      entityType: LeaveBalance.entityTypeName,
      fromPayload: LeaveBalance.fromPayload,
      toSearchFields: (e) => (name: e.employeeId, sku: e.leaveType.value, barcode: null, storeId: null),
    );
    return repo.create(balance);
  }
}
