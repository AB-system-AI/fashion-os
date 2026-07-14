import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/features/customers/domain/enums/customer_enums.dart';

class CustomerActivity extends Equatable implements SyncableEntity {
  const CustomerActivity({
    required this.id,
    required this.tenantId,
    required this.customerId,
    required this.activityType,
    required this.title,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.body,
    this.referenceType,
    this.referenceId,
    this.favoriteProductIds = const [],
    this.employeeId,
    this.occurredAt,
    this.deletedAt,
  });

  static const entityTypeName = 'customer_activity';

  @override
  final String id;
  @override
  final String tenantId;
  final String customerId;
  final CustomerActivityType activityType;
  final String title;
  final String? body;
  final String? referenceType;
  final String? referenceId;
  final List<String> favoriteProductIds;
  final String? employeeId;
  final DateTime? occurredAt;
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
        'customer_id': customerId,
        'activity_type': activityType.value,
        'title': title,
        'body': body,
        'reference_type': referenceType,
        'reference_id': referenceId,
        'favorite_product_ids': favoriteProductIds,
        'employee_id': employeeId,
        'occurred_at': occurredAt?.toIso8601String(),
        'version': version,
      };

  factory CustomerActivity.fromPayload(Map<String, dynamic> json, LocalRecord record) {
    final rawFavorites = json['favorite_product_ids'] as List<dynamic>? ?? const [];
    return CustomerActivity(
      id: record.id,
      tenantId: record.tenantId,
      customerId: json['customer_id'] as String? ?? record.storeId ?? '',
      activityType: CustomerActivityType.fromValue(json['activity_type'] as String?),
      title: json['title'] as String? ?? record.searchName ?? '',
      body: json['body'] as String?,
      referenceType: json['reference_type'] as String?,
      referenceId: json['reference_id'] as String?,
      favoriteProductIds: rawFavorites.map((e) => e.toString()).toList(),
      employeeId: json['employee_id'] as String?,
      occurredAt: json['occurred_at'] != null ? DateTime.tryParse(json['occurred_at'] as String) : null,
      version: record.version,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
      deletedAt: record.deletedAt,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  @override
  List<Object?> get props => [id, customerId, activityType, title];
}
