import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/features/hr/domain/enums/hr_enums.dart';

class PayrollPeriod extends Equatable implements SyncableEntity {
  const PayrollPeriod({
    required this.id,
    required this.tenantId,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.isClosed = false,
    this.deletedAt,
  });

  static const entityTypeName = 'payroll_period';

  @override
  final String id;
  @override
  final String tenantId;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final bool isClosed;
  @override
  final int version;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? deletedAt;
  @override
  final LocalSyncStatus syncStatus;
  @override
  final bool isDirty;

  @override
  String get entityType => entityTypeName;

  @override
  Map<String, dynamic> toPayload() => {
        'id': id,
        'tenant_id': tenantId,
        'name': name,
        'start_date': startDate.toIso8601String().split('T').first,
        'end_date': endDate.toIso8601String().split('T').first,
        'is_closed': isClosed,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static PayrollPeriod fromPayload(Map<String, dynamic> json, LocalRecord record) {
    return PayrollPeriod(
      id: json['id'] as String? ?? record.id,
      tenantId: json['tenant_id'] as String? ?? record.tenantId,
      name: json['name'] as String? ?? '',
      startDate: DateTime.tryParse(json['start_date'] as String? ?? '') ?? record.createdAt,
      endDate: DateTime.tryParse(json['end_date'] as String? ?? '') ?? record.createdAt,
      isClosed: json['is_closed'] as bool? ?? false,
      version: record.version,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
      deletedAt: record.deletedAt,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  @override
  List<Object?> get props => [id, name];
}

class PayrollRun extends Equatable implements SyncableEntity {
  const PayrollRun({
    required this.id,
    required this.tenantId,
    required this.payrollPeriodId,
    required this.runNumber,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.status = PayrollRunStatus.draft,
    this.totalGross = 0,
    this.totalDeductions = 0,
    this.totalTax = 0,
    this.totalNet = 0,
    this.approvedAt,
    this.approvedBy,
    this.deletedAt,
  });

  static const entityTypeName = 'payroll_run';

  @override
  final String id;
  @override
  final String tenantId;
  final String payrollPeriodId;
  final String runNumber;
  final PayrollRunStatus status;
  final double totalGross;
  final double totalDeductions;
  final double totalTax;
  final double totalNet;
  final DateTime? approvedAt;
  final String? approvedBy;
  @override
  final int version;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? deletedAt;
  @override
  final LocalSyncStatus syncStatus;
  @override
  final bool isDirty;

  @override
  String get entityType => entityTypeName;

  PayrollRun copyWith({
    PayrollRunStatus? status,
    double? totalGross,
    double? totalDeductions,
    double? totalTax,
    double? totalNet,
    DateTime? approvedAt,
    String? approvedBy,
    int? version,
    DateTime? updatedAt,
    LocalSyncStatus? syncStatus,
    bool? isDirty,
  }) {
    return PayrollRun(
      id: id,
      tenantId: tenantId,
      payrollPeriodId: payrollPeriodId,
      runNumber: runNumber,
      status: status ?? this.status,
      totalGross: totalGross ?? this.totalGross,
      totalDeductions: totalDeductions ?? this.totalDeductions,
      totalTax: totalTax ?? this.totalTax,
      totalNet: totalNet ?? this.totalNet,
      approvedAt: approvedAt ?? this.approvedAt,
      approvedBy: approvedBy ?? this.approvedBy,
      version: version ?? this.version,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      isDirty: isDirty ?? this.isDirty,
    );
  }

  @override
  Map<String, dynamic> toPayload() => {
        'id': id,
        'tenant_id': tenantId,
        'payroll_period_id': payrollPeriodId,
        'run_number': runNumber,
        'status': status.value,
        'total_gross': totalGross,
        'total_deductions': totalDeductions,
        'total_tax': totalTax,
        'total_net': totalNet,
        'approved_at': approvedAt?.toIso8601String(),
        'approved_by': approvedBy,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static PayrollRun fromPayload(Map<String, dynamic> json, LocalRecord record) {
    return PayrollRun(
      id: json['id'] as String? ?? record.id,
      tenantId: json['tenant_id'] as String? ?? record.tenantId,
      payrollPeriodId: json['payroll_period_id'] as String? ?? '',
      runNumber: json['run_number'] as String? ?? '',
      status: PayrollRunStatus.fromValue(json['status'] as String?),
      totalGross: (json['total_gross'] as num?)?.toDouble() ?? 0,
      totalDeductions: (json['total_deductions'] as num?)?.toDouble() ?? 0,
      totalTax: (json['total_tax'] as num?)?.toDouble() ?? 0,
      totalNet: (json['total_net'] as num?)?.toDouble() ?? 0,
      approvedAt: DateTime.tryParse(json['approved_at'] as String? ?? ''),
      approvedBy: json['approved_by'] as String?,
      version: record.version,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
      deletedAt: record.deletedAt,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  @override
  List<Object?> get props => [id, runNumber];
}

class PayrollItem extends Equatable implements SyncableEntity {
  const PayrollItem({
    required this.id,
    required this.tenantId,
    required this.payrollRunId,
    required this.employeeId,
    required this.itemType,
    required this.amount,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.description,
    this.deletedAt,
  });

  static const entityTypeName = 'payroll_item';

  @override
  final String id;
  @override
  final String tenantId;
  final String payrollRunId;
  final String employeeId;
  final PayrollItemType itemType;
  final double amount;
  final String? description;
  @override
  final int version;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? deletedAt;
  @override
  final LocalSyncStatus syncStatus;
  @override
  final bool isDirty;

  @override
  String get entityType => entityTypeName;

  @override
  Map<String, dynamic> toPayload() => {
        'id': id,
        'tenant_id': tenantId,
        'payroll_run_id': payrollRunId,
        'employee_id': employeeId,
        'item_type': itemType.value,
        'amount': amount,
        'description': description,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static PayrollItem fromPayload(Map<String, dynamic> json, LocalRecord record) {
    return PayrollItem(
      id: json['id'] as String? ?? record.id,
      tenantId: json['tenant_id'] as String? ?? record.tenantId,
      payrollRunId: json['payroll_run_id'] as String? ?? '',
      employeeId: json['employee_id'] as String? ?? '',
      itemType: PayrollItemType.fromValue(json['item_type'] as String?),
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      description: json['description'] as String?,
      version: record.version,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
      deletedAt: record.deletedAt,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  @override
  List<Object?> get props => [id, payrollRunId, employeeId, itemType];
}

class SalaryStructure extends Equatable implements SyncableEntity {
  const SalaryStructure({
    required this.id,
    required this.tenantId,
    required this.employeeId,
    required this.baseSalary,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.currency = 'USD',
    this.payFrequency = 'monthly',
    this.effectiveFrom,
    this.active = true,
    this.deletedAt,
  });

  static const entityTypeName = 'salary_structure';

  @override
  final String id;
  @override
  final String tenantId;
  final String employeeId;
  final double baseSalary;
  final String currency;
  final String payFrequency;
  final DateTime? effectiveFrom;
  final bool active;
  @override
  final int version;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? deletedAt;
  @override
  final LocalSyncStatus syncStatus;
  @override
  final bool isDirty;

  @override
  String get entityType => entityTypeName;

  @override
  Map<String, dynamic> toPayload() => {
        'id': id,
        'tenant_id': tenantId,
        'employee_id': employeeId,
        'base_salary': baseSalary,
        'currency': currency,
        'pay_frequency': payFrequency,
        'effective_from': effectiveFrom?.toIso8601String().split('T').first,
        'is_active': active,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static SalaryStructure fromPayload(Map<String, dynamic> json, LocalRecord record) {
    return SalaryStructure(
      id: json['id'] as String? ?? record.id,
      tenantId: json['tenant_id'] as String? ?? record.tenantId,
      employeeId: json['employee_id'] as String? ?? '',
      baseSalary: (json['base_salary'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? 'USD',
      payFrequency: json['pay_frequency'] as String? ?? 'monthly',
      effectiveFrom: DateTime.tryParse(json['effective_from'] as String? ?? ''),
      active: json['is_active'] as bool? ?? true,
      version: record.version,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
      deletedAt: record.deletedAt,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  @override
  List<Object?> get props => [id, employeeId];
}

class Allowance extends Equatable implements SyncableEntity {
  const Allowance({
    required this.id,
    required this.tenantId,
    required this.employeeId,
    required this.code,
    required this.name,
    required this.amount,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.recurring = true,
    this.active = true,
    this.deletedAt,
  });

  static const entityTypeName = 'allowance';

  @override
  final String id;
  @override
  final String tenantId;
  final String employeeId;
  final String code;
  final String name;
  final double amount;
  final bool recurring;
  final bool active;
  @override
  final int version;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? deletedAt;
  @override
  final LocalSyncStatus syncStatus;
  @override
  final bool isDirty;

  @override
  String get entityType => entityTypeName;

  @override
  Map<String, dynamic> toPayload() => {
        'id': id,
        'tenant_id': tenantId,
        'employee_id': employeeId,
        'code': code,
        'name': name,
        'amount': amount,
        'is_recurring': recurring,
        'is_active': active,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static Allowance fromPayload(Map<String, dynamic> json, LocalRecord record) {
    return Allowance(
      id: json['id'] as String? ?? record.id,
      tenantId: json['tenant_id'] as String? ?? record.tenantId,
      employeeId: json['employee_id'] as String? ?? '',
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      recurring: json['is_recurring'] as bool? ?? true,
      active: json['is_active'] as bool? ?? true,
      version: record.version,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
      deletedAt: record.deletedAt,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  @override
  List<Object?> get props => [id, code];
}

class Deduction extends Equatable implements SyncableEntity {
  const Deduction({
    required this.id,
    required this.tenantId,
    required this.employeeId,
    required this.code,
    required this.name,
    required this.amount,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.isPercentage = false,
    this.active = true,
    this.deletedAt,
  });

  static const entityTypeName = 'deduction';

  @override
  final String id;
  @override
  final String tenantId;
  final String employeeId;
  final String code;
  final String name;
  final double amount;
  final bool isPercentage;
  final bool active;
  @override
  final int version;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? deletedAt;
  @override
  final LocalSyncStatus syncStatus;
  @override
  final bool isDirty;

  @override
  String get entityType => entityTypeName;

  @override
  Map<String, dynamic> toPayload() => {
        'id': id,
        'tenant_id': tenantId,
        'employee_id': employeeId,
        'code': code,
        'name': name,
        'amount': amount,
        'is_percentage': isPercentage,
        'is_active': active,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static Deduction fromPayload(Map<String, dynamic> json, LocalRecord record) {
    return Deduction(
      id: json['id'] as String? ?? record.id,
      tenantId: json['tenant_id'] as String? ?? record.tenantId,
      employeeId: json['employee_id'] as String? ?? '',
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      isPercentage: json['is_percentage'] as bool? ?? false,
      active: json['is_active'] as bool? ?? true,
      version: record.version,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
      deletedAt: record.deletedAt,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  @override
  List<Object?> get props => [id, code];
}

class Bonus extends Equatable implements SyncableEntity {
  const Bonus({
    required this.id,
    required this.tenantId,
    required this.employeeId,
    required this.amount,
    required this.bonusDate,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.reason,
    this.payrollRunId,
    this.deletedAt,
  });

  static const entityTypeName = 'bonus';

  @override
  final String id;
  @override
  final String tenantId;
  final String employeeId;
  final double amount;
  final DateTime bonusDate;
  final String? reason;
  final String? payrollRunId;
  @override
  final int version;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? deletedAt;
  @override
  final LocalSyncStatus syncStatus;
  @override
  final bool isDirty;

  @override
  String get entityType => entityTypeName;

  @override
  Map<String, dynamic> toPayload() => {
        'id': id,
        'tenant_id': tenantId,
        'employee_id': employeeId,
        'amount': amount,
        'bonus_date': bonusDate.toIso8601String().split('T').first,
        'reason': reason,
        'payroll_run_id': payrollRunId,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static Bonus fromPayload(Map<String, dynamic> json, LocalRecord record) {
    return Bonus(
      id: json['id'] as String? ?? record.id,
      tenantId: json['tenant_id'] as String? ?? record.tenantId,
      employeeId: json['employee_id'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      bonusDate: DateTime.tryParse(json['bonus_date'] as String? ?? '') ?? record.createdAt,
      reason: json['reason'] as String?,
      payrollRunId: json['payroll_run_id'] as String?,
      version: record.version,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
      deletedAt: record.deletedAt,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  @override
  List<Object?> get props => [id, employeeId, bonusDate];
}

class Commission extends Equatable implements SyncableEntity {
  const Commission({
    required this.id,
    required this.tenantId,
    required this.employeeId,
    required this.amount,
    required this.commissionDate,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.saleId,
    this.ratePercent,
    this.payrollRunId,
    this.deletedAt,
  });

  static const entityTypeName = 'commission';

  @override
  final String id;
  @override
  final String tenantId;
  final String employeeId;
  final double amount;
  final DateTime commissionDate;
  final String? saleId;
  final double? ratePercent;
  final String? payrollRunId;
  @override
  final int version;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? deletedAt;
  @override
  final LocalSyncStatus syncStatus;
  @override
  final bool isDirty;

  @override
  String get entityType => entityTypeName;

  @override
  Map<String, dynamic> toPayload() => {
        'id': id,
        'tenant_id': tenantId,
        'employee_id': employeeId,
        'amount': amount,
        'commission_date': commissionDate.toIso8601String().split('T').first,
        'sale_id': saleId,
        'rate_percent': ratePercent,
        'payroll_run_id': payrollRunId,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static Commission fromPayload(Map<String, dynamic> json, LocalRecord record) {
    return Commission(
      id: json['id'] as String? ?? record.id,
      tenantId: json['tenant_id'] as String? ?? record.tenantId,
      employeeId: json['employee_id'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      commissionDate: DateTime.tryParse(json['commission_date'] as String? ?? '') ?? record.createdAt,
      saleId: json['sale_id'] as String?,
      ratePercent: (json['rate_percent'] as num?)?.toDouble(),
      payrollRunId: json['payroll_run_id'] as String?,
      version: record.version,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
      deletedAt: record.deletedAt,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  @override
  List<Object?> get props => [id, employeeId, saleId];
}
