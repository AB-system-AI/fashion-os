import 'package:uuid/uuid.dart';

import 'package:fashion_pos_enterprise/core/audit/audit_action.dart';
import 'package:fashion_pos_enterprise/core/audit/audit_service.dart';
import 'package:fashion_pos_enterprise/core/business/domain/enums/business_enums.dart' as biz;
import 'package:fashion_pos_enterprise/core/business/domain/entities/cash_session_models.dart' as engine;
import 'package:fashion_pos_enterprise/core/business/engines/cash_session_engine.dart';
import 'package:fashion_pos_enterprise/core/business/engines/number_generator_engine.dart';
import 'package:fashion_pos_enterprise/core/business/engines/sales/sales_engine.dart';
import 'package:fashion_pos_enterprise/core/business/domain/value_objects/money.dart';
import 'package:fashion_pos_enterprise/core/errors/failure.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/pagination/paginated_result.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/repository/repository_query.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_engine.dart';
import 'package:fashion_pos_enterprise/core/result/result.dart';
import 'package:fashion_pos_enterprise/core/search/product_search_service.dart';
import 'package:fashion_pos_enterprise/features/auth/domain/entities/auth_user.dart';
import 'package:fashion_pos_enterprise/features/pos/domain/entities/cash_movement.dart';
import 'package:fashion_pos_enterprise/features/pos/domain/entities/cash_session.dart';
import 'package:fashion_pos_enterprise/features/pos/domain/entities/sale.dart';
import 'package:fashion_pos_enterprise/features/pos/domain/entities/sale_line.dart';
import 'package:fashion_pos_enterprise/features/pos/domain/entities/suspended_sale.dart';
import 'package:fashion_pos_enterprise/features/pos/domain/enums/pos_enums.dart';
import 'package:fashion_pos_enterprise/features/pos/domain/repositories/cash_repository.dart';
import 'package:fashion_pos_enterprise/features/pos/domain/repositories/sale_repository.dart';

class POSService {
  POSService({
    required SaleRepository saleRepository,
    required SuspendedSaleRepository suspendedSaleRepository,
    required SalesEngine salesEngine,
    required ProductSearchService productSearch,
    required AuditService auditService,
    required PermissionEngine permissionEngine,
    Uuid? uuid,
  })  : _sales = saleRepository,
        _suspended = suspendedSaleRepository,
        _engine = salesEngine,
        _search = productSearch,
        _audit = auditService,
        _permissions = permissionEngine,
        _uuid = uuid ?? const Uuid();

  final SaleRepository _sales;
  final SuspendedSaleRepository _suspended;
  final SalesEngine _engine;
  final ProductSearchService _search;
  final AuditService _audit;
  final PermissionEngine _permissions;
  final Uuid _uuid;

  Future<PaginatedResult<Sale>> listSales({
    required AuthUser user,
    required String tenantId,
    int page = 1,
  }) async {
    try {
      _permissions.require(user, SalePermissions.view);
    } on PermissionDeniedException {
      return PaginatedResult(items: const [], page: page, pageSize: 50, totalCount: 0, hasMore: false);
    }
    return _sales.getPage(RepositoryQuery(tenantId: tenantId, page: page, pageSize: 50, sortBy: 'updated_at'));
  }

  Future<Result<Sale>> createDraft({
    required AuthUser user,
    required String storeId,
    String? registerId,
    String? cashSessionId,
  }) async {
    try {
      _permissions.require(user, SalePermissions.create);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }

    final now = DateTime.now().toUtc();
    final tenantId = user.tenantId ?? '';
    final sale = Sale(
      id: _uuid.v4(),
      tenantId: tenantId,
      storeId: storeId,
      orderNumber: '',
      employeeId: user.employeeId ?? '',
      registerId: registerId,
      cashSessionId: cashSessionId,
      lines: const [],
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    );
    final saved = await _sales.create(sale);
    return Success(saved);
  }

  Future<Result<Sale>> addLine({
    required AuthUser user,
    required Sale sale,
    required SaleLine line,
  }) async {
    try {
      _permissions.require(user, SalePermissions.update);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }

    final lines = [...sale.lines, line.copyWith(id: line.id.isEmpty ? _uuid.v4() : line.id)];
    final updated = _engine.applyTotals(sale.copyWith(
      lines: lines,
      version: sale.version + 1,
      updatedAt: DateTime.now().toUtc(),
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    ));
    return Success(await _sales.update(updated));
  }

