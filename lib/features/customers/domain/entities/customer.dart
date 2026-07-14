import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/features/customers/domain/enums/customer_enums.dart';

class Customer extends Equatable implements SyncableEntity {
  const Customer({
    required this.id,
    required this.tenantId,
    required this.customerCode,
    required this.firstName,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.lastName,
    this.phone,
    this.mobile,
    this.email,
    this.gender,
    this.birthDate,
    this.address,
    this.city,
    this.country = 'US',
    this.notes,
    this.tags = const [],
    this.groupId,
    this.loyaltyTier,
    this.loyaltyPoints = 0,
    this.walletBalance = 0,
    this.creditLimit = 0,
    this.outstandingCredit = 0,
    this.totalPurchases = 0,
    this.totalOrders = 0,
    this.lastPurchaseAt,
    this.membershipBarcode,
    this.active = true,
    this.deletedAt,
  });

  static const entityTypeName = 'customer';

  @override
  final String id;
  @override
  final String tenantId;
  final String customerCode;
  final String firstName;
  final String? lastName;
  final String? phone;
  final String? mobile;
  final String? email;
  final CustomerGender? gender;
  final DateTime? birthDate;
  final String? address;
  final String? city;
  final String country;
  final String? notes;
  final List<String> tags;
  final String? groupId;
  final String? loyaltyTier;
  final int loyaltyPoints;
  final double walletBalance;
  final double creditLimit;
  final double outstandingCredit;
  final double totalPurchases;
  final int totalOrders;
  final DateTime? lastPurchaseAt;
  final String? membershipBarcode;
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

  String get fullName => [firstName, lastName].where((s) => s != null && s.isNotEmpty).join(' ').trim();

  double get remainingCredit => (creditLimit - outstandingCredit).clamp(0, double.infinity);

  @override
  String get entityType => entityTypeName;

  @override
  Map<String, dynamic> toPayload() => {
        'id': id,
        'tenant_id': tenantId,
        'customer_code': customerCode,
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'phone': phone ?? mobile,
        'mobile': mobile,
        'gender': gender?.value,
        'date_of_birth': birthDate?.toIso8601String().split('T').first,
        'address': address,
        'city': city,
        'country': country,
        'notes': notes,
        'tags': tags,
        'group_id': groupId,
        'loyalty_tier': loyaltyTier,
        'loyalty_points': loyaltyPoints,
        'wallet_balance': walletBalance,
        'credit_limit': creditLimit,
        'outstanding_credit': outstandingCredit,
        'total_spent': totalPurchases,
        'total_orders': totalOrders,
        'last_order_at': lastPurchaseAt?.toIso8601String(),
        'membership_barcode': membershipBarcode,
        'is_active': active,
        'version': version,
      };

  factory Customer.fromPayload(Map<String, dynamic> json, LocalRecord record) {
    final rawTags = json['tags'] as List<dynamic>? ?? const [];
    return Customer(
      id: record.id,
      tenantId: record.tenantId,
      customerCode: json['customer_code'] as String? ?? record.searchSku ?? '',
      firstName: json['first_name'] as String? ?? record.searchName ?? '',
      lastName: json['last_name'] as String?,
      phone: json['phone'] as String?,
      mobile: json['mobile'] as String?,
      email: json['email'] as String?,
      gender: CustomerGender.fromValue(json['gender'] as String?),
      birthDate: json['date_of_birth'] != null ? DateTime.tryParse(json['date_of_birth'] as String) : null,
      address: json['address'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String? ?? 'US',
      notes: json['notes'] as String?,
      tags: rawTags.map((e) => e.toString()).toList(),
      groupId: json['group_id'] as String?,
      loyaltyTier: json['loyalty_tier'] as String?,
      loyaltyPoints: (json['loyalty_points'] as num?)?.toInt() ?? 0,
      walletBalance: (json['wallet_balance'] as num?)?.toDouble() ?? 0,
      creditLimit: (json['credit_limit'] as num?)?.toDouble() ?? 0,
      outstandingCredit: (json['outstanding_credit'] as num?)?.toDouble() ?? 0,
      totalPurchases: (json['total_spent'] as num?)?.toDouble() ?? 0,
      totalOrders: (json['total_orders'] as num?)?.toInt() ?? 0,
      lastPurchaseAt: json['last_order_at'] != null ? DateTime.tryParse(json['last_order_at'] as String) : null,
      membershipBarcode: json['membership_barcode'] as String? ?? record.searchBarcode,
      active: json['is_active'] as bool? ?? true,
      version: record.version,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
      deletedAt: record.deletedAt,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  Customer copyWith({
    String? firstName,
    String? lastName,
    String? phone,
    String? mobile,
    String? email,
    CustomerGender? gender,
    DateTime? birthDate,
    String? address,
    String? city,
    String? country,
    String? notes,
    List<String>? tags,
    String? groupId,
    String? loyaltyTier,
    int? loyaltyPoints,
    double? walletBalance,
    double? creditLimit,
    double? outstandingCredit,
    double? totalPurchases,
    int? totalOrders,
    DateTime? lastPurchaseAt,
    String? membershipBarcode,
    bool? active,
    int? version,
    DateTime? updatedAt,
    DateTime? deletedAt,
    LocalSyncStatus? syncStatus,
    bool? isDirty,
  }) {
    return Customer(
      id: id,
      tenantId: tenantId,
      customerCode: customerCode,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      mobile: mobile ?? this.mobile,
      email: email ?? this.email,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      address: address ?? this.address,
      city: city ?? this.city,
      country: country ?? this.country,
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
      groupId: groupId ?? this.groupId,
      loyaltyTier: loyaltyTier ?? this.loyaltyTier,
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
      walletBalance: walletBalance ?? this.walletBalance,
      creditLimit: creditLimit ?? this.creditLimit,
      outstandingCredit: outstandingCredit ?? this.outstandingCredit,
      totalPurchases: totalPurchases ?? this.totalPurchases,
      totalOrders: totalOrders ?? this.totalOrders,
      lastPurchaseAt: lastPurchaseAt ?? this.lastPurchaseAt,
      membershipBarcode: membershipBarcode ?? this.membershipBarcode,
      active: active ?? this.active,
      version: version ?? this.version,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      isDirty: isDirty ?? this.isDirty,
    );
  }

  @override
  List<Object?> get props => [id, customerCode, fullName, active];
}
