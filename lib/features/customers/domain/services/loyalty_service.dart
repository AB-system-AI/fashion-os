import 'package:uuid/uuid.dart';

import 'package:fashion_pos_enterprise/core/audit/audit_action.dart';
import 'package:fashion_pos_enterprise/core/audit/audit_service.dart';
import 'package:fashion_pos_enterprise/core/business/domain/entities/loyalty_models.dart';
import 'package:fashion_pos_enterprise/core/business/domain/enums/business_enums.dart';
import 'package:fashion_pos_enterprise/core/business/domain/value_objects/money.dart';
import 'package:fashion_pos_enterprise/core/business/engines/loyalty_engine.dart';
import 'package:fashion_pos_enterprise/core/errors/failure.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_engine.dart';
import 'package:fashion_pos_enterprise/core/result/result.dart';
import 'package:fashion_pos_enterprise/features/auth/domain/entities/auth_user.dart';
import 'package:fashion_pos_enterprise/features/customers/domain/entities/customer.dart';
import 'package:fashion_pos_enterprise/features/customers/domain/entities/customer_loyalty_account.dart';
import 'package:fashion_pos_enterprise/features/customers/domain/entities/loyalty_point_transaction.dart';
import 'package:fashion_pos_enterprise/features/customers/domain/enums/customer_enums.dart';
import 'package:fashion_pos_enterprise/features/customers/domain/repositories/customer_repositories.dart';

class LoyaltyService {
  LoyaltyService({
    required CustomerRepository customerRepository,
    required CustomerLoyaltyAccountRepository accountRepository,
    required LoyaltyPointTransactionRepository transactionRepository,
    required LoyaltyEngine loyaltyEngine,
    required AuditService auditService,
    required PermissionEngine permissionEngine,
    Uuid? uuid,
  })  : _customers = customerRepository,
        _accounts = accountRepository,
        _transactions = transactionRepository,
        _engine = loyaltyEngine,
        _audit = auditService,
        _permissions = permissionEngine,
        _uuid = uuid ?? const Uuid();

  final CustomerRepository _customers;
  final CustomerLoyaltyAccountRepository _accounts;
  final LoyaltyPointTransactionRepository _transactions;
  final LoyaltyEngine _engine;
  final AuditService _audit;
  final PermissionEngine _permissions;
  final Uuid _uuid;

  static const _defaultProgramId = 'default-loyalty-program';

  LoyaltyProgram _defaultProgram() => const LoyaltyProgram(
        id: _defaultProgramId,
        name: 'Default',
        pointsPerCurrencyUnit: 1,
        currencyCode: 'USD',
        tiers: [
          LoyaltyTierConfig(tier: LoyaltyTier.standard, minPoints: 0, earnMultiplier: 1),
          LoyaltyTierConfig(tier: LoyaltyTier.silver, minPoints: 500, earnMultiplier: 1.25),
          LoyaltyTierConfig(tier: LoyaltyTier.gold, minPoints: 2000, earnMultiplier: 1.5),
          LoyaltyTierConfig(tier: LoyaltyTier.vip, minPoints: 5000, earnMultiplier: 2),
        ],
        birthdayBonusPoints: 100,
      );

  LoyaltyAccount _toEngineAccount(Customer customer, CustomerLoyaltyAccount account) {
    return LoyaltyAccount(
      customerId: customer.id,
      programId: account.programId,
      pointsBalance: account.pointsBalance,
      tier: LoyaltyTier.values.firstWhere(
        (t) => t.name == (account.tierName ?? customer.loyaltyTier ?? 'standard'),
        orElse: () => LoyaltyTier.standard,
      ),
      lifetimePoints: account.lifetimePoints,
      lastActivityAt: account.lastActivityAt,
      dateOfBirth: customer.birthDate,
    );
  }

  Future<Result<CustomerLoyaltyAccount>> enroll({
    required AuthUser user,
    required String customerId,
  }) async {
    try {
      _permissions.require(user, LoyaltyPermissions.manage);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }

    final customer = await _customers.getById(customerId, tenantId: user.tenantId);
    if (customer == null) {
      return const Error(ValidationFailure(message: 'Customer not found', code: 'not_found'));
    }

    final existing = await _accounts.findByCustomer(customer.tenantId, customerId);
    if (existing != null) return Success(existing);

    final now = DateTime.now().toUtc();
    final account = CustomerLoyaltyAccount(
      id: _uuid.v4(),
      tenantId: customer.tenantId,
      customerId: customerId,
      programId: _defaultProgramId,
      tierName: 'standard',
      version: 1,
      enrolledAt: now,
      createdAt: now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    );
    final created = await _accounts.create(account);
    await _audit.log(
      action: AuditAction.create,
      entityType: CustomerLoyaltyAccount.entityTypeName,
      tenantId: customer.tenantId,
      employeeId: user.employeeId,
      entityId: created.id,
    );
    return Success(created);
  }

  Future<Result<CustomerLoyaltyAccount>> earnFromSale({
    required AuthUser user,
    required String customerId,
    required double saleAmount,
    String currency = 'USD',
  }) async {
    return _process(
      user: user,
      customerId: customerId,
      type: LoyaltyTransactionType.earn,
      saleAmount: saleAmount,
      currency: currency,
    );
  }

  Future<Result<CustomerLoyaltyAccount>> redeem({
    required AuthUser user,
    required String customerId,
    required int points,
  }) async {
    return _process(
      user: user,
      customerId: customerId,
      type: LoyaltyTransactionType.redeem,
      points: points,
    );
  }

