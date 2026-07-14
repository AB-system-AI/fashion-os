import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';

class Supplier extends Equatable implements SyncableEntity {
  const Supplier({
    required this.id,
    required this.tenantId,
    required this.supplierCode,
    required this.companyName,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.contactName,
    this.phone,
    this.mobile,
    this.email,
    this.address,
    this.city,
    this.country = 'US',
    this.taxNumber,
    this.commercialRegistration,
    this.paymentTerms,
    this.creditLimit = 0,
    this.currentBalance = 0,
    this.notes,
    this.active = true,
    this.deletedAt,
  });

  static const entityTypeName = 'supplier';

  @override
  final String id;
  @override
  final String tenantId;
  final String supplierCode;
  final String companyName;
  final String? contactName;
  final String? phone;
  final String? mobile;
  final String? email;
  final String? address;
  final String? city;
  final String country;
  final String? taxNumber;
  final String? commercialRegistration;
  final String? paymentTerms;
  final double creditLimit;
  final double currentBalance;
  final String? notes;
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
        'code': supplierCode,
        'name': companyName,
        'contact_name': contactName,
        'phone': phone,
        'mobile': mobile,
        'email': email,
        'address_line1': address,
        'city': city,
        'country': country,
        'tax_id': taxNumber,
        'commercial_registration': commercialRegistration,
        'payment_terms': paymentTerms,
        'credit_limit': creditLimit,
        'current_balance': currentBalance,
        'notes': notes,
        'is_active': active,
        'version': version,
      };

  factory Supplier.fromPayload(Map<String, dynamic> json, LocalRecord record) {
    return Supplier(
      id: record.id,
      tenantId: record.tenantId,
      supplierCode: json['code'] as String? ?? json['supplier_code'] as String? ?? '',
      companyName: json['name'] as String? ?? json['company_name'] as String? ?? record.searchName ?? '',
      contactName: json['contact_name'] as String?,
      phone: json['phone'] as String?,
      mobile: json['mobile'] as String?,
      email: json['email'] as String?,
      address: json['address_line1'] as String? ?? json['address'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String? ?? 'US',
      taxNumber: json['tax_id'] as String? ?? json['tax_number'] as String?,
      commercialRegistration: json['commercial_registration'] as String?,
      paymentTerms: json['payment_terms'] as String?,
      creditLimit: (json['credit_limit'] as num?)?.toDouble() ?? 0,
      currentBalance: (json['current_balance'] as num?)?.toDouble() ?? 0,
      notes: json['notes'] as String?,
      active: json['is_active'] as bool? ?? json['active'] as bool? ?? true,
      version: record.version,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
      deletedAt: record.deletedAt,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  Supplier copyWith({
    String? supplierCode,
    String? companyName,
    String? contactName,
    String? phone,
    String? mobile,
    String? email,
    String? address,
    String? city,
    String? country,
    String? taxNumber,
    String? commercialRegistration,
    String? paymentTerms,
    double? creditLimit,
    double? currentBalance,
    String? notes,
    bool? active,
    int? version,
    DateTime? updatedAt,
    DateTime? deletedAt,
    LocalSyncStatus? syncStatus,
    bool? isDirty,
  }) {
    return Supplier(
      id: id,
      tenantId: tenantId,
      supplierCode: supplierCode ?? this.supplierCode,
      companyName: companyName ?? this.companyName,
      contactName: contactName ?? this.contactName,
      phone: phone ?? this.phone,
      mobile: mobile ?? this.mobile,
      email: email ?? this.email,
      address: address ?? this.address,
      city: city ?? this.city,
      country: country ?? this.country,
      taxNumber: taxNumber ?? this.taxNumber,
      commercialRegistration: commercialRegistration ?? this.commercialRegistration,
      paymentTerms: paymentTerms ?? this.paymentTerms,
      creditLimit: creditLimit ?? this.creditLimit,
      currentBalance: currentBalance ?? this.currentBalance,
      notes: notes ?? this.notes,
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
  List<Object?> get props => [id, supplierCode, companyName, active];
}
