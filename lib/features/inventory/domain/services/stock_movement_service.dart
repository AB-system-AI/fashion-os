import 'package:uuid/uuid.dart';

import 'package:fashion_pos_enterprise/core/audit/audit_action.dart';
import 'package:fashion_pos_enterprise/core/audit/audit_service.dart';
import 'package:fashion_pos_enterprise/core/business/engines/inventory/inventory_engine.dart';
import 'package:fashion_pos_enterprise/core/errors/failure.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/pagination/paginated_result.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/repository/repository_query.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_engine.dart';
import 'package:fashion_pos_enterprise/core/result/result.dart';
import 'package:fashion_pos_enterprise/features/auth/domain/entities/auth_user.dart';
import 'package:fashion_pos_enterprise/features/inventory/domain/entities/stock_level.dart';
import 'package:fashion_pos_enterprise/features/inventory/domain/entities/stock_movement.dart';
import 'package:fashion_pos_enterprise/features/inventory/domain/enums/inventory_enums.dart';
import 'package:fashion_pos_enterprise/features/inventory/domain/repositories/inventory_repositories.dart';
import 'package:fashion_pos_enterprise/features/inventory/domain/value_objects/quantity.dart';

class StockMovementService {
  StockMovementService({
    required StockLevelRepository stockLevelRepository,
    required StockMovementRepository movementRepository,
    required InventoryEngine inventoryEngine,
    required AuditService auditService,
    required PermissionEngine permissionEngine,
    Uuid? uuid,
  })  : _levels = stockLevelRepository,
        _movements = movementRepository,
        _engine = inventoryEngine,
        _audit = auditService,
        _permissions = permissionEngine,
        _uuid = uuid ?? const Uuid();

  final StockLevelRepository _levels;
  final StockMovementRepository _movements;
  final InventoryEngine _engine;
  final AuditService _audit;
  final PermissionEngine _permissions;
  final Uuid _uuid;

  Future<PaginatedResult<StockLevel>> listStock({
    required AuthUser user,
    required String tenantId,
    String? warehouseId,
    int page = 1,
  }) async {
    try {
      _permissions.require(user, InventoryPermissions.read);
    } on PermissionDeniedException catch (e) {
      return PaginatedResult(items: const [], page: page, pageSize: 50, totalCount: 0, hasMore: false);
    }
    return _levels.getPage(
      RepositoryQuery(
        tenantId: tenantId,
        storeId: warehouseId,
        page: page,
        pageSize: 100,
        sortBy: 'updated_at',
      ),
    );
  }