  Future<Result<CustomerLoyaltyAccount>> birthdayBonus({
    required AuthUser user,
    required String customerId,
  }) async {
    return _process(user: user, customerId: customerId, type: LoyaltyTransactionType.birthdayBonus);
  }

  Future<Result<CustomerLoyaltyAccount>> expirePoints({
    required AuthUser user,
    required String customerId,
    required int points,
  }) async {
    return _process(user: user, customerId: customerId, type: LoyaltyTransactionType.expire, points: points);
  }

  Future<Result<CustomerLoyaltyAccount>> campaignBonus({
    required AuthUser user,
    required String customerId,
    required int bonusPoints,
  }) async {
    try {
      _permissions.require(user, LoyaltyPermissions.manage);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }

    final customer = await _customers.getById(customerId, tenantId: user.tenantId);
    if (customer == null) {
      return const Error(ValidationFailure(message: 'Customer not found', code: 'not_found'));
    }
    var account = await _accounts.findByCustomer(customer.tenantId, customerId);
    account ??= (await enroll(user: user, customerId: customerId)).dataOrNull;
    if (account == null) {
      return const Error(ValidationFailure(message: 'Loyalty account not found', code: 'not_found'));
    }

    final result = _engine.applyCampaignBonus(
      request: LoyaltyTransactionRequest(
        account: _toEngineAccount(customer, account),
        type: LoyaltyTransactionType.earn,
        program: _defaultProgram(),
      ),
      bonusPoints: bonusPoints,
    );
    if (result.isFailure) return Error(result.failureOrNull!);
    return _persistLoyaltyResult(user, customer, account, result.dataOrNull!, LoyaltyPointLedgerType.campaign, bonusPoints);
  }

  Future<Result<CustomerLoyaltyAccount>> _process({
    required AuthUser user,
    required String customerId,
    required LoyaltyTransactionType type,
    double? saleAmount,
    String currency = 'USD',
    int? points,
  }) async {
    try {
      _permissions.require(user, LoyaltyPermissions.manage);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }

    final customer = await _customers.getById(customerId, tenantId: user.tenantId);
    if (customer == null) {
      return const Error(ValidationFailure(message: 'Customer not found', code: 'not_found'));
    }
    var account = await _accounts.findByCustomer(customer.tenantId, customerId);
    account ??= (await enroll(user: user, customerId: customerId)).dataOrNull;
    if (account == null) {
      return const Error(ValidationFailure(message: 'Loyalty account not found', code: 'not_found'));
    }

    final request = LoyaltyTransactionRequest(
      account: _toEngineAccount(customer, account),
      type: type,
      program: _defaultProgram(),
      saleAmount: saleAmount != null ? Money.fromMajor(saleAmount, currencyCode: currency) : null,
      pointsToRedeem: points,
    );
    final result = _engine.process(request);
    if (result.isFailure) return Error(result.failureOrNull!);

    final ledgerType = switch (type) {
      LoyaltyTransactionType.earn => LoyaltyPointLedgerType.earn,
      LoyaltyTransactionType.redeem => LoyaltyPointLedgerType.redeem,
      LoyaltyTransactionType.birthdayBonus => LoyaltyPointLedgerType.birthdayBonus,
      LoyaltyTransactionType.expire => LoyaltyPointLedgerType.expire,
      LoyaltyTransactionType.adjust => LoyaltyPointLedgerType.adjustment,
      _ => LoyaltyPointLedgerType.adjustment,
    };
    return _persistLoyaltyResult(user, customer, account, result.dataOrNull!, ledgerType, result.dataOrNull!.pointsDelta);
  }

  Future<Result<CustomerLoyaltyAccount>> _persistLoyaltyResult(
    AuthUser user,
    Customer customer,
    CustomerLoyaltyAccount account,
    LoyaltyTransactionResult engineResult,
    LoyaltyPointLedgerType ledgerType,
    int pointsDelta,
  ) async {
    final now = DateTime.now().toUtc();
    final updatedAccount = await _accounts.update(
      account.copyWith(
        pointsBalance: engineResult.account.pointsBalance,
        lifetimePoints: engineResult.account.lifetimePoints,
        tierName: engineResult.account.tier.name,
        lastActivityAt: now,
        updatedAt: now,
        syncStatus: LocalSyncStatus.pending,
        isDirty: true,
      ),
    );

    await _customers.update(
      customer.copyWith(
        loyaltyPoints: engineResult.account.pointsBalance,
        loyaltyTier: engineResult.account.tier.name,
        updatedAt: now,
        syncStatus: LocalSyncStatus.pending,
        isDirty: true,
      ),
    );

    await _transactions.create(
      LoyaltyPointTransaction(
        id: _uuid.v4(),
        tenantId: customer.tenantId,
        accountId: account.id,
        customerId: customer.id,
        transactionType: ledgerType,
        points: pointsDelta,
        balanceAfter: engineResult.account.pointsBalance,
        version: 1,
        createdAt: now,
        updatedAt: now,
        syncStatus: LocalSyncStatus.pending,
        isDirty: true,
      ),
    );

    await _audit.log(
      action: AuditAction.update,
      entityType: CustomerLoyaltyAccount.entityTypeName,
      tenantId: customer.tenantId,
      employeeId: user.employeeId,
      entityId: updatedAccount.id,
      metadata: {'type': ledgerType.value, 'points': pointsDelta},
    );
    return Success(updatedAccount);
  }

  Future<List<LoyaltyPointTransaction>> history(String tenantId, String customerId) {
    return _transactions.listByCustomer(tenantId, customerId);
  }
}
