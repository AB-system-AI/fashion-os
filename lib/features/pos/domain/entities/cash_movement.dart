import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/features/pos/domain/enums/pos_enums.dart';

class CashMovement extends Equatable implements SyncableEntity {
  const CashMovement({
    required this.id,
    required this.tenantId,
    required this.sessionId,
    required this.movementType,
    required this.amount,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.referenceType,
    this.referenceId,
    this.notes,
    this.employeeId,
    this.deletedAt,
  });

  static const entityTypeName = 'cash_movement';

  @override
  final String id;
  @override
  final String tenantId;
  final String sessionId;
  final CashMovementType movementType;
  final double amount;
  final String? referenceType;
  final String? referenceId;
  final String? notes;
  final String? employeeId;
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
        'session_id': sessionId,
        'movement_type': movementType.value,
        'amount': amount,
        'reference_type': referenceType,
        'reference_id': referenceId,
        'notes': notes,
        'employee_id': employeeId,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static CashMovement fromPayload(Map<String, dynamic> json, LocalRecord record) {
    return CashMovement(
      id: json['id'] as String? ?? record.id,
      tenantId: json['tenant_id'] as String? ?? record.tenantId,
      sessionId: json['session_id'] as String? ?? '',
      movementType: CashMovementType.fromValue(json['movement_type'] as String?),
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      referenceType: json['reference_type'] as String?,
      referenceId: json['reference_id'] as String?,
      notes: json['notes'] as String?,
      employeeId: json['employee_id'] as String?,
      version: record.version,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
      deletedAt: record.deletedAt,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  @override
  List<Object?> get props => [id, sessionId, movementType, amount];
}