  Future<Result<SuspendedSale>> suspendSale({
    required AuthUser user,
    required Sale sale,
    String? label,
  }) async {
    try {
      _permissions.require(user, SalePermissions.update);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }

    final now = DateTime.now().toUtc();
    final suspendedSale = sale.copyWith(status: SaleStatus.suspended, updatedAt: now);
    await _sales.update(suspendedSale);

    final suspended = SuspendedSale(
      id: _uuid.v4(),
      tenantId: sale.tenantId,
      storeId: sale.storeId,
      sale: suspendedSale,
      suspendedBy: user.employeeId ?? user.userId,
      label: label,
      suspendedAt: now,
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    );
    final saved = await _suspended.create(suspended);
    await _audit.log(
      action: AuditAction.update,
      entityType: SuspendedSale.entityTypeName,
      entityId: saved.id,
      employeeId: user.employeeId,
      tenantId: sale.tenantId,
      storeId: sale.storeId,
      metadata: {'order_number': sale.orderNumber},
    );
    return Success(saved);
  }

  Future<Result<Sale>> resumeSale({required AuthUser user, required SuspendedSale suspended}) async {
    try {
      _permissions.require(user, SalePermissions.update);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }

    final sale = suspended.sale.copyWith(
      status: SaleStatus.draft,
      version: suspended.sale.version + 1,
      updatedAt: DateTime.now().toUtc(),
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    );
    return Success(await _sales.update(sale));
  }

  Future<List<ProductSearchResult>> searchProducts(String tenantId, String query) =>
      _search.search(tenantId: tenantId, query: query);

  Future<ProductSearchResult?> findByBarcode(String tenantId, String barcode) =>
      _search.findByBarcode(tenantId: tenantId, barcode: barcode);
}

class CashDrawerService {
  CashDrawerService({
    required CashRepository cashRepository,
    required CashSessionEngine cashSessionEngine,
    required SalesEngine salesEngine,
    required AuditService auditService,
    required PermissionEngine permissionEngine,
    required NumberGeneratorEngine numberGenerator,
    Uuid? uuid,
  })  : _cash = cashRepository,
        _engine = cashSessionEngine,
        _salesEngine = salesEngine,
        _audit = auditService,
        _permissions = permissionEngine,
        _numbers = numberGenerator,
        _uuid = uuid ?? const Uuid();

  final CashRepository _cash;
  final CashSessionEngine _engine;
  final SalesEngine _salesEngine;
  final AuditService _audit;
  final PermissionEngine _permissions;
  final NumberGeneratorEngine _numbers;
  final Uuid _uuid;

  Future<Result<CashSession>> openSession({
    required AuthUser user,
    required String storeId,
    required String registerId,
    required double openingFloat,
  }) async {
    try {
      _permissions.require(user, SalePermissions.cash);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }

    final tenantId = user.tenantId ?? '';
    final existing = await _cash.findOpenSession(tenantId, registerId);
    if (existing != null) {
      return const Error(ValidationFailure(message: 'Register already has an open session', code: 'session_open'));
    }

    final numberResult = await _numbers.next(
      type: biz.DocumentNumberType.cashSession,
      tenantId: tenantId,
      storeId: storeId,
    );
    if (numberResult.isFailure) return Error(numberResult.failureOrNull!);

    final sessionId = _uuid.v4();
    final openResult = _engine.openSession(
      sessionId: sessionId,
      storeId: storeId,
      registerId: registerId,
      employeeId: user.employeeId ?? user.userId,
      openingFloat: Money.fromMajor(openingFloat),
    );
    if (openResult.isFailure) return Error(openResult.failureOrNull!);

    final now = DateTime.now().toUtc();
    final session = CashSession(
      id: sessionId,
      tenantId: tenantId,
      storeId: storeId,
      registerId: registerId,
      sessionNumber: numberResult.dataOrNull!.value,
      employeeId: user.employeeId ?? user.userId,
      openingFloat: openingFloat,
      expectedCash: openingFloat,
      openedAt: now,
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    );
    final saved = await _cash.create(session);
    await _audit.log(
      action: AuditAction.create,
      entityType: CashSession.entityTypeName,
      entityId: saved.id,
      employeeId: user.employeeId,
      tenantId: tenantId,
      storeId: storeId,
      metadata: {'opening_float': openingFloat},
    );
    return Success(saved);
  }

