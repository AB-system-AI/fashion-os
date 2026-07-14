import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/features/hr/domain/enums/hr_enums.dart';

class LeaveRequest extends Equatable implements SyncableEntity {
  const LeaveRequest({
    required this.id,
    required this.tenantId,
    required this.employeeId,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.days,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.status = LeaveStatus.pending,
    this.reason,
    this.approvedBy,
    this.approvedAt,
    this.deletedAt,
  });

  static const entityTypeName = 'leave_request';

  @override
  final String id;
  @override
  final String tenantId;
  final String employeeId;
  final LeaveType leaveType;
  final DateTime startDate;
  final DateTime endDate;
  final double days;
  final LeaveStatus status;
  final String? reason;
  final String? approvedBy;
  final DateTime? approvedAt;
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

  LeaveRequest copyWith({
    LeaveStatus? status,
    String? approvedBy,
    DateTime? approvedAt,
    int? version,
    DateTime? updatedAt,
    LocalSyncStatus? syncStatus,
    bool? isDirty,
  }) {
    return LeaveRequest(
      id: id,
      tenantId: tenantId,
      employeeId: employeeId,
      leaveType: leaveType,
      startDate: startDate,
      endDate: endDate,
      days: days,
      status: status ?? this.status,
      reason: reason,
      approvedBy: approvedBy ?? this.approvedBy,
      approvedAt: approvedAt ?? this.approvedAt,
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
        'employee_id': employeeId,
        'leave_type': leaveType.value,
        'start_date': startDate.toIso8601String().split('T').first,
        'end_date': endDate.toIso8601String().split('T').first,
        'days': days,
        'status': status.value,
        'reason': reason,
        'approved_by': approvedBy,
        'approved_at': approvedAt?.toIso8601String(),
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static LeaveRequest fromPayload(Map<String, dynamic> json, LocalRecord record) {
    return LeaveRequest(
      id: json['id'] as String? ?? record.id,
      tenantId: json['tenant_id'] as String? ?? record.tenantId,
      employeeId: json['employee_id'] as String? ?? '',
      leaveType: LeaveType.fromValue(json['leave_type'] as String?),
      startDate: DateTime.tryParse(json['start_date'] as String? ?? '') ?? record.createdAt,
      endDate: DateTime.tryParse(json['end_date'] as String? ?? '') ?? record.createdAt,
      days: (json['days'] as num?)?.toDouble() ?? 0,
      status: LeaveStatus.fromValue(json['status'] as String?),
      reason: json['reason'] as String?,
      approvedBy: json['approved_by'] as String?,
      approvedAt: DateTime.tryParse(json['approved_at'] as String? ?? ''),
      version: record.version,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
      deletedAt: record.deletedAt,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  @override
  List<Object?> get props => [id, employeeId, startDate];
}

class LeaveBalance extends Equatable implements SyncableEntity {
  const LeaveBalance({
    required this.id,
    required this.tenantId,
    required this.employeeId,
    required this.leaveType,
    required this.entitledDays,
    required this.usedDays,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.year,
    this.deletedAt,
  });

  static const entityTypeName = 'leave_balance';

  @override
  final String id;
  @override
  final String tenantId;
  final String employeeId;
  final LeaveType leaveType;
  final double entitledDays;
  final double usedDays;
  final int? year;
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

  double get remainingDays => entitledDays - usedDays;

  @override
  String get entityType => entityTypeName;

  @override
  Map<String, dynamic> toPayload() => {
        'id': id,
        'tenant_id': tenantId,
        'employee_id': employeeId,
        'leave_type': leaveType.value,
        'entitled_days': entitledDays,
        'used_days': usedDays,
        'year': year,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static LeaveBalance fromPayload(Map<String, dynamic> json, LocalRecord record) {
    return LeaveBalance(
      id: json['id'] as String? ?? record.id,
      tenantId: json['tenant_id'] as String? ?? record.tenantId,
      employeeId: json['employee_id'] as String? ?? '',
      leaveType: LeaveType.fromValue(json['leave_type'] as String?),
      entitledDays: (json['entitled_days'] as num?)?.toDouble() ?? 0,
      usedDays: (json['used_days'] as num?)?.toDouble() ?? 0,
      year: (json['year'] as num?)?.toInt(),
      version: record.version,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
      deletedAt: record.deletedAt,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  @override
  List<Object?> get props => [id, employeeId, leaveType, year];
}
