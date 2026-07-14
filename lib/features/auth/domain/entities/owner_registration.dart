import 'package:equatable/equatable.dart';

class OwnerRegistration extends Equatable {
  const OwnerRegistration({
    required this.email,
    required this.password,
    required this.fullName,
    required this.tenantName,
    required this.tenantSlug,
    required this.storeName,
    this.storeCode = 'MAIN',
    this.currency = 'USD',
    this.timezone = 'UTC',
    this.country = 'US',
  });

  final String email;
  final String password;
  final String fullName;
  final String tenantName;
  final String tenantSlug;
  final String storeName;
  final String storeCode;
  final String currency;
  final String timezone;
  final String country;

  @override
  List<Object?> get props => [
        email,
        fullName,
        tenantName,
        tenantSlug,
        storeName,
        storeCode,
        currency,
        timezone,
        country,
      ];
}

class OrganizationContext extends Equatable {
  const OrganizationContext({
    required this.tenantId,
    required this.storeId,
    required this.warehouseId,
    required this.employeeId,
    required this.roleId,
  });

  final String tenantId;
  final String storeId;
  final String warehouseId;
  final String employeeId;
  final String roleId;

  factory OrganizationContext.fromJson(Map<String, dynamic> json) {
    return OrganizationContext(
      tenantId: json['tenant_id'] as String,
      storeId: json['store_id'] as String,
      warehouseId: json['warehouse_id'] as String,
      employeeId: json['employee_id'] as String,
      roleId: json['role_id'] as String,
    );
  }

  @override
  List<Object?> get props => [tenantId, storeId, warehouseId, employeeId, roleId];
}