  Future<Result<CashSession>> closeSession({
    required AuthUser user,
    required CashSession session,
    required double actualCash,
    String? notes,
  }) async {
    try {
      _permissions.require(user, SalePermissions.closeSession);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }

    final closeResult = _engine.closeSession(
      session: _toEngineSession(session),
      actualCash: Money.fromMajor(actualCash),
    );
    if (closeResult.isFailure) return Error(closeResult.failureOrNull!);

    final difference = actualCash - session.expectedCash;
    final now = DateTime.now().toUtc();
    final saved = await _cash.update(
      session.copyWith(
        status: CashSessionStatus.closed,
        actualCash: actualCash,
        cashDifference: difference,
        closedAt: now,
        notes: notes,
        version: session.version + 1,
        updatedAt: now,
        syncStatus: LocalSyncStatus.pending,
        isDirty: true,
      ),
    );

    _salesEngine.publishCashSessionClosed(
      sessionId: saved.id,
      actualCash: actualCash,
      difference: difference,
      tenantId: saved.tenantId,
      storeId: saved.storeId,
    );

    await _audit.log(
      action: AuditAction.update,
      entityType: CashSession.entityTypeName,
      entityId: saved.id,
      employeeId: user.employeeId,
      tenantId: saved.tenantId,
      storeId: saved.storeId,
      metadata: {'actual_cash': actualCash, 'difference': difference},
    );
    return Success(saved);
  }

  Future<Result<CashMovement>> recordMovement({
    required AuthUser user,
    required CashSession session,
    required CashMovementType type,
    required double amount,
    String? notes,
  }) async {
    try {
      _permissions.require(user, SalePermissions.cash);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }

    final movementResult = _engine.recordMovement(
      movementId: _uuid.v4(),
      session: _toEngineSession(session),
      type: _mapMovementType(type),
      amount: Money.fromMajor(amount),
      notes: notes,
    );
    if (movementResult.isFailure) return Error(movementResult.failureOrNull!);

    final now = DateTime.now().toUtc();
    final movement = CashMovement(
      id: movementResult.dataOrNull!.id,
      tenantId: session.tenantId,
      sessionId: session.id,
      movementType: type,
      amount: amount,
      notes: notes,
      employeeId: user.employeeId,
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    );
    final saved = await _cash.createMovement(movement);
    await _audit.log(
      action: AuditAction.update,
      entityType: CashMovement.entityTypeName,
      entityId: saved.id,
      employeeId: user.employeeId,
      tenantId: session.tenantId,
      storeId: session.storeId,
      metadata: {'type': type.value, 'amount': amount},
    );
    return Success(saved);
  }

  biz.CashMovementType _mapMovementType(CashMovementType type) {
    return switch (type) {
      CashMovementType.sale => biz.CashMovementType.sale,
      CashMovementType.refund => biz.CashMovementType.refund,
      CashMovementType.cashIn || CashMovementType.safeDrop => biz.CashMovementType.cashIn,
      CashMovementType.cashOut || CashMovementType.expense => biz.CashMovementType.cashOut,
      CashMovementType.openingFloat => biz.CashMovementType.openingFloat,
      CashMovementType.closingFloat => biz.CashMovementType.closingFloat,
    };
  }

  engine.CashSession _toEngineSession(CashSession session) {
    return engine.CashSession(
      id: session.id,
      storeId: session.storeId,
      registerId: session.registerId,
      employeeId: session.employeeId,
      openingFloat: Money.fromMajor(session.openingFloat),
      openedAt: session.openedAt ?? session.createdAt,
      totalSales: Money.fromMajor(session.totalSales),
      totalRefunds: Money.fromMajor(session.totalRefunds),
      transactionCount: session.transactionCount,
      expectedCash: Money.fromMajor(session.expectedCash),
      isOpen: session.isOpen,
    );
  }
}
