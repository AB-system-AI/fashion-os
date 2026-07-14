import 'package:uuid/uuid.dart';

import 'package:fashion_pos_enterprise/core/audit/audit_action.dart';
import 'package:fashion_pos_enterprise/core/audit/audit_service.dart';
import 'package:fashion_pos_enterprise/core/errors/failure.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_engine.dart';
import 'package:fashion_pos_enterprise/core/result/result.dart';
import 'package:fashion_pos_enterprise/features/auth/domain/entities/auth_user.dart';
import 'package:fashion_pos_enterprise/features/purchasing/domain/entities/supplier.dart';
import 'package:fashion_pos_enterprise/features/purchasing/domain/entities/supplier_payment.dart';
import 'package:fashion_pos_enterprise/features/purchasing/domain/enums/purchasing_enums.dart';
import 'package:fashion_pos_enterprise/features/purchasing/domain/repositories/purchasing_repositories.dart';

class SupplierFinancialService {
  SupplierFinancialService({
    required SupplierRepository supplierRepository,
    required SupplierPaymentRepository paymentRepository,
    required SupplierStatementRepository statementRepository,
    required PurchaseOrderRepository purchaseOrderRepository,
    required AuditService auditService,
    required PermissionEngine permissionEngine,
    Uuid? uuid,
  })  : _suppliers = supplierRepository,
        _payments = paymentRepository,
        _statements = statementRepository,
        _orders = purchaseOrderRepository,
        _audit = auditService,
        _permissions = permissionEngine,
        _uuid = uuid ?? const Uuid();

  final SupplierRepository _suppliers;
  final SupplierPaymentRepository _payments;
  final SupplierStatementRepository _statements;
  final PurchaseOrderRepository _orders;
  final AuditService _audit;
  final PermissionEngine _permissions;
  final Uuid _uuid;

  Future<Result<SupplierPayment>> recordPayment({
    required AuthUser user,
    required String supplierId,
    required double amount,
    String? purchaseOrderId,
    String? reference,
    String? notes,
  }) async {
    try {
      _permissions.require(user, PurchasePermissions.payment);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }

    if (amount <= 0) {
      return const Error(ValidationFailure(message: 'Payment amount must be positive', code: 'invalid_amount'));
    }

    final supplier = await _suppliers.getById(supplierId, tenantId: user.tenantId);
    if (supplier == null) {
      return const Error(ValidationFailure(message: 'Supplier not found', code: 'not_found'));
    }

    final now = DateTime.now().toUtc();
    final payment = SupplierPayment(
      id: _uuid.v4(),
      tenantId: supplier.tenantId,
      supplierId: supplierId,
      purchaseOrderId: purchaseOrderId,
      amount: amount,
      type: SupplierPaymentType.payment,
      reference: reference,
      notes: notes,
      paidAt: now,
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    );

    final created = await _payments.create(payment);
    await _suppliers.update(
      supplier.copyWith(
        currentBalance: (supplier.currentBalance - amount).clamp(0, double.infinity),
        updatedAt: now,
        syncStatus: LocalSyncStatus.pending,
        isDirty: true,
      ),
    );

    await _audit.log(
      action: AuditAction.create,
      entityType: SupplierPayment.entityTypeName,
      tenantId: supplier.tenantId,
      employeeId: user.employeeId,
      entityId: created.id,
      newValue: created.toPayload(),
    );
    return Success(created);
  }

  Future<Result<SupplierPayment>> recordRefund({
    required AuthUser user,
    required String supplierId,
    required double amount,
    String? reference,
    String? notes,
  }) async {
    try {
      _permissions.require(user, PurchasePermissions.payment);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }

    if (amount <= 0) {
      return const Error(ValidationFailure(message: 'Refund amount must be positive', code: 'invalid_amount'));
    }

    final supplier = await _suppliers.getById(supplierId, tenantId: user.tenantId);
    if (supplier == null) {
      return const Error(ValidationFailure(message: 'Supplier not found', code: 'not_found'));
    }

    final now = DateTime.now().toUtc();
    final payment = SupplierPayment(
      id: _uuid.v4(),
      tenantId: supplier.tenantId,
      supplierId: supplierId,
      amount: amount,
      type: SupplierPaymentType.refund,
      reference: reference,
      notes: notes,
      paidAt: now,
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    );

    final created = await _payments.create(payment);
    await _suppliers.update(
      supplier.copyWith(
        currentBalance: supplier.currentBalance + amount,
        updatedAt: now,
        syncStatus: LocalSyncStatus.pending,
        isDirty: true,
      ),
    );

    await _audit.log(
      action: AuditAction.create,
      entityType: SupplierPayment.entityTypeName,
      tenantId: supplier.tenantId,
      employeeId: user.employeeId,
      entityId: created.id,
      metadata: {'type': 'refund'},
    );
    return Success(created);
  }

  Future<Result<SupplierStatement>> generateStatement({
    required AuthUser user,
    required String supplierId,
    DateTime? periodStart,
    DateTime? periodEnd,
  }) async {
    try {
      _permissions.require(user, SupplierPermissions.view);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }

    final supplier = await _suppliers.getById(supplierId, tenantId: user.tenantId);
    if (supplier == null) {
      return const Error(ValidationFailure(message: 'Supplier not found', code: 'not_found'));
    }

    final payments = await _payments.listBySupplier(supplier.tenantId, supplierId);
    final orders = await _orders.listBySupplier(supplier.tenantId, supplierId);
    final now = DateTime.now().toUtc();

    final entries = <SupplierStatementEntry>[
      ...orders.map(
        (o) => SupplierStatementEntry(
          id: o.id,
          type: SupplierTransactionType.purchase,
          amount: o.grandTotal,
          occurredAt: o.createdAt,
          reference: o.poNumber,
          description: 'Purchase order',
        ),
      ),
      ...payments.map(
        (p) => SupplierStatementEntry(
          id: p.id,
          type: p.type == SupplierPaymentType.refund ? SupplierTransactionType.refund : SupplierTransactionType.payment,
          amount: p.amount,
          occurredAt: p.paidAt ?? p.createdAt,
          reference: p.reference,
          description: p.type.value,
        ),
      ),
    ]..sort((a, b) => a.occurredAt.compareTo(b.occurredAt));

    final opening = supplier.currentBalance - entries.fold<double>(0, (sum, e) {
      return switch (e.type) {
        SupplierTransactionType.purchase => sum + e.amount,
        SupplierTransactionType.payment => sum - e.amount,
        SupplierTransactionType.refund => sum + e.amount,
        SupplierTransactionType.returnCredit => sum - e.amount,
      };
    });

    final statement = SupplierStatement(
      id: _uuid.v4(),
      tenantId: supplier.tenantId,
      supplierId: supplierId,
      periodStart: periodStart,
      periodEnd: periodEnd ?? now,
      openingBalance: opening,
      closingBalance: supplier.currentBalance,
      entries: entries,
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    );

    final created = await _statements.create(statement);
    await _audit.log(
      action: AuditAction.create,
      entityType: SupplierStatement.entityTypeName,
      tenantId: supplier.tenantId,
      employeeId: user.employeeId,
      entityId: created.id,
    );
    return Success(created);
  }

  Future<List<SupplierPayment>> transactionHistory(String tenantId, String supplierId) {
    return _payments.listBySupplier(tenantId, supplierId);
  }
}
