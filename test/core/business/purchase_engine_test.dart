import 'package:flutter_test/flutter_test.dart';

import 'package:fashion_pos_enterprise/core/business/engines/purchasing/purchase_engine.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/features/purchasing/domain/entities/purchase_order.dart';
import 'package:fashion_pos_enterprise/features/purchasing/domain/enums/purchasing_enums.dart';

void main() {
  late PurchaseEngine engine;

  setUp(() {
    engine = PurchaseEngine();
  });

  test('calculateTotals sums lines correctly', () {
    const lines = [
      PurchaseOrderLine(id: 'l1', productId: 'p1', variantId: 'v1', quantity: 10, unitCost: 5, discount: 2, tax: 1),
      PurchaseOrderLine(id: 'l2', productId: 'p2', variantId: 'v2', quantity: 2, unitCost: 20, discount: 0, tax: 4),
    ];
    final totals = engine.calculateTotals(lines);
    expect(totals.subtotal, 90);
    expect(totals.discountTotal, 2);
    expect(totals.taxTotal, 5);
    expect(totals.grandTotal, 93);
  });

  test('validateReceiving rejects over-receive', () {
    final order = PurchaseOrder(
      id: 'po1',
      tenantId: 't1',
      supplierId: 's1',
      warehouseId: 'w1',
      poNumber: 'PO-1',
      status: PurchaseOrderStatus.sent,
      lines: const [
        PurchaseOrderLine(id: 'l1', productId: 'p1', variantId: 'v1', quantity: 10, unitCost: 5, receivedQuantity: 8),
      ],
      version: 1,
      createdAt: DateTime.utc(2025),
      updatedAt: DateTime.utc(2025),
      syncStatus: LocalSyncStatus.synced,
      isDirty: false,
    );

    final result = engine.validateReceiving(order: order, quantitiesByLineId: {'l1': 5});
    expect(result.isFailure, isTrue);
    expect(result.failureOrNull?.code, 'over_receive');
  });

  test('resolveStatusAfterReceive returns partially received', () {
    const lines = [
      PurchaseOrderLine(id: 'l1', productId: 'p1', variantId: 'v1', quantity: 10, unitCost: 5, receivedQuantity: 5),
    ];
    expect(engine.resolveStatusAfterReceive(lines), PurchaseOrderStatus.partiallyReceived);
  });

  test('validateLines rejects duplicate products', () {
    const lines = [
      PurchaseOrderLine(id: 'l1', productId: 'p1', variantId: 'v1', quantity: 1, unitCost: 1),
      PurchaseOrderLine(id: 'l2', productId: 'p1', variantId: 'v1', quantity: 2, unitCost: 1),
    ];
    expect(engine.validateLines(lines).isFailure, isTrue);
  });
}
