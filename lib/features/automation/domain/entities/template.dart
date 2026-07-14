import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/features/automation/domain/enums/automation_enums.dart';

class DocumentTemplate extends Equatable implements SyncableEntity {
  const DocumentTemplate({
    required this.id,
    required this.tenantId,
    required this.name,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.description,
    this.templateType = TemplateType.document,
    this.subject,
    this.body,
    this.variables = const [],
    this.isActive = true,
    this.createdBy,
    this.deletedAt,
  });

  static const entityTypeName = 'document_template';

  @override
  final String id;
  @override
  final String tenantId;
  final String name;
  final String? description;
  final TemplateType templateType;
  final String? subject;
  final String? body;
  final List<String> variables;
  final bool isActive;
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

  @override
  Map<String, dynamic> toPayload() => {
        'id': id,
        'tenant_id': tenantId,
        'name': name,
        'description': description,
        'template_type': templateType.value,
        'subject': subject,
        'body': body,
        'variables': variables,
        'is_active': isActive,
        'created_by': createdBy,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static DocumentTemplate fromPayload(Map<String, dynamic> json, LocalRecord record) => DocumentTemplate(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        name: json['name'] as String? ?? record.searchName ?? '',
        description: json['description'] as String?,
        templateType: TemplateType.fromValue(json['template_type'] as String?),
        subject: json['subject'] as String?,
        body: json['body'] as String?,
        variables: List<String>.from(json['variables'] as List? ?? []),
        isActive: json['is_active'] as bool? ?? true,
        createdBy: json['created_by'] as String?,
        version: record.version,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
        deletedAt: record.deletedAt,
        syncStatus: record.syncStatus,
        isDirty: record.isDirty,
      );

  @override
  List<Object?> get props => [id, name, templateType, version];
}
