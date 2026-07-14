import 'package:fashion_pos_enterprise/core/errors/failure.dart';
import 'package:fashion_pos_enterprise/core/result/result.dart';
import 'package:fashion_pos_enterprise/features/purchasing/domain/entities/purchase_order.dart';
import 'package:fashion_pos_enterprise/features/purchasing/domain/enums/purchasing_enums.dart';

class PurchaseTotals {
  const PurchaseTotals({
    required this.subtotal,
    required this.discountTotal,
    required this.taxTotal,
    required this.grandTotal,
  });

  final double subtotal;
  final double discountTotal;
  final double taxTotal;
  final double grandTotal;
}

class PurchaseReceiveValidation {
  const PurchaseReceiveValidation({
    required this.lineId,
    required this.requested,
    required this.remaining,
    required this.isOverReceive,
    required this.isShortReceive,
  });

  final String lineId;
  final double requested;
  final double remaining;
  final bool isOverReceive;
  final bool isShortReceive;
}

/// Pure purchase calculation and validation rules.
class PurchaseEngine {
  PurchaseTotals calculateTotals(List<PurchaseOrderLine> lines) {
    var subtotal = 0.0;
    var discountTotal = 0.0;
    var taxTotal = 0.0;

    for (final line in lines) {
      subtotal += line.lineSubtotal;
      discountTotal += line.discount;
      taxTotal += line.tax;
    }

    final grandTotal = subtotal - discountTotal + taxTotal;
    return PurchaseTotals(
      subtotal: subtotal,
      discountTotal: discountTotal,
      taxTotal: taxTotal,
      grandTotal: grandTotal,
    );
  }

  Result<void> validateLines(List<PurchaseOrderLine> lines) {
    if (lines.isEmpty) {
      return const Error(ValidationFailure(message: 'Purchase order requires at least one line', code: 'no_lines'));
    }

    final seen = <String>{};
    for (final line in lines) {
      if (line.quantity <= 0) {
        return const Error(ValidationFailure(message: 'Line quantity must be positive', code: 'invalid_quantity'));
      }
      if (line.unitCost < 0) {
        return const Error(ValidationFailure(message: 'Unit cost cannot be negative', code: 'invalid_cost'));
      }
      final key = '${line.productId}:${line.variantId}';
      if (seen.contains(key)) {
        return const Error(ValidationFailure(message: 'Duplicate product lines are not allowed', code: 'duplicate_line'));
      }
      seen.add(key);
    }
    return const Success(null);
  }

  Result<void> validateOrderOpen(PurchaseOrder order) {
    if (order.status.isClosed) {
      return const Error(ValidationFailure(message: 'Purchase order is closed', code: 'order_closed'));
    }
    return const Success(null);
  }

  Result<List<PurchaseReceiveValidation>> validateReceiving({
    required PurchaseOrder order,
    required Map<String, double> quantitiesByLineId,
    bool allowOverReceive = false,
  }) {
    final openCheck = validateOrderOpen(order);
    if (openCheck.isFailure) return Error(openCheck.failureOrNull!);

    if (!order.status.canReceive) {
      return const Error(
        ValidationFailure(message: 'Purchase order is not in a receivable state', code: 'invalid_state'),
      );
    }

    final validations = <PurchaseReceiveValidation>[];
    for (final line in order.lines) {
      final requested = quantitiesByLineId[line.id] ?? 0;
      if (requested < 0) {
        return const Error(ValidationFailure(message: 'Receive quantity cannot be negative', code: 'invalid_quantity'));
      }
      if (requested == 0) continue;

      final remaining = line.remainingQuantity;
      final isOver = requested > remaining;
      if (isOver && !allowOverReceive) {
        return Error(
          ValidationFailure(
            message: 'Over-receive on line ${line.id}: requested $requested, remaining $remaining',
            code: 'over_receive',
          ),
        );
      }

      validations.add(
        PurchaseReceiveValidation(
          lineId: line.id,
          requested: requested,
          remaining: remaining,
          isOverReceive: isOver,
          isShortReceive: requested < remaining,
        ),
      );
    }

    if (validations.isEmpty) {
      return const Error(ValidationFailure(message: 'No quantities to receive', code: 'empty_receive'));
    }

    return Success(validations);
  }

  List<PurchaseOrderLine> applyReceivedQuantities({
    required List<PurchaseOrderLine> lines,
    required Map<String, double> quantitiesByLineId,
  }) {
    return lines
        .map(
          (line) => line.copyWith(
            receivedQuantity: line.receivedQuantity + (quantitiesByLineId[line.id] ?? 0),
          ),
        )
        .toList();
  }

  PurchaseOrderStatus resolveStatusAfterReceive(List<PurchaseOrderLine> lines) {
    final allReceived = lines.every((l) => l.receivedQuantity >= l.quantity);
    final anyReceived = lines.any((l) => l.receivedQuantity > 0);
    if (allReceived) return PurchaseOrderStatus.received;
    if (anyReceived) return PurchaseOrderStatus.partiallyReceived;
    return PurchaseOrderStatus.sent;
  }

  double outstandingAmount(PurchaseOrder order) {
    if (order.status == PurchaseOrderStatus.cancelled) return 0;
    final receivedRatio = order.lines.isEmpty
        ? 0.0
        : order.lines.fold<double>(0, (sum, l) => sum + l.receivedQuantity) /
            order.lines.fold<double>(0, (sum, l) => sum + l.quantity);
    return order.grandTotal * (1 - receivedRatio.clamp(0, 1));
  }
}
