import 'package:fashion_pos_enterprise/core/business/domain/entities/inventory_models.dart';
import 'package:fashion_pos_enterprise/core/business/engines/inventory_rules_engine.dart';
import 'package:fashion_pos_enterprise/core/business/events/business_events.dart';
import 'package:fashion_pos_enterprise/core/business/events/domain_event_bus.dart';
import 'package:fashion_pos_enterprise/core/errors/failure.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/result/result.dart';
import 'package:fashion_pos_enterprise/features/inventory/domain/entities/stock_level.dart';
import 'package:fashion_pos_enterprise/features/inventory/domain/entities/stock_movement.dart';
import 'package:fashion_pos_enterprise/features/inventory/domain/enums/inventory_enums.dart';
import 'package:fashion_pos_enterprise/features/inventory/domain/value_objects/quantity.dart';

/// Core stock calculation and mutation rules for inventory operations.
class InventoryEngine {
  InventoryEngine({
    InventoryRulesEngine? rulesEngine,
    DomainEventBus? eventBus,
    this.allowNegativeStock = false,
  })  : _rules = rulesEngine ?? InventoryRulesEngine(),
        _eventBus = eventBus;

  final InventoryRulesEngine _rules;
  final DomainEventBus? _eventBus;
  final bool allowNegativeStock;

  Quantity availableStock(StockLevel level) => Quantity(level.available);

  Result<void> checkAvailability({
    required StockLevel level,
    required Quantity requested,
    bool allowNegativeOverride = false,
  }) {
    final available = availableStock(level);
    if (!allowNegativeStock && !allowNegativeOverride && requested > available) {
      return const Error(
        ValidationFailure(message: 'Insufficient available stock', code: 'insufficient_stock'),
      );
    }
    return const Success(null);
  }

  Result<StockLevel> increaseStock({
    required StockLevel level,
    required Quantity quantity,
    required MovementType movementType,
    MovementReason reason = MovementReason.receipt,
  }) {
    if (!quantity.isPositive) {
      return const Error(ValidationFailure(message: 'Quantity must be positive', code: 'invalid_quantity'));
    }
    final next = level.copyWith(
      onHand: level.onHand + quantity.value,
      updatedAt: DateTime.now().toUtc(),
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    );
    _publishStockChanged(level, next, movementType.value);
    return Success(next);
  }

  Result<StockLevel> decreaseStock({
    required StockLevel level,
    required Quantity quantity,
    required MovementType movementType,
    bool allowNegativeOverride = false,
  }) {
    if (!quantity.isPositive) {
      return const Error(ValidationFailure(message: 'Quantity must be positive', code: 'invalid_quantity'));
    }
    final check = checkAvailability(
      level: level,
      requested: quantity,
      allowNegativeOverride: allowNegativeOverride,
    );
    if (check.isFailure) return Error(check.failureOrNull!);

    final next = level.copyWith(
      onHand: level.onHand - quantity.value,
      updatedAt: DateTime.now().toUtc(),
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    );
    _publishStockChanged(level, next, movementType.value);
    return Success(next);
  }

  Result<StockLevel> reserveStock({
    required StockLevel level,
    required Quantity quantity,
  }) {
    final snapshot = _rules.classify(
      variantId: level.variantId ?? level.productId,
      warehouseId: level.warehouseId,
      onHand: level.onHand,
      reserved: level.reserved,
      damaged: level.damaged,
      minimumLevel: level.minimumLevel,
      maximumLevel: level.maximumLevel,
    );
    final reserved = _rules.reserveStock(snapshot, quantity.value);
    if (reserved.isFailure) return Error(reserved.failureOrNull!);
    final snap = reserved.dataOrNull!;
    return Success(
      level.copyWith(
        reserved: snap.reserved,
        updatedAt: DateTime.now().toUtc(),
        syncStatus: LocalSyncStatus.pending,
        isDirty: true,
      ),
    );
  }

  Result<StockLevel> releaseReservation({
    required StockLevel level,
    required Quantity quantity,
  }) {
    final snapshot = _rules.classify(
      variantId: level.variantId ?? level.productId,
      warehouseId: level.warehouseId,
      onHand: level.onHand,
      reserved: level.reserved,
      damaged: level.damaged,
    );
    final released = _rules.releaseReservation(snapshot, quantity.value);
    if (released.isFailure) return Error(released.failureOrNull!);
    final snap = released.dataOrNull!;
    return Success(
      level.copyWith(
        reserved: snap.reserved,
        updatedAt: DateTime.now().toUtc(),
        syncStatus: LocalSyncStatus.pending,
        isDirty: true,
      ),
    );
  }

  Result<(StockLevel source, StockLevel destination)> transferStock({
    required StockLevel source,
    required StockLevel destination,
    required Quantity quantity,
  }) {
    final decreased = decreaseStock(level: source, quantity: quantity, movementType: MovementType.transferOut);
    if (decreased.isFailure) return Error(decreased.failureOrNull!);
    final increased = increaseStock(
      level: destination,
      quantity: quantity,
      movementType: MovementType.transferIn,
      reason: MovementReason.transfer,
    );
    if (increased.isFailure) return Error(increased.failureOrNull!);
    return Success((decreased.dataOrNull!, increased.dataOrNull!));
  }

  Result<StockLevel> adjustStock({
    required StockLevel level,
    required Quantity newOnHand,
    MovementReason reason = MovementReason.correction,
  }) {
    final delta = newOnHand.value - level.onHand;
    if (delta == 0) return Success(level);
    if (delta > 0) {
      return increaseStock(
        level: level,
        quantity: Quantity(delta),
        movementType: MovementType.adjustment,
        reason: reason,
      );
    }
    return decreaseStock(
      level: level,
      quantity: Quantity(-delta),
      movementType: MovementType.adjustment,
      allowNegativeOverride: allowNegativeStock,
    );
  }

  StockMovement buildMovement({
    required String id,
    required String tenantId,
    required StockLevel levelAfter,
    required MovementType movementType,
    required double quantityDelta,
    MovementReason reason = MovementReason.receipt,
    String? referenceType,
    String? referenceId,
    String? reversalOfId,
    String? notes,
    String? employeeId,
  }) {
    final now = DateTime.now().toUtc();
    return StockMovement(
      id: id,
      tenantId: tenantId,
      warehouseId: levelAfter.warehouseId,
      productId: levelAfter.productId,
      variantId: levelAfter.variantId,
      movementType: movementType,
      reason: reason,
      quantity: quantityDelta,
      quantityAfter: levelAfter.onHand,
      referenceType: referenceType,
      referenceId: referenceId,
      reversalOfId: reversalOfId,
      notes: notes,
      employeeId: employeeId,
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    );
  }

  void _publishStockChanged(StockLevel before, StockLevel after, String movementType) {
    _eventBus?.publish(
      StockChangedEvent(
        eventId: '${after.id}_${after.updatedAt.millisecondsSinceEpoch}',
        occurredAt: after.updatedAt,
        variantId: after.variantId ?? after.productId,
        warehouseId: after.warehouseId,
        quantityBefore: before.onHand,
        quantityAfter: after.onHand,
        movementType: movementType,
      ),
    );
  }
}
