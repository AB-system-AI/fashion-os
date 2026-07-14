import 'package:uuid/uuid.dart';

import 'package:fashion_pos_enterprise/core/audit/audit_action.dart';
import 'package:fashion_pos_enterprise/core/audit/audit_service.dart';
import 'package:fashion_pos_enterprise/core/business/domain/enums/business_enums.dart';
import 'package:fashion_pos_enterprise/core/business/engines/number_generator_engine.dart';
import 'package:fashion_pos_enterprise/core/errors/failure.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/pagination/paginated_result.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/repository/repository_query.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_engine.dart';
import 'package:fashion_pos_enterprise/core/result/result.dart';
import 'package:fashion_pos_enterprise/features/auth/domain/entities/auth_user.dart';
import 'package:fashion_pos_enterprise/features/purchasing/domain/entities/supplier.dart';
import 'package:fashion_pos_enterprise/features/purchasing/domain/repositories/purchasing_repositories.dart';

class SupplierStatistics {
  const SupplierStatistics({
    required this.totalOrders,
    required this.outstandingBalance,
    required this.creditLimit,
    required this.creditAvailable,
  });

  final int totalOrders;
  final double outstandingBalance;
  final double creditLimit;
  final double creditAvailable;
}

class SupplierService {
  SupplierService({
    required SupplierRepository repository,
    required PurchaseOrderRepository purchaseOrderRepository,
    required AuditService auditService,
    required PermissionEngine permissionEngine,
    required NumberGeneratorEngine numberGenerator,
    Uuid? uuid,
  })  : _repository = repository,
        _orders = purchaseOrderRepository,
        _audit = auditService,
        _permissions = permissionEngine,
        _numbers = numberGenerator,
        _uuid = uuid ?? const Uuid();

  final SupplierRepository _repository;
  final PurchaseOrderRepository _orders;
  final AuditService _audit;
  final PermissionEngine _permissions;
  final NumberGeneratorEngine _numbers;
  final Uuid _uuid;

  Future<PaginatedResult<Supplier>> list({
    required String tenantId,
    String? search,
    bool? activeOnly,
    int page = 1,
    int pageSize = 100,
  }) async {
    final result = await _repository.getPage(
      RepositoryQuery(tenantId: tenantId, search: search, page: page, pageSize: pageSize, sortBy: 'name'),
    );
    if (activeOnly == true) {
      return PaginatedResult(
        items: result.items.where((s) => s.active).toList(),
        page: result.page,
        pageSize: result.pageSize,
        totalCount: result.totalCount,
        hasMore: result.hasMore,
      );
    }
    return result;
  }

  Future<Result<Supplier>> getById(String id, {AuthUser? user}) async {
    if (user != null) {
      try {
        _permissions.require(user, SupplierPermissions.view);
      } on PermissionDeniedException catch (e) {
        return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
      }
    }
    final supplier = await _repository.getById(id, tenantId: user?.tenantId);
    if (supplier == null) {
      return const Error(ValidationFailure(message: 'Supplier not found', code: 'not_found'));
    }
    return Success(supplier);
  }

  Future<Result<Supplier>> create({required AuthUser user, required Supplier draft}) async {
    try {
      _permissions.require(user, SupplierPermissions.create);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }

    final tenantId = user.tenantId ?? draft.tenantId;
    final codeResult = draft.supplierCode.isNotEmpty
        ? Success(draft.supplierCode)
        : (await _numbers.next(type: DocumentNumberType.supplier, tenantId: tenantId)).map((n) => n.value);

    if (codeResult.isFailure) return Error(codeResult.failureOrNull!);
    final code = codeResult.dataOrNull!;

    final existing = await _repository.findByCode(tenantId, code);
    if (existing != null) {
      return const Error(ValidationFailure(message: 'Supplier code already exists', code: 'duplicate_code'));
    }

    final now = DateTime.now().toUtc();
    final supplier = Supplier(
      id: draft.id.isEmpty ? _uuid.v4() : draft.id,
      tenantId: tenantId,
      supplierCode: code,
      companyName: draft.companyName.trim(),
      contactName: draft.contactName,
      phone: draft.phone,
      mobile: draft.mobile,
      email: draft.email,
      address: draft.address,
      city: draft.city,
      country: draft.country,
      taxNumber: draft.taxNumber,
      commercialRegistration: draft.commercialRegistration,
      paymentTerms: draft.paymentTerms,
      creditLimit: draft.creditLimit,
      currentBalance: draft.currentBalance,
      notes: draft.notes,
      active: draft.active,
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    );

    final created = await _repository.create(supplier);
    await _audit.log(
      action: AuditAction.create,
      entityType: Supplier.entityTypeName,
      tenantId: created.tenantId,
      employeeId: user.employeeId,
      entityId: created.id,
      newValue: created.toPayload(),
    );
    return Success(created);
  }

  Future<Result<Supplier>> update({
    required AuthUser user,
    required Supplier supplier,
    Supplier? previous,
  }) async {
    try {
      _permissions.require(user, SupplierPermissions.update);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }

    final updated = await _repository.update(
      supplier.copyWith(
        updatedAt: DateTime.now().toUtc(),
        syncStatus: LocalSyncStatus.pending,
        isDirty: true,
      ),
    );
    await _audit.log(
      action: AuditAction.update,
      entityType: Supplier.entityTypeName,
      tenantId: updated.tenantId,
      employeeId: user.employeeId,
      entityId: updated.id,
      oldValue: previous?.toPayload(),
      newValue: updated.toPayload(),
    );
    return Success(updated);
  }

  Future<Result<Supplier>> archive({required AuthUser user, required Supplier supplier}) {
    return update(user: user, supplier: supplier.copyWith(active: false), previous: supplier);
  }

  Future<Result<void>> delete({required AuthUser user, required String supplierId}) async {
    try {
      _permissions.require(user, SupplierPermissions.delete);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    await _repository.softDelete(supplierId, tenantId: user.tenantId);
    await _audit.log(
      action: AuditAction.delete,
      entityType: Supplier.entityTypeName,
      tenantId: user.tenantId,
      employeeId: user.employeeId,
      entityId: supplierId,
    );
    return const Success(null);
  }

  Future<SupplierStatistics> statistics({required String tenantId, required String supplierId}) async {
    final supplier = await _repository.getById(supplierId, tenantId: tenantId);
    final orders = await _orders.listBySupplier(tenantId, supplierId);
    final outstanding = supplier?.currentBalance ?? 0;
    final creditLimit = supplier?.creditLimit ?? 0;
    return SupplierStatistics(
      totalOrders: orders.length,
      outstandingBalance: outstanding,
      creditLimit: creditLimit,
      creditAvailable: (creditLimit - outstanding).clamp(0, double.infinity),
    );
  }
}