  Future<Result<List<StockMovement>>> ledger({
    required AuthUser user,
    required String tenantId,
    required String warehouseId,
    int limit = 100,
  }) async {
    try {
      _permissions.require(user, InventoryPermissions.read);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final items = await _movements.listByWarehouse(tenantId, warehouseId, limit: limit);
    return Success(items);
  }

  Future<Result<StockLevel>> receiveStock({
    required AuthUser user,
    required String warehouseId,
    required String productId,
    required double quantity,
    String? variantId,
    String? notes,
  }) => _applyMovement(
        user: user,
        warehouseId: warehouseId,
        productId: productId,
        variantId: variantId,
        quantity: quantity,
        movementType: MovementType.purchase,
        reason: MovementReason.receipt,
        permission: InventoryPermissions.movement,
        notes: notes,
      );

  Future<Result<StockLevel>> issueStock({
    required AuthUser user,
    required String warehouseId,
    required String productId,
    required double quantity,
    String? variantId,
    String? notes,
  }) => _applyMovement(
        user: user,
        warehouseId: warehouseId,
        productId: productId,
        variantId: variantId,
        quantity: quantity,
        movementType: MovementType.sale,
        reason: MovementReason.issue,
        permission: InventoryPermissions.movement,
        decrease: true,
        notes: notes,
      );

  Future<Result<StockLevel>> adjustStock({
    required AuthUser user,
    required String warehouseId,
    required String productId,
    required double newOnHand,
    String? variantId,
    String? notes,
  }) async {
    try {
      _permissions.require(user, InventoryPermissions.adjust);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }

    final level = await _loadOrCreateLevel(
      tenantId: user.tenantId!,
      warehouseId: warehouseId,
      productId: productId,
      variantId: variantId,
    );
    final before = level.onHand;
    final adjusted = _engine.adjustStock(level: level, newOnHand: Quantity(newOnHand));
    if (adjusted.isFailure) return Error(adjusted.failureOrNull!);

    final saved = await _levels.update(adjusted.dataOrNull!);
    final movement = _engine.buildMovement(
      id: _uuid.v4(),
      tenantId: user.tenantId!,
      levelAfter: saved,
      movementType: MovementType.adjustment,
      quantityDelta: saved.onHand - before,
      reason: MovementReason.correction,
      notes: notes,
      employeeId: user.employeeId,
    );
    await _movements.create(movement);
    await _audit.log(
      action: AuditAction.inventoryChange,
      entityType: StockMovement.entityTypeName,
      tenantId: user.tenantId,
      employeeId: user.employeeId,
      entityId: movement.id,
      metadata: {'action': 'adjust', 'warehouse_id': warehouseId, 'product_id': productId},
    );
    return Success(saved);
  }

  Future<Result<StockMovement>> reverseMovement({
    required AuthUser user,
    required StockMovement original,
    String? notes,
  }) async {
    try {
      _permissions.require(user, InventoryPermissions.adjust);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }

    final level = await _levels.findLevel(
      tenantId: user.tenantId!,
      warehouseId: original.warehouseId,
      productId: original.productId,
      variantId: original.variantId,
    );
    if (level == null) {
      return const Error(ValidationFailure(message: 'Stock level not found', code: 'not_found'));
    }

    final isIncrease = original.quantity < 0 || original.movementType == MovementType.sale;
    final qty = Quantity(original.quantity.abs());
    final next = isIncrease
        ? _engine.increaseStock(level: level, quantity: qty, movementType: MovementType.adjustment, reason: MovementReason.reversal)
        : _engine.decreaseStock(level: level, quantity: qty, movementType: MovementType.adjustment);
    if (next.isFailure) return Error(next.failureOrNull!);

    final saved = await _levels.update(next.dataOrNull!);
    final reversal = _engine.buildMovement(
      id: _uuid.v4(),
      tenantId: user.tenantId!,
      levelAfter: saved,
      movementType: MovementType.adjustment,
      quantityDelta: -original.quantity,
      reason: MovementReason.reversal,
      reversalOfId: original.id,
      notes: notes ?? 'Reversal of ${original.id}',
      employeeId: user.employeeId,
    );
    final created = await _movements.create(reversal);
    await _audit.log(
      action: AuditAction.inventoryChange,
      entityType: StockMovement.entityTypeName,
      tenantId: user.tenantId,
      employeeId: user.employeeId,
      entityId: created.id,
      metadata: {'reversal_of': original.id},
    );
    return Success(created);
  }

  Future<Result<StockLevel>> _applyMovement({
    required AuthUser user,
    required String warehouseId,
    required String productId,
    required double quantity,
    required MovementType movementType,
    required MovementReason reason,
    required String permission,
    String? variantId,
    String? notes,
    bool decrease = false,
  }) async {
    try {
      _permissions.require(user, permission);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }

    final level = await _loadOrCreateLevel(
      tenantId: user.tenantId!,
      warehouseId: warehouseId,
      productId: productId,
      variantId: variantId,
    );
    final qty = Quantity(quantity);
    final result = decrease
        ? _engine.decreaseStock(level: level, quantity: qty, movementType: movementType)
        : _engine.increaseStock(level: level, quantity: qty, movementType: movementType, reason: reason);
    if (result.isFailure) return Error(result.failureOrNull!);

    final saved = await _levels.update(result.dataOrNull!);
    final movement = _engine.buildMovement(
      id: _uuid.v4(),
      tenantId: user.tenantId!,
      levelAfter: saved,
      movementType: movementType,
      quantityDelta: decrease ? -quantity : quantity,
      reason: reason,
      notes: notes,
      employeeId: user.employeeId,
    );
    await _movements.create(movement);
    await _audit.log(
      action: AuditAction.inventoryChange,
      entityType: StockMovement.entityTypeName,
      tenantId: user.tenantId,
      employeeId: user.employeeId,
      entityId: movement.id,
      metadata: {'movement_type': movementType.value},
    );
    return Success(saved);
  }

  Future<StockLevel> _loadOrCreateLevel({
    required String tenantId,
    required String warehouseId,
    required String productId,
    String? variantId,
  }) async {
    final existing = await _levels.findLevel(
      tenantId: tenantId,
      warehouseId: warehouseId,
      productId: productId,
      variantId: variantId,
    );
    if (existing != null) return existing;

    final now = DateTime.now().toUtc();
    return _levels.create(
      StockLevel(
        id: _uuid.v4(),
        tenantId: tenantId,
        warehouseId: warehouseId,
        productId: productId,
        variantId: variantId,
        onHand: 0,
        reserved: 0,
        version: 1,
        createdAt: now,
        updatedAt: now,
        syncStatus: LocalSyncStatus.pending,
        isDirty: true,
      ),
    );
  }
}
