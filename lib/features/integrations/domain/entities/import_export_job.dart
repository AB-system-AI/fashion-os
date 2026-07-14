import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/features/integrations/domain/enums/integration_enums.dart';

class ImportJob extends Equatable implements SyncableEntity {
  const ImportJob({
    required this.id,
    required this.tenantId,
    required this.entityType,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.status = ImportJobStatus.pending,
    this.fileName,
    this.totalRows = 0,
    this.importedRows = 0,
    this.failedRows = 0,
    this.errors = const [],
    this.createdBy,
    this.completedAt,
    this.deletedAt,
  });

  static const entityTypeName = 'import_job';

  @override
  final String id;
  @override
  final String tenantId;
  final String entityType;
  final ImportJobStatus status;
  final String? fileName;
  final int totalRows;
  final int importedRows;
  final int failedRows;
  final List<String> errors;
  final String? createdBy;
  final DateTime? completedAt;
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

  ImportJob copyWith({
    ImportJobStatus? status,
    int? totalRows,
    int? importedRows,
    int? failedRows,
    List<String>? errors,
    DateTime? completedAt,
    int? version,
    DateTime? updatedAt,
    LocalSyncStatus? syncStatus,
    bool? isDirty,
  }) =>
      ImportJob(
        id: id,
        tenantId: tenantId,
        entityType: entityType,
        status: status ?? this.status,
        fileName: fileName,
        totalRows: totalRows ?? this.totalRows,
        importedRows: importedRows ?? this.importedRows,
        failedRows: failedRows ?? this.failedRows,
        errors: errors ?? this.errors,
        createdBy: createdBy,
        completedAt: completedAt ?? this.completedAt,
        version: version ?? this.version,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt,
        syncStatus: syncStatus ?? this.syncStatus,
        isDirty: isDirty ?? this.isDirty,
      );

  @override
  Map<String, dynamic> toPayload() => {
        'id': id,
        'tenant_id': tenantId,
        'entity_type': entityType,
        'status': status.value,
        'file_name': fileName,
        'total_rows': totalRows,
        'imported_rows': importedRows,
        'failed_rows': failedRows,
        'errors': errors,
        'created_by': createdBy,
        'completed_at': completedAt?.toIso8601String(),
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static ImportJob fromPayload(Map<String, dynamic> json, LocalRecord record) => ImportJob(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        entityType: json['entity_type'] as String? ?? record.searchName ?? '',
        status: ImportJobStatus.fromValue(json['status'] as String?),
        fileName: json['file_name'] as String?,
        totalRows: json['total_rows'] as int? ?? 0,
        importedRows: json['imported_rows'] as int? ?? 0,
        failedRows: json['failed_rows'] as int? ?? 0,
        errors: List<String>.from(json['errors'] as List? ?? []),
        createdBy: json['created_by'] as String?,
        completedAt: json['completed_at'] != null ? DateTime.tryParse(json['completed_at'] as String) : null,
        version: record.version,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
        deletedAt: record.deletedAt,
        syncStatus: record.syncStatus,
        isDirty: record.isDirty,
      );

  @override
  List<Object?> get props => [id, entityType, status, version];
}

class ExportJob extends Equatable implements SyncableEntity {
  const ExportJob({
    required this.id,
    required this.tenantId,
    required this.entityType,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.status = ExportJobStatus.pending,
    this.format = 'csv',
    this.fileName,
    this.rowCount = 0,
    this.createdBy,
    this.completedAt,
    this.deletedAt,
  });

  static const entityTypeName = 'export_job';

  @override
  final String id;
  @override
  final String tenantId;
  final String entityType;
  final ExportJobStatus status;
  final String format;
  final String? fileName;
  final int rowCount;
  final String? createdBy;
  final DateTime? completedAt;
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

  ExportJob copyWith({
    ExportJobStatus? status,
    String? fileName,
    int? rowCount,
    DateTime? completedAt,
    int? version,
    DateTime? updatedAt,
    LocalSyncStatus? syncStatus,
    bool? isDirty,
  }) =>
      ExportJob(
        id: id,
        tenantId: tenantId,
        entityType: entityType,
        status: status ?? this.status,
        format: format,
        fileName: fileName ?? this.fileName,
        rowCount: rowCount ?? this.rowCount,
        createdBy: createdBy,
        completedAt: completedAt ?? this.completedAt,
        version: version ?? this.version,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt,
        syncStatus: syncStatus ?? this.syncStatus,
        isDirty: isDirty ?? this.isDirty,
      );

  @override
  Map<String, dynamic> toPayload() => {
        'id': id,
        'tenant_id': tenantId,
        'entity_type': entityType,
        'status': status.value,
        'format': format,
        'file_name': fileName,
        'row_count': rowCount,
        'created_by': createdBy,
        'completed_at': completedAt?.toIso8601String(),
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static ExportJob fromPayload(Map<String, dynamic> json, LocalRecord record) => ExportJob(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        entityType: json['entity_type'] as String? ?? record.searchName ?? '',
        status: ExportJobStatus.fromValue(json['status'] as String?),
        format: json['format'] as String? ?? 'csv',
        fileName: json['file_name'] as String?,
        rowCount: json['row_count'] as int? ?? 0,
        createdBy: json['created_by'] as String?,
        completedAt: json['completed_at'] != null ? DateTime.tryParse(json['completed_at'] as String) : null,
        version: record.version,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
        deletedAt: record.deletedAt,
        syncStatus: record.syncStatus,
        isDirty: record.isDirty,
      );

  @override
  List<Object?> get props => [id, entityType, status, version];
}
