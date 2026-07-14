import 'package:uuid/uuid.dart';

import 'package:fashion_pos_enterprise/core/audit/audit_action.dart';
import 'package:fashion_pos_enterprise/core/audit/audit_service.dart';
import 'package:fashion_pos_enterprise/core/business/domain/enums/business_enums.dart' as biz;
import 'package:fashion_pos_enterprise/core/business/engines/number_generator_engine.dart';
import 'package:fashion_pos_enterprise/core/business/engines/sales/sales_engine.dart';
import 'package:fashion_pos_enterprise/core/errors/failure.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_engine.dart';
import 'package:fashion_pos_enterprise/core/result/result.dart';
import 'package:fashion_pos_enterprise/features/auth/domain/entities/auth_user.dart';
import 'package:fashion_pos_enterprise/features/inventory/domain/services/stock_movement_service.dart';
import 'package:fashion_pos_enterprise/features/pos/domain/entities/payment.dart';
import 'package:fashion_pos_enterprise/features/pos/domain/entities/sale.dart';
import 'package:fashion_pos_enterprise/features/pos/domain/enums/pos_enums.dart';
import 'package:fashion_pos_enterprise/features/pos/domain/repositories/cash_repository.dart';
import 'package:fashion_pos_enterprise/features/pos/domain/repositories/sale_repository.dart';

class CheckoutService {
  CheckoutService({
    required SaleRepository saleRepository,
    required PaymentRepository paymentRepository,
    required CashRepository cashRepository,
    required SalesEngine salesEngine,
    required StockMovementService stockMovementService,
    required AuditService auditService,
    required PermissionEngine permissionEngine,
    required NumberGeneratorEngine numberGenerator,
    Uuid? uuid,
  })  : _sales = saleRepository,
        _payments = paymentRepository,
        _cash = cashRepository,
        _engine = salesEngine,
        _stock = stockMovementService,
        _audit = auditService,
        _permissions = permissionEngine,
        _numbers = numberGenerator,
        _uuid = uuid ?? const Uuid();

  final SaleRepository _sales;
  final PaymentRepository _payments;
  final CashRepository _cash;
  final SalesEngine _engine;
  final StockMovementService _stock;
  final AuditService _audit;
  final PermissionEngine _permissions;
  final NumberGeneratorEngine _numbers;
  final Uuid _uuid;

  Future<Result<Sale>> completeSale({
    required AuthUser user,
    required Sale draft,
    required List<Payment> payments,
    required String warehouseId,
  }) async {
    try {
      _permissions.require(user, SalePermissions.create);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }

    final lineCheck = _engine.validateLines(draft.lines);
    if (lineCheck.isFailure) return Error(lineCheck.failureOrNull!);

    final split = _engine.calculateSplitPayments(payments: payments, grandTotal: draft.grandTotal);
    if (!split.isBalanced) {
      return const Error(ValidationFailure(message: 'Payment total does not cover sale amount', code: 'payment_short'));
    }

    final tenantId = user.tenantId ?? draft.tenantId;
    final orderNumberResult = draft.orderNumber.isNotEmpty
        ? Success(draft.orderNumber)
        : (await _numbers.next(type: biz.DocumentNumberType.saleOrder, tenantId: tenantId, storeId: draft.storeId))
            .map((n) => n.value);
    if (orderNumberResult.isFailure) return Error(orderNumberResult.failureOrNull!);

    final now = DateTime.now().toUtc();
    final calculated = _engine.applyTotals(draft);
    final sale = calculated.copyWith(
      id: draft.id.isEmpty ? _uuid.v4() : draft.id,
      tenantId: tenantId,
      orderNumber: orderNumberResult.dataOrNull!,
      employeeId: user.employeeId ?? draft.employeeId,
      status: SaleStatus.completed,
      amountPaid: split.totalPaid,
      amountDue: 0,
      completedAt: now,
      version: 1,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    );

    final saved = await _sales.create(sale);

    for (final payment in payments) {
      final now = DateTime.now().toUtc();
      final p = Payment(
        id: payment.id.isEmpty ? _uuid.v4() : payment.id,
        tenantId: tenantId,
        saleOrderId: saved.id,
        paymentMethodId: payment.paymentMethodId,
        methodKind: payment.methodKind,
        status: payment.status,
        amount: payment.amount,
        currency: payment.currency,
        referenceNumber: payment.referenceNumber,
        cardLastFour: payment.cardLastFour,
        processedAt: payment.processedAt ?? now,
        version: 1,
        createdAt: now,
        updatedAt: now,
        syncStatus: LocalSyncStatus.pending,
        isDirty: true,
      );
      await _payments.create(p);
      _engine.publishPaymentReceived(
        saleId: saved.id,
        paymentId: p.id,
        amount: p.amount,
        tenantId: tenantId,
        storeId: saved.storeId,
      );
    }

    for (final line in saved.lines) {
      await _stock.issueStock(
        user: user,
        warehouseId: warehouseId,
        productId: line.productId,
        variantId: line.variantId,
        quantity: line.quantity,
        notes: 'Sale ${saved.orderNumber}',
      );
    }

    if (saved.cashSessionId != null) {
      final session = await _cash.getById(saved.cashSessionId!, tenantId: tenantId);
      if (session != null && session.isOpen) {
        await _cash.update(
          session.copyWith(
            totalSales: session.totalSales + saved.grandTotal,
            transactionCount: session.transactionCount + 1,
            expectedCash: session.expectedCash + saved.grandTotal,
            version: session.version + 1,
            updatedAt: now,
            syncStatus: LocalSyncStatus.pending,
            isDirty: true,
          ),
        );
      }
    }

    _engine.publishSaleCompleted(
      saleId: saved.id,
      grandTotal: saved.grandTotal,
      currencyCode: saved.currency,
      tenantId: tenantId,
      storeId: saved.storeId,
    );

    await _audit.log(
      action: AuditAction.sale,
      entityType: Sale.entityTypeName,
      entityId: saved.id,
      employeeId: user.employeeId,
      tenantId: tenantId,
      storeId: saved.storeId,
      metadata: {'order_number': saved.orderNumber, 'grand_total': saved.grandTotal},
    );

    return Success(saved);
  }

  Future<Result<Sale>> cancelSale({required AuthUser user, required Sale sale, String? reason}) async {
    try {
      _permissions.require(user, SalePermissions.cancel);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }

    final now = DateTime.now().toUtc();
    final cancelled = sale.copyWith(
      status: SaleStatus.cancelled,
      voidedAt: now,
      voidedBy: user.employeeId,
      voidReason: reason,
      version: sale.version + 1,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    );
    final saved = await _sales.update(cancelled);
    _engine.publishSaleCancelled(
      saleId: saved.id,
      reason: reason,
      tenantId: saved.tenantId,
      storeId: saved.storeId,
    );
    await _audit.log(
      action: AuditAction.refund,
      entityType: Sale.entityTypeName,
      entityId: saved.id,
      employeeId: user.employeeId,
      tenantId: saved.tenantId,
      storeId: saved.storeId,
      metadata: {'reason': reason},
    );
    return Success(saved);
  }
}
