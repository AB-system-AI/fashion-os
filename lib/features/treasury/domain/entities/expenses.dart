import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/features/treasury/domain/entities/accounts.dart';
import 'package:fashion_pos_enterprise/features/treasury/domain/enums/treasury_enums.dart';

class ExpenseRequest extends Equatable with TreasuryEntity {
  const ExpenseRequest({
    required this.id,
    required this.tenantId,
    required this.requestNumber,
    required this.description,
    required this.amount,
    required this.category,
    required this.requestedBy,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.status = ExpenseRequestStatus.draft,
    this.departmentId,
    this.currencyCode = 'USD',
    this.deletedAt,
  });

  static const entityTypeName = 'expense_request';

  @override
  final String id;
  @override
  final String tenantId;
  final String requestNumber;
  final String description;
  final double amount;
  final String category;
  final String requestedBy;
  final String? departmentId;
  final ExpenseRequestStatus status;
  final String currencyCode;
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

  ExpenseRequest copyWith({ExpenseRequestStatus? status, int? version, DateTime? updatedAt, LocalSyncStatus? syncStatus, bool? isDirty}) =>
      ExpenseRequest(
        id: id,
        tenantId: tenantId,
        requestNumber: requestNumber,
        description: description,
        amount: amount,
        category: category,
        requestedBy: requestedBy,
        departmentId: departmentId,
        status: status ?? this.status,
        currencyCode: currencyCode,
        version: version ?? this.version,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt,
        syncStatus: syncStatus ?? this.syncStatus,
        isDirty: isDirty ?? this.isDirty,
      );

  @override
  Map<String, dynamic> toPayload() => {
        ...basePayload(),
        'request_number': requestNumber,
        'description': description,
        'amount': amount,
        'category': category,
        'requested_by': requestedBy,
        'department_id': departmentId,
        'status': status.value,
        'currency_code': currencyCode,
      };

  static ExpenseRequest fromPayload(Map<String, dynamic> json, LocalRecord record) => ExpenseRequest(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        requestNumber: json['request_number'] as String? ?? record.searchName ?? '',
        description: json['description'] as String? ?? '',
        amount: (json['amount'] as num?)?.toDouble() ?? 0,
        category: json['category'] as String? ?? '',
        requestedBy: json['requested_by'] as String? ?? '',
        departmentId: json['department_id'] as String?,
        status: ExpenseRequestStatus.fromValue(json['status'] as String?),
        currencyCode: json['currency_code'] as String? ?? 'USD',
        version: record.version,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
        deletedAt: record.deletedAt,
        syncStatus: record.syncStatus,
        isDirty: record.isDirty,
      );

  @override
  List<Object?> get props => [id, requestNumber, status, amount, version];
}

class ExpenseApproval extends Equatable with TreasuryEntity {
  const ExpenseApproval({
    required this.id,
    required this.tenantId,
    required this.expenseRequestId,
    required this.approverId,
    required this.approved,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.comments,
    this.deletedAt,
  });

  static const entityTypeName = 'expense_approval';

  @override
  final String id;
  @override
  final String tenantId;
  final String expenseRequestId;
  final String approverId;
  final bool approved;
  final String? comments;
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
        ...basePayload(),
        'expense_request_id': expenseRequestId,
        'approver_id': approverId,
        'approved': approved,
        'comments': comments,
      };

  static ExpenseApproval fromPayload(Map<String, dynamic> json, LocalRecord record) => ExpenseApproval(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        expenseRequestId: json['expense_request_id'] as String? ?? '',
        approverId: json['approver_id'] as String? ?? '',
        approved: json['approved'] as bool? ?? false,
        comments: json['comments'] as String?,
        version: record.version,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
        deletedAt: record.deletedAt,
        syncStatus: record.syncStatus,
        isDirty: record.isDirty,
      );

  @override
  List<Object?> get props => [id, expenseRequestId, approved, version];
}
