import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/features/hr/domain/enums/hr_enums.dart';

class PerformanceReview extends Equatable implements SyncableEntity {
  const PerformanceReview({
    required this.id,
    required this.tenantId,
    required this.employeeId,
    required this.reviewDate,
    required this.rating,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.reviewerId,
    this.score,
    this.comments,
    this.salesCount,
    this.salesTotal,
    this.deletedAt,
  });

  static const entityTypeName = 'performance_review';

  @override
  final String id;
  @override
  final String tenantId;
  final String employeeId;
  final String? reviewerId;
  final DateTime reviewDate;
  final PerformanceRating rating;
  final double? score;
  final String? comments;
  final int? salesCount;
  final double? salesTotal;
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
        'reviewer_id': reviewerId,
        'review_date': reviewDate.toIso8601String().split('T').first,
        'rating': rating.value,
        'score': score,
        'comments': comments,
        'sales_count': salesCount,
        'sales_total': salesTotal,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static PerformanceReview fromPayload(Map<String, dynamic> json, LocalRecord record) {
    return PerformanceReview(
      id: json['id'] as String? ?? record.id,
      tenantId: json['tenant_id'] as String? ?? record.tenantId,
      employeeId: json['employee_id'] as String? ?? '',
      reviewerId: json['reviewer_id'] as String?,
      reviewDate: DateTime.tryParse(json['review_date'] as String? ?? '') ?? record.createdAt,
      rating: PerformanceRating.fromValue(json['rating'] as String?),
      score: (json['score'] as num?)?.toDouble(),
      comments: json['comments'] as String?,
      salesCount: (json['sales_count'] as num?)?.toInt(),
      salesTotal: (json['sales_total'] as num?)?.toDouble(),
      version: record.version,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
      deletedAt: record.deletedAt,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  @override
  List<Object?> get props => [id, employeeId, reviewDate];
}

class EmployeeDocument extends Equatable implements SyncableEntity {
  const EmployeeDocument({
    required this.id,
    required this.tenantId,
    required this.employeeId,
    required this.title,
    required this.category,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.fileUrl,
    this.fileName,
    this.mimeType,
    this.expiresAt,
    this.deletedAt,
  });

  static const entityTypeName = 'employee_document';

  @override
  final String id;
  @override
  final String tenantId;
  final String employeeId;
  final String title;
  final DocumentCategory category;
  final String? fileUrl;
  final String? fileName;
  final String? mimeType;
  final DateTime? expiresAt;
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
        'title': title,
        'category': category.value,
        'file_url': fileUrl,
        'file_name': fileName,
        'mime_type': mimeType,
        'expires_at': expiresAt?.toIso8601String(),
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static EmployeeDocument fromPayload(Map<String, dynamic> json, LocalRecord record) {
    return EmployeeDocument(
      id: json['id'] as String? ?? record.id,
      tenantId: json['tenant_id'] as String? ?? record.tenantId,
      employeeId: json['employee_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      category: DocumentCategory.fromValue(json['category'] as String?),
      fileUrl: json['file_url'] as String?,
      fileName: json['file_name'] as String?,
      mimeType: json['mime_type'] as String?,
      expiresAt: DateTime.tryParse(json['expires_at'] as String? ?? ''),
      version: record.version,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
      deletedAt: record.deletedAt,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  @override
  List<Object?> get props => [id, employeeId, title];
}
