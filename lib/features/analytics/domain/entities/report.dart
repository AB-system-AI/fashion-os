import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/features/analytics/domain/enums/analytics_enums.dart';
import 'package:fashion_pos_enterprise/features/analytics/domain/value_objects/analytics_value_objects.dart';

class ReportDefinition extends Equatable implements SyncableEntity {
  const ReportDefinition({
    required this.id,
    required this.tenantId,
    required this.name,
    required this.module,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.description,
    this.status = ReportStatus.draft,
    this.filters = const {},
    this.columns = const [],
    this.groupBy,
    this.sortBy,
    this.templateId,
    this.createdBy,
    this.deletedAt,
  });

  static const entityTypeName = 'report_definition';

  @override
  final String id;
  @override
  final String tenantId;
  final String name;
  final String module;
  final String? description;
  final ReportStatus status;
  final Map<String, dynamic> filters;
  final List<String> columns;
  final String? groupBy;
  final String? sortBy;
  final String? templateId;
  final String? createdBy;
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

  ReportDefinition copyWith({
    String? name,
    ReportStatus? status,
    Map<String, dynamic>? filters,
    int? version,
    DateTime? updatedAt,
    DateTime? deletedAt,
    LocalSyncStatus? syncStatus,
    bool? isDirty,
  }) =>
      ReportDefinition(
        id: id,
        tenantId: tenantId,
        name: name ?? this.name,
        module: module,
        description: description,
        status: status ?? this.status,
        filters: filters ?? this.filters,
        columns: columns,
        groupBy: groupBy,
        sortBy: sortBy,
        templateId: templateId,
        createdBy: createdBy,
        version: version ?? this.version,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt ?? this.deletedAt,
        syncStatus: syncStatus ?? this.syncStatus,
        isDirty: isDirty ?? this.isDirty,
      );

  @override
  Map<String, dynamic> toPayload() => {
        'id': id,
        'tenant_id': tenantId,
        'name': name,
        'module': module,
        'description': description,
        'status': status.value,
        'filters': filters,
        'columns': columns,
        'group_by': groupBy,
        'sort_by': sortBy,
        'template_id': templateId,
        'created_by': createdBy,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static ReportDefinition fromPayload(Map<String, dynamic> json, LocalRecord record) {
    return ReportDefinition(
      id: json['id'] as String? ?? record.id,
      tenantId: json['tenant_id'] as String? ?? record.tenantId,
      name: json['name'] as String? ?? '',
      module: json['module'] as String? ?? 'executive',
      description: json['description'] as String?,
      status: ReportStatus.fromValue(json['status'] as String?),
      filters: Map<String, dynamic>.from(json['filters'] as Map? ?? {}),
      columns: List<String>.from(json['columns'] as List? ?? []),
      groupBy: json['group_by'] as String?,
      sortBy: json['sort_by'] as String?,
      templateId: json['template_id'] as String?,
      createdBy: json['created_by'] as String?,
      version: record.version,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
      deletedAt: record.deletedAt,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  @override
  List<Object?> get props => [id, name, version];
}

class ReportTemplate extends Equatable implements SyncableEntity {
  const ReportTemplate({
    required this.id,
    required this.tenantId,
    required this.name,
    required this.module,
    required this.definition,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.isSystem = false,
    this.deletedAt,
  });

  static const entityTypeName = 'report_template';

  @override
  final String id;
  @override
  final String tenantId;
  final String name;
  final String module;
  final Map<String, dynamic> definition;
  final bool isSystem;
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
        'module': module,
        'definition': definition,
        'is_system': isSystem,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static ReportTemplate fromPayload(Map<String, dynamic> json, LocalRecord record) {
    return ReportTemplate(
      id: json['id'] as String? ?? record.id,
      tenantId: json['tenant_id'] as String? ?? record.tenantId,
      name: json['name'] as String? ?? '',
      module: json['module'] as String? ?? 'executive',
      definition: Map<String, dynamic>.from(json['definition'] as Map? ?? {}),
      isSystem: json['is_system'] as bool? ?? false,
      version: record.version,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
      deletedAt: record.deletedAt,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  @override
  List<Object?> get props => [id, name, version];
}

class ReportExport extends Equatable implements SyncableEntity {
  const ReportExport({
    required this.id,
    required this.tenantId,
    required this.reportId,
    required this.format,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.fileName,
    this.filtersUsed = const {},
    this.generatedBy,
    this.deletedAt,
  });

  static const entityTypeName = 'report_export';

  @override
  final String id;
  @override
  final String tenantId;
  final String reportId;
  final ExportFormatType format;
  final String? fileName;
  final Map<String, dynamic> filtersUsed;
  final String? generatedBy;
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
        'report_id': reportId,
        'format': format.value,
        'file_name': fileName,
        'filters_used': filtersUsed,
        'generated_by': generatedBy,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static ReportExport fromPayload(Map<String, dynamic> json, LocalRecord record) {
    return ReportExport(
      id: json['id'] as String? ?? record.id,
      tenantId: json['tenant_id'] as String? ?? record.tenantId,
      reportId: json['report_id'] as String? ?? '',
      format: ExportFormatType.fromValue(json['format'] as String?),
      fileName: json['file_name'] as String?,
      filtersUsed: Map<String, dynamic>.from(json['filters_used'] as Map? ?? {}),
      generatedBy: json['generated_by'] as String?,
      version: record.version,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
      deletedAt: record.deletedAt,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  @override
  List<Object?> get props => [id, reportId, version];
}

class ReportSnapshot extends Equatable implements SyncableEntity {
  const ReportSnapshot({
    required this.id,
    required this.tenantId,
    required this.reportId,
    required this.data,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.snapshotAt,
    this.deletedAt,
  });

  static const entityTypeName = 'report_snapshot';

  @override
  final String id;
  @override
  final String tenantId;
  final String reportId;
  final Map<String, dynamic> data;
  final DateTime? snapshotAt;
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
        'report_id': reportId,
        'data': data,
        'snapshot_at': snapshotAt?.toIso8601String(),
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static ReportSnapshot fromPayload(Map<String, dynamic> json, LocalRecord record) {
    return ReportSnapshot(
      id: json['id'] as String? ?? record.id,
      tenantId: json['tenant_id'] as String? ?? record.tenantId,
      reportId: json['report_id'] as String? ?? '',
      data: Map<String, dynamic>.from(json['data'] as Map? ?? {}),
      snapshotAt: json['snapshot_at'] != null ? DateTime.tryParse(json['snapshot_at'] as String) : null,
      version: record.version,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
      deletedAt: record.deletedAt,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  @override
  List<Object?> get props => [id, reportId, version];
}
