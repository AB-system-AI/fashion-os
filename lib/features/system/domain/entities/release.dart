import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/features/system/domain/enums/system_enums.dart';

class ReleaseNote extends Equatable implements SyncableEntity {
  const ReleaseNote({
    required this.id,
    required this.tenantId,
    required this.appVersion,
    required this.title,
    required this.body,
    required this.publishedAt,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.isPublished = true,
    this.tags = const [],
    this.deletedAt,
  });

  static const entityTypeName = 'release_note';

  @override
  final String id;
  @override
  final String tenantId;
  final String appVersion;
  final String title;
  final String body;
  final bool isPublished;
  final List<String> tags;
  final DateTime publishedAt;
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
        'app_version': appVersion,
        'title': title,
        'body': body,
        'is_published': isPublished,
        'tags': tags,
        'published_at': publishedAt.toIso8601String(),
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static ReleaseNote fromPayload(Map<String, dynamic> json, LocalRecord record) => ReleaseNote(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        appVersion: json['app_version'] as String? ?? record.searchName ?? '',
        title: json['title'] as String? ?? '',
        body: json['body'] as String? ?? '',
        isPublished: json['is_published'] as bool? ?? true,
        tags: List<String>.from(json['tags'] as List? ?? []),
        publishedAt: DateTime.tryParse(json['published_at'] as String? ?? '') ?? record.createdAt,
        version: record.version,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
        deletedAt: record.deletedAt,
        syncStatus: record.syncStatus,
        isDirty: record.isDirty,
      );

  @override
  List<Object?> get props => [id, appVersion, title, publishedAt];
}

class MigrationHistoryEntry extends Equatable implements SyncableEntity {
  const MigrationHistoryEntry({
    required this.id,
    required this.tenantId,
    required this.migrationName,
    required this.appliedAt,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.status = MigrationStatus.applied,
    this.durationMs = 0,
    this.errorMessage,
    this.deletedAt,
  });

  static const entityTypeName = 'migration_history_entry';

  @override
  final String id;
  @override
  final String tenantId;
  final String migrationName;
  final MigrationStatus status;
  final DateTime appliedAt;
  final int durationMs;
  final String? errorMessage;
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
        'migration_name': migrationName,
        'status': status.value,
        'applied_at': appliedAt.toIso8601String(),
        'duration_ms': durationMs,
        'error_message': errorMessage,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static MigrationHistoryEntry fromPayload(Map<String, dynamic> json, LocalRecord record) => MigrationHistoryEntry(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        migrationName: json['migration_name'] as String? ?? record.searchName ?? '',
        status: MigrationStatus.fromValue(json['status'] as String?),
        appliedAt: DateTime.tryParse(json['applied_at'] as String? ?? '') ?? record.createdAt,
        durationMs: json['duration_ms'] as int? ?? 0,
        errorMessage: json['error_message'] as String?,
        version: record.version,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
        deletedAt: record.deletedAt,
        syncStatus: record.syncStatus,
        isDirty: record.isDirty,
      );

  @override
  List<Object?> get props => [id, migrationName, status, appliedAt];
}
