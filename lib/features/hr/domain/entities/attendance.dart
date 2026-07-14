import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/features/hr/domain/enums/hr_enums.dart';

class Shift extends Equatable implements SyncableEntity {
  const Shift({
    required this.id,
    required this.tenantId,
    required this.employeeId,
    required this.storeId,
    required this.startTime,
    required this.endTime,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.status = ShiftStatus.scheduled,
    this.openedAt,
    this.closedAt,
    this.deletedAt,
  });

  static const entityTypeName = 'shift';

  @override
  final String id;
  @override
  final String tenantId;
  final String employeeId;
  final String storeId;
  final DateTime startTime;
  final DateTime endTime;
  final ShiftStatus status;
  final DateTime? openedAt;
  final DateTime? closedAt;
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
        'store_id': storeId,
        'start_time': startTime.toIso8601String(),
        'end_time': endTime.toIso8601String(),
        'status': status.value,
        'opened_at': openedAt?.toIso8601String(),
        'closed_at': closedAt?.toIso8601String(),
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static Shift fromPayload(Map<String, dynamic> json, LocalRecord record) {
    return Shift(
      id: json['id'] as String? ?? record.id,
      tenantId: json['tenant_id'] as String? ?? record.tenantId,
      employeeId: json['employee_id'] as String? ?? '',
      storeId: json['store_id'] as String? ?? '',
      startTime: DateTime.tryParse(json['start_time'] as String? ?? '') ?? record.createdAt,
      endTime: DateTime.tryParse(json['end_time'] as String? ?? '') ?? record.createdAt,
      status: ShiftStatus.fromValue(json['status'] as String?),
      openedAt: DateTime.tryParse(json['opened_at'] as String? ?? ''),
      closedAt: DateTime.tryParse(json['closed_at'] as String? ?? ''),
      version: record.version,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
      deletedAt: record.deletedAt,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  @override
  List<Object?> get props => [id, employeeId, startTime];
}

class AttendanceRecord extends Equatable implements SyncableEntity {
  const AttendanceRecord({
    required this.id,
    required this.tenantId,
    required this.employeeId,
    required this.recordDate,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.storeId,
    this.shiftId,
    this.clockIn,
    this.clockOut,
    this.status = AttendanceStatus.present,
    this.lateMinutes = 0,
    this.workedMinutes = 0,
    this.notes,
    this.deletedAt,
  });

  static const entityTypeName = 'attendance_record';

  @override
  final String id;
  @override
  final String tenantId;
  final String employeeId;
  final String? storeId;
  final String? shiftId;
  final DateTime recordDate;
  final DateTime? clockIn;
  final DateTime? clockOut;
  final AttendanceStatus status;
  final int lateMinutes;
  final int workedMinutes;
  final String? notes;
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
        'store_id': storeId,
        'shift_id': shiftId,
        'record_date': recordDate.toIso8601String().split('T').first,
        'clock_in': clockIn?.toIso8601String(),
        'clock_out': clockOut?.toIso8601String(),
        'status': status.value,
        'late_minutes': lateMinutes,
        'worked_minutes': workedMinutes,
        'notes': notes,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static AttendanceRecord fromPayload(Map<String, dynamic> json, LocalRecord record) {
    return AttendanceRecord(
      id: json['id'] as String? ?? record.id,
      tenantId: json['tenant_id'] as String? ?? record.tenantId,
      employeeId: json['employee_id'] as String? ?? '',
      storeId: json['store_id'] as String?,
      shiftId: json['shift_id'] as String?,
      recordDate: DateTime.tryParse(json['record_date'] as String? ?? '') ?? record.createdAt,
      clockIn: DateTime.tryParse(json['clock_in'] as String? ?? ''),
      clockOut: DateTime.tryParse(json['clock_out'] as String? ?? ''),
      status: AttendanceStatus.fromValue(json['status'] as String?),
      lateMinutes: (json['late_minutes'] as num?)?.toInt() ?? 0,
      workedMinutes: (json['worked_minutes'] as num?)?.toInt() ?? 0,
      notes: json['notes'] as String?,
      version: record.version,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
      deletedAt: record.deletedAt,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  @override
  List<Object?> get props => [id, employeeId, recordDate];
}

class OvertimeRecord extends Equatable implements SyncableEntity {
  const OvertimeRecord({
    required this.id,
    required this.tenantId,
    required this.employeeId,
    required this.overtimeDate,
    required this.hours,
    required this.rateMultiplier,
    required this.amount,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.attendanceId,
    this.approved = false,
    this.deletedAt,
  });

  static const entityTypeName = 'overtime_record';

  @override
  final String id;
  @override
  final String tenantId;
  final String employeeId;
  final String? attendanceId;
  final DateTime overtimeDate;
  final double hours;
  final double rateMultiplier;
  final double amount;
  final bool approved;
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
        'attendance_id': attendanceId,
        'overtime_date': overtimeDate.toIso8601String().split('T').first,
        'hours': hours,
        'rate_multiplier': rateMultiplier,
        'amount': amount,
        'is_approved': approved,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static OvertimeRecord fromPayload(Map<String, dynamic> json, LocalRecord record) {
    return OvertimeRecord(
      id: json['id'] as String? ?? record.id,
      tenantId: json['tenant_id'] as String? ?? record.tenantId,
      employeeId: json['employee_id'] as String? ?? '',
      attendanceId: json['attendance_id'] as String?,
      overtimeDate: DateTime.tryParse(json['overtime_date'] as String? ?? '') ?? record.createdAt,
      hours: (json['hours'] as num?)?.toDouble() ?? 0,
      rateMultiplier: (json['rate_multiplier'] as num?)?.toDouble() ?? 1.5,
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      approved: json['is_approved'] as bool? ?? false,
      version: record.version,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
      deletedAt: record.deletedAt,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  @override
  List<Object?> get props => [id, employeeId, overtimeDate];
}
