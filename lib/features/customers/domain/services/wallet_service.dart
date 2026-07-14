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
import 'package:fashion_pos_enterprise/features/customers/domain/entities/customer_wallet.dart';
import 'package:fashion_pos_enterprise/features/customers/domain/enums/customer_enums.dart';
import 'package:fashion_pos_enterprise/features/customers/domain/repositories/customer_repositories.dart';

class WalletService {
  WalletService({
    required CustomerRepository customerRepository,
    required CustomerWalletRepository walletRepository,
    required AuditService auditService,
    required PermissionEngine permissionEngine,
    Uuid? uuid,
  })  : _customers = customerRepository,
        _wallets = walletRepository,
        _audit = auditService,
        _permissions = permissionEngine,
        _uuid = uuid ?? const Uuid();

  final CustomerRepository _customers;
  final CustomerWalletRepository _wallets;
  final AuditService _audit;
  final PermissionEngine _permissions;
  final Uuid _uuid;

  Future<Result<CustomerWallet>> deposit({
    required AuthUser user,
    required String customerId,
    required double amount,
    String? reference,
    String? notes,
  }) => _apply(
        user: user,
        customerId: customerId,
        amount: amount,
        type: WalletTransactionType.deposit,
        reference: reference,
        notes: notes,
      );

  Future<Result<CustomerWallet>> withdraw({
    required AuthUser user,
    required String customerId,
    required double amount,
    String? reference,
    String? notes,
  }) => _apply(
        user: user,
        customerId: customerId,
        amount: -amount,
        type: WalletTransactionType.withdraw,
        reference: reference,
        notes: notes,
      );

  Future<Result<CustomerWallet>> refund({
    required AuthUser user,
    required String customerId,
    required double amount,
    String? reference,
  }) => _apply(
        user: user,
        customerId: customerId,
        amount: amount,
        type: WalletTransactionType.refund,
        reference: reference,
      );

  Future<Result<CustomerWallet>> payPurchase({
    required AuthUser user,
    required String customerId,
    required double amount,
    String? reference,
  }) => _apply(
        user: user,
        customerId: customerId,
        amount: -amount,
        type: WalletTransactionType.purchasePayment,
        reference: reference,
      );

  Future<Result<CustomerWallet>> adjust({
    required AuthUser user,
    required String customerId,
    required double amount,
    String? notes,
  }) => _apply(
        user: user,
        customerId: customerId,
        amount: amount,
        type: WalletTransactionType.adjustment,
        notes: notes,
      );

  Future<Result<CustomerWallet>> _apply({
    required AuthUser user,
    required String customerId,
    required double amount,
    required WalletTransactionType type,
    String? reference,
    String? notes,
  }) async {
    try {
      _permissions.require(user, WalletPermissions.manage);
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
    var wallet = await _wallets.findByCustomer(customer.tenantId, customerId);
    if (wallet == null) {
      wallet = CustomerWallet(
        id: _uuid.v4(),
        tenantId: customer.tenantId,
        customerId: customerId,
        balance: 0,
        version: 1,
        createdAt: now,
        updatedAt: now,
        syncStatus: LocalSyncStatus.pending,
        isDirty: true,
      );
      wallet = await _wallets.create(wallet);
    }

    final nextBalance = wallet.balance + amount;
    if (nextBalance < 0) {
      return const Error(ValidationFailure(message: 'Insufficient wallet balance', code: 'insufficient_balance'));
    }

    final entry = WalletTransaction(
      id: _uuid.v4(),
      type: type,
      amount: amount.abs(),
      balanceAfter: nextBalance,
      occurredAt: now,
      reference: reference,
      notes: notes,
    );

    final updatedWallet = await _wallets.update(
      wallet.copyWith(
        balance: nextBalance,
        transactions: [...wallet.transactions, entry],
        updatedAt: now,
        syncStatus: LocalSyncStatus.pending,
        isDirty: true,
      ),
    );

    await _customers.update(
      customer.copyWith(
        walletBalance: nextBalance,
        updatedAt: now,
        syncStatus: LocalSyncStatus.pending,
        isDirty: true,
      ),
    );

    await _audit.log(
      action: AuditAction.update,
      entityType: CustomerWallet.entityTypeName,
      tenantId: customer.tenantId,
      employeeId: user.employeeId,
      entityId: updatedWallet.id,
      metadata: {'type': type.value, 'amount': amount},
    );
    return Success(updatedWallet);
  }

  Future<CustomerWallet?> getWallet(String tenantId, String customerId) {
    return _wallets.findByCustomer(tenantId, customerId);
  }
}
