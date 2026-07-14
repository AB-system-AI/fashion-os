import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/features/integrations/domain/enums/integration_enums.dart';

class IntegrationLog extends Equatable implements SyncableEntity {
  const IntegrationLog({
    required this.id,
    required this.tenantId,
    required this.message,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.level = IntegrationLogLevel.info,
    this.connectorId,
    this.webhookId,
    this.eventType,
    this.metadata = const {},
    this.deletedAt,
  });

  static const entityTypeName = 'integration_log';

  @override
  final String id;
  @override
  final String tenantId;
  final IntegrationLogLevel level;
  final String message;
  final String? connectorId;
  final String? webhookId;
  final String? eventType;
  final Map<String, dynamic> metadata;
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
        'level': level.value,
        'message': message,
        'connector_id': connectorId,
        'webhook_id': webhookId,
        'event_type': eventType,
        'metadata': metadata,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static IntegrationLog fromPayload(Map<String, dynamic> json, LocalRecord record) => IntegrationLog(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        level: IntegrationLogLevel.fromValue(json['level'] as String?),
        message: json['message'] as String? ?? record.searchName ?? '',
        connectorId: json['connector_id'] as String?,
        webhookId: json['webhook_id'] as String?,
        eventType: json['event_type'] as String?,
        metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
        version: record.version,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
        deletedAt: record.deletedAt,
        syncStatus: record.syncStatus,
        isDirty: record.isDirty,
      );

  @override
  List<Object?> get props => [id, level, message, version];
}
