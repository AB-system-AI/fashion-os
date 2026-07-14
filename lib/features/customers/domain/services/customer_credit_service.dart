import 'package:uuid/uuid.dart';

import 'package:fashion_pos_enterprise/core/audit/audit_action.dart';
import 'package:fashion_pos_enterprise/core/audit/audit_service.dart';
import 'package:fashion_pos_enterprise/core/errors/failure.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_engine.dart';
import 'package:fashion_pos_enterprise/core/result/result.dart';
import 'package:fashion_pos_enterprise/features/auth/domain/entities/auth_user.dart';
import 'package:fashion_pos_enterprise/features/customers/domain/entities/customer.dart';
import 'package:fashion_pos_enterprise/features/customers/domain/entities/customer_credit.dart';
import 'package:fashion_pos_enterprise/features/customers/domain/enums/customer_enums.dart';
import 'package:fashion_pos_enterprise/features/customers/domain/repositories/customer_repositories.dart';

class CustomerCreditService {
  CustomerCreditService({
    required CustomerRepository customerRepository,
    required CustomerCreditRepository creditRepository,
    required AuditService auditService,
    required PermissionEngine permissionEngine,
    Uuid? uuid,
  })  : _customers = customerRepository,
        _credits = creditRepository,
        _audit = auditService,
        _permissions = permissionEngine,
        _uuid = uuid ?? const Uuid();

  final CustomerRepository _customers;
  final CustomerCreditRepository _credits;
  final AuditService _audit;
  final PermissionEngine _permissions;
  final Uuid _uuid;

  Future<Result<void>> validateForSale({
    required AuthUser user,
    required String customerId,
    required double saleAmount,
  }) async {
    final account = await _getOrCreateAccount(user.tenantId!, customerId);
    if (account.remainingCredit < saleAmount) {
      return const Error(ValidationFailure(message: 'Credit limit exceeded', code: 'credit_exceeded'));
    }
    return const Success(null);
  }

  Future<Result<CustomerCreditAccount>> charge({
    required AuthUser user,
    required String customerId,
    required double amount,
    String? reference,
  }) => _apply(
        user: user,
        customerId: customerId,
        amount: amount,
        type: CreditTransactionType.charge,
        reference: reference,
      );

  Future<Result<CustomerCreditAccount>> recordPayment({
    required AuthUser user,
    required String customerId,
    required double amount,
    String? reference,
  }) => _apply(
        user: user,
        customerId: customerId,
        amount: -amount,
        type: CreditTransactionType.payment,
        reference: reference,
      );

  Future<Result<CustomerCreditAccount>> _apply({
    required AuthUser user,
    required String customerId,
    required double amount,
    required CreditTransactionType type,
    String? reference,
  }) async {
    try {
      _permissions.require(user, CreditPermissions.manage);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }

    if (amount == 0) {
      return const Error(ValidationFailure(message: 'Amount cannot be zero', code: 'invalid_amount'));
    }

    final customer = await _customers.getById(customerId, tenantId: user.tenantId);
    if (customer == null) {
      return const Error(ValidationFailure(message: 'Customer not found', code: 'not_found'));
    }

    final now = DateTime.now().toUtc();
    var account = await _getOrCreateAccount(customer.tenantId, customerId);
    final nextOutstanding = account.outstandingBalance + amount;
    if (nextOutstanding < 0) {
      return const Error(ValidationFailure(message: 'Payment exceeds outstanding balance', code: 'invalid_amount'));
    }
    if (nextOutstanding > account.creditLimit) {
      return const Error(ValidationFailure(message: 'Credit limit exceeded', code: 'credit_exceeded'));
    }

    final entry = CreditTransaction(
      id: _uuid.v4(),
      type: type,
      amount: amount.abs(),
      balanceAfter: nextOutstanding,
      occurredAt: now,
      reference: reference,
    );

    final updated = await _credits.update(
      account.copyWith(
        outstandingBalance: nextOutstanding,
        transactions: [...account.transactions, entry],
        updatedAt: now,
        syncStatus: LocalSyncStatus.pending,
        isDirty: true,
      ),
    );

    await _customers.update(
      customer.copyWith(
        outstandingCredit: nextOutstanding,
        updatedAt: now,
        syncStatus: LocalSyncStatus.pending,
        isDirty: true,
      ),
    );

    await _audit.log(
      action: AuditAction.update,
      entityType: CustomerCreditAccount.entityTypeName,
      tenantId: customer.tenantId,
      employeeId: user.employeeId,
      entityId: updated.id,
      metadata: {'type': type.value, 'amount': amount},
    );
    return Success(updated);
  }

  Future<CustomerCreditAccount> _getOrCreateAccount(String tenantId, String customerId) async {
    final existing = await _credits.findByCustomer(tenantId, customerId);
    if (existing != null) return existing;

    final customer = await _customers.getById(customerId, tenantId: tenantId);
    final now = DateTime.now().toUtc();
    return _credits.create(
      CustomerCreditAccount(
        id: _uuid.v4(),
        tenantId: tenantId,
        customerId: customerId,
        creditLimit: customer?.creditLimit ?? 0,
        outstandingBalance: customer?.outstandingCredit ?? 0,
        version: 1,
        createdAt: now,
        updatedAt: now,
        syncStatus: LocalSyncStatus.pending,
        isDirty: true,
      ),
    );
  }

  Future<CustomerCreditAccount?> getAccount(String tenantId, String customerId) {
    return _credits.findByCustomer(tenantId, customerId);
  }
}
