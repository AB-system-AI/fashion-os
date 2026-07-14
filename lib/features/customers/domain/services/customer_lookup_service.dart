import 'package:fashion_pos_enterprise/core/errors/failure.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_engine.dart';
import 'package:fashion_pos_enterprise/core/result/result.dart';
import 'package:fashion_pos_enterprise/features/auth/domain/entities/auth_user.dart';
import 'package:fashion_pos_enterprise/features/customers/domain/entities/customer.dart';
import 'package:fashion_pos_enterprise/features/customers/domain/repositories/customer_repositories.dart';

class CustomerLookupService {
  CustomerLookupService({
    required CustomerRepository customerRepository,
    required PermissionEngine permissionEngine,
  })  : _customers = customerRepository,
        _permissions = permissionEngine;

  final CustomerRepository _customers;
  final PermissionEngine _permissions;

  Future<Result<Customer>> lookupByPhone({
    required AuthUser user,
    required String phone,
  }) async {
    try {
      _permissions.require(user, CustomerPermissions.view);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }

    final tenantId = user.tenantId;
    if (tenantId == null) {
      return const Error(ValidationFailure(message: 'No tenant context', code: 'no_tenant'));
    }

    final customer = await _customers.findByPhone(tenantId, phone.trim());
    if (customer == null) {
      return const Error(ValidationFailure(message: 'Customer not found', code: 'not_found'));
    }
    return Success(customer);
  }

  Future<Result<Customer>> lookupByCode({
    required AuthUser user,
    required String customerCode,
  }) async {
    try {
      _permissions.require(user, CustomerPermissions.view);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }

    final tenantId = user.tenantId;
    if (tenantId == null) {
      return const Error(ValidationFailure(message: 'No tenant context', code: 'no_tenant'));
    }

    final customer = await _customers.findByCode(tenantId, customerCode.trim());
    if (customer == null) {
      return const Error(ValidationFailure(message: 'Customer not found', code: 'not_found'));
    }
    return Success(customer);
  }

  Future<Result<Customer>> lookupByMembershipBarcode({
    required AuthUser user,
    required String barcode,
  }) async {
    try {
      _permissions.require(user, CustomerPermissions.view);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }

    final tenantId = user.tenantId;
    if (tenantId == null) {
      return const Error(ValidationFailure(message: 'No tenant context', code: 'no_tenant'));
    }

    final customer = await _customers.findByMembershipBarcode(tenantId, barcode.trim());
    if (customer == null) {
      return const Error(ValidationFailure(message: 'Customer not found', code: 'not_found'));
    }
    return Success(customer);
  }

  Future<Result<Customer>> posLookup({
    required AuthUser user,
    required String query,
  }) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return const Error(ValidationFailure(message: 'Lookup query required', code: 'invalid_query'));
    }

    final byPhone = await lookupByPhone(user: user, phone: trimmed);
    if (byPhone.isSuccess) return byPhone;

    final byCode = await lookupByCode(user: user, customerCode: trimmed);
    if (byCode.isSuccess) return byCode;

    return lookupByMembershipBarcode(user: user, barcode: trimmed);
  }
}
