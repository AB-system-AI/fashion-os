import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/features/hr/domain/enums/hr_enums.dart';

class Employee extends Equatable implements SyncableEntity {
  const Employee({
    required this.id,
    required this.tenantId,
    required this.employeeCode,
    required this.firstName,
    required this.lastName,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.userId,
    this.email,
    this.phone,
    this.departmentId,
    this.positionId,
    this.storeId,
    this.jobTitle,
    this.status = EmployeeStatus.active,
    this.hiredAt,
    this.terminatedAt,
    this.baseSalary = 0,
    this.currency = 'USD',
    this.deletedAt,
  });

  static const entityTypeName = 'employee';

  @override
  final String id;
  @override
  final String tenantId;
  final String? userId;
  final String employeeCode;
  final String firstName;
  final String lastName;
  final String? email;
  final String? phone;
  final String? departmentId;
  final String? positionId;
  final String? storeId;
  final String? jobTitle;
  final EmployeeStatus status;
  final DateTime? hiredAt;
  final DateTime? terminatedAt;
  final double baseSalary;
  final String currency;
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

  String get fullName => '$firstName $lastName'.trim();

  @override
  String get entityType => entityTypeName;

  Employee copyWith({
    String? id,
    String? tenantId,
    String? userId,
    String? employeeCode,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? departmentId,
    String? positionId,
    String? storeId,
    String? jobTitle,
    EmployeeStatus? status,
    DateTime? hiredAt,
    DateTime? terminatedAt,
    double? baseSalary,
    String? currency,
    int? version,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    LocalSyncStatus? syncStatus,
    bool? isDirty,
  }) {
    return Employee(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      userId: userId ?? this.userId,
      employeeCode: employeeCode ?? this.employeeCode,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      departmentId: departmentId ?? this.departmentId,
      positionId: positionId ?? this.positionId,
      storeId: storeId ?? this.storeId,
      jobTitle: jobTitle ?? this.jobTitle,
      status: status ?? this.status,
      hiredAt: hiredAt ?? this.hiredAt,
      terminatedAt: terminatedAt ?? this.terminatedAt,
      baseSalary: baseSalary ?? this.baseSalary,
      currency: currency ?? this.currency,
      version: version ?? this.version,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      isDirty: isDirty ?? this.isDirty,
    );
  }

  @override
  Map<String, dynamic> toPayload() => {
        'id': id,
        'tenant_id': tenantId,
        'user_id': userId,
        'employee_code': employeeCode,
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'phone': phone,
        'department_id': departmentId,
        'position_id': positionId,
        'store_id': storeId,
        'job_title': jobTitle,
        'status': status.value,
        'hired_at': hiredAt?.toIso8601String().split('T').first,
        'terminated_at': terminatedAt?.toIso8601String().split('T').first,
        'base_salary': baseSalary,
        'currency': currency,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static Employee fromPayload(Map<String, dynamic> json, LocalRecord record) {
    return Employee(
      id: json['id'] as String? ?? record.id,
      tenantId: json['tenant_id'] as String? ?? record.tenantId,
      userId: json['user_id'] as String?,
      employeeCode: json['employee_code'] as String? ?? '',
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      departmentId: json['department_id'] as String?,
      positionId: json['position_id'] as String?,
      storeId: json['store_id'] as String?,
      jobTitle: json['job_title'] as String?,
      status: EmployeeStatus.fromValue(json['status'] as String?),
      hiredAt: DateTime.tryParse(json['hired_at'] as String? ?? ''),
      terminatedAt: DateTime.tryParse(json['terminated_at'] as String? ?? ''),
      baseSalary: (json['base_salary'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? 'USD',
      version: record.version,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
      deletedAt: record.deletedAt,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  @override
  List<Object?> get props => [id, employeeCode, version];
}
