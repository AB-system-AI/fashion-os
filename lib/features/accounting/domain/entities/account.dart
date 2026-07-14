import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/features/accounting/domain/enums/accounting_enums.dart';

class AccountGroup extends Equatable implements SyncableEntity {
  const AccountGroup({
    required this.id,
    required this.tenantId,
    required this.name,
    required this.code,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.parentId,
    this.sortOrder = 0,
    this.active = true,
    this.deletedAt,
  });

  static const entityTypeName = 'account_group';

  @override
  final String id;
  @override
  final String tenantId;
  final String name;
  final String code;
  final String? parentId;
  final int sortOrder;
  final bool active;
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
        'code': code,
        'parent_id': parentId,
        'sort_order': sortOrder,
        'is_active': active,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static AccountGroup fromPayload(Map<String, dynamic> json, LocalRecord record) {
    return AccountGroup(
      id: json['id'] as String? ?? record.id,
      tenantId: json['tenant_id'] as String? ?? record.tenantId,
      name: json['name'] as String? ?? '',
      code: json['code'] as String? ?? '',
      parentId: json['parent_id'] as String?,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      active: json['is_active'] as bool? ?? true,
      version: record.version,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
      deletedAt: record.deletedAt,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  @override
  List<Object?> get props => [id, code];
}

class Account extends Equatable implements SyncableEntity {
  const Account({
    required this.id,
    required this.tenantId,
    required this.code,
    required this.name,
    required this.accountType,
    required this.normalBalance,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.groupId,
    this.currency = 'USD',
    this.parentAccountId,
    this.isSystem = false,
    this.active = true,
    this.balance = 0,
    this.deletedAt,
  });

  static const entityTypeName = 'chart_of_account';

  @override
  final String id;
  @override
  final String tenantId;
  final String code;
  final String name;
  final AccountType accountType;
  final AccountNormalBalance normalBalance;
  final String? groupId;
  final String currency;
  final String? parentAccountId;
  final bool isSystem;
  final bool active;
  final double balance;
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
        'code': code,
        'name': name,
        'account_type': accountType.value,
        'normal_balance': normalBalance.value,
        'group_id': groupId,
        'currency': currency,
        'parent_account_id': parentAccountId,
        'is_system': isSystem,
        'is_active': active,
        'balance': balance,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static Account fromPayload(Map<String, dynamic> json, LocalRecord record) {
    return Account(
      id: json['id'] as String? ?? record.id,
      tenantId: json['tenant_id'] as String? ?? record.tenantId,
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      accountType: AccountType.fromValue(json['account_type'] as String?),
      normalBalance: AccountNormalBalance.fromValue(json['normal_balance'] as String?),
      groupId: json['group_id'] as String?,
      currency: json['currency'] as String? ?? 'USD',
      parentAccountId: json['parent_account_id'] as String?,
      isSystem: json['is_system'] as bool? ?? false,
      active: json['is_active'] as bool? ?? true,
      balance: (json['balance'] as num?)?.toDouble() ?? 0,
      version: record.version,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
      deletedAt: record.deletedAt,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  Account copyWith({double? balance, int? version, DateTime? updatedAt, LocalSyncStatus? syncStatus, bool? isDirty}) {
    return Account(
      id: id,
      tenantId: tenantId,
      code: code,
      name: name,
      accountType: accountType,
      normalBalance: normalBalance,
      groupId: groupId,
      currency: currency,
      parentAccountId: parentAccountId,
      isSystem: isSystem,
      active: active,
      balance: balance ?? this.balance,
      version: version ?? this.version,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      isDirty: isDirty ?? this.isDirty,
    );
  }

  @override
  List<Object?> get props => [id, code, accountType];
}
