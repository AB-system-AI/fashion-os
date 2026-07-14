import 'package:uuid/uuid.dart';

import 'package:fashion_pos_enterprise/core/audit/audit_action.dart';
import 'package:fashion_pos_enterprise/core/audit/audit_service.dart';
import 'package:fashion_pos_enterprise/core/errors/failure.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/pagination/paginated_result.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/repository/repository_query.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_engine.dart';
import 'package:fashion_pos_enterprise/core/result/result.dart';
import 'package:fashion_pos_enterprise/features/auth/domain/entities/auth_user.dart';
import 'package:fashion_pos_enterprise/features/inventory/domain/entities/stock_adjustment.dart';
import 'package:fashion_pos_enterprise/features/inventory/domain/entities/stock_count.dart';
import 'package:fashion_pos_enterprise/features/inventory/domain/enums/inventory_enums.dart';
import 'package:fashion_pos_enterprise/features/inventory/domain/repositories/inventory_repositories.dart';
import 'package:fashion_pos_enterprise/features/inventory/domain/services/stock_movement_service.dart';

class StockCountService {
  StockCountService({
    required StockCountRepository countRepository,
    required StockLevelRepository stockLevelRepository,
    required StockAdjustmentRepository adjustmentRepository,
    required StockMovementService movementService,
    required AuditService auditService,
    required PermissionEngine permissionEngine,
    Uuid? uuid,
  })  : _counts = countRepository,
        _levels = stockLevelRepository,
        _adjustments = adjustmentRepository,
        _movements = movementService,
        _audit = auditService,
        _permissions = permissionEngine,
        _uuid = uuid ?? const Uuid();

  final StockCountRepository _counts;
  final StockLevelRepository _levels;
  final StockAdjustmentRepository _adjustments;
  final StockMovementService _movements;
  final AuditService _audit;
  final PermissionEngine _permissions;
  final Uuid _uuid;

  Future<PaginatedResult<StockCount>> list({
    required AuthUser user,
    required String tenantId,
    int page = 1,
  }) async {
    try {
      _permissions.require(user, InventoryPermissions.count);
    } on PermissionDeniedException catch (e) {
      return PaginatedResult(items: const [], page: page, pageSize: 50, totalCount: 0, hasMore: false);
    }
    return _counts.getPage(RepositoryQuery(tenantId: tenantId, page: page, pageSize: 50, sortBy: 'updated_at'));
  }

  Future<Result<StockCount>> createSession({
    required AuthUser user,
    required String warehouseId,
    String? name,
  }) async {
    try {
      _permissions.require(user, InventoryPermissions.count);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }

    final now = DateTime.now().toUtc();
    final count = StockCount(
      id: _uuid.v4(),
      tenantId: user.tenantId!,
      warehouseId: warehouseId,
      status: StockCountStatus.draft,
      name: name ?? 'Count ${now.toIso8601String()}',
      lines: const [],
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    );
    final created = await _counts.create(count);
    await _audit.log(
      action: AuditAction.create,
      entityType: StockCount.entityTypeName,
      tenantId: user.tenantId,
      employeeId: user.employeeId,
      entityId: created.id,
    );
    return Success(created);
  }

  Future<Result<StockCount>> recordLine({
    required AuthUser user,
    required StockCount count,
    required String productId,
    required double countedQuantity,
    String? variantId,
    String? barcode,
  }) async {
    try {
      _permissions.require(user, InventoryPermissions.count);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }

    final expected = await _levels.findLevel(
      tenantId: user.tenantId!,
      warehouseId: count.warehouseId,
      productId: productId,
      variantId: variantId,
    );
    final line = StockCountLine(
      productId: productId,
      variantId: variantId,
      barcode: barcode,
      expectedQuantity: expected?.onHand ?? 0,
      countedQuantity: countedQuantity,
    );

    final lines = [...count.lines.where((l) => l.productId != productId || l.variantId != variantId), line];
    final updated = await _counts.update(
      count.copyWith(
        status: StockCountStatus.inProgress,
        lines: lines,
        updatedAt: DateTime.now().toUtc(),
        syncStatus: LocalSyncStatus.pending,
        isDirty: true,
      ),
    );
    return Success(updated);
  }

  Future<Result<StockCount>> completeAndAdjust({
    required AuthUser user,
    required StockCount count,
  }) async {
    try {
      _permissions.require(user, InventoryPermissions.adjust);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }

    final adjustmentLines = count.lines
        .where((l) => l.variance != 0)
        .map(
          (l) => StockAdjustmentLine(
            productId: l.productId,
            variantId: l.variantId,
            expectedQuantity: l.expectedQuantity,
            adjustedQuantity: l.countedQuantity,
            notes: 'Count variance',
          ),
        )
        .toList();

    String? adjustmentId;
    if (adjustmentLines.isNotEmpty) {
      final now = DateTime.now().toUtc();
      final adjustment = StockAdjustment(
        id: _uuid.v4(),
        tenantId: user.tenantId!,
        warehouseId: count.warehouseId,
        status: AdjustmentStatus.posted,
        reason: MovementReason.countVariance,
        lines: adjustmentLines,
        employeeId: user.employeeId,
        postedAt: now,
        version: 1,
        createdAt: now,
        updatedAt: now,
        syncStatus: LocalSyncStatus.pending,
        isDirty: true,
      );
      final saved = await _adjustments.create(adjustment);
      adjustmentId = saved.id;

      for (final line in adjustmentLines) {
        await _movements.adjustStock(
          user: user,
          warehouseId: count.warehouseId,
          productId: line.productId,
          variantId: line.variantId,
          newOnHand: line.adjustedQuantity,
          notes: 'Stock count ${count.id}',
        );
      }
    }

    final completed = await _counts.update(
      count.copyWith(
        status: StockCountStatus.completed,
        completedAt: DateTime.now().toUtc(),
        adjustmentId: adjustmentId,
        updatedAt: DateTime.now().toUtc(),
        syncStatus: LocalSyncStatus.pending,
        isDirty: true,
      ),
    );
    await _audit.log(
      action: AuditAction.inventoryChange,
      entityType: StockCount.entityTypeName,
      tenantId: user.tenantId,
      employeeId: user.employeeId,
      entityId: completed.id,
      metadata: {'adjustment_id': adjustmentId, 'lines': count.lines.length},
    );
    return Success(completed);
  }
}
