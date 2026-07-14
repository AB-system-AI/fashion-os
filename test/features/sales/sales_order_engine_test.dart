import 'package:flutter_test/flutter_test.dart';

import 'package:fashion_pos_enterprise/core/business/engines/sales_order/sales_order_engine.dart';
import 'package:fashion_pos_enterprise/features/sales/domain/enums/sales_enums.dart';
import 'package:fashion_pos_enterprise/features/sales/domain/value_objects/sales_value_objects.dart';

void main() {
  late SalesOrderEngine engine;

  setUp(() => engine = SalesOrderEngine());

  test('calculateQuotation totals lines with tax and discount', () {
    final totals = engine.calculateQuotation([
      const QuotationLineInput(productId: 'p1', quantity: 2, unitPrice: 100, taxRate: 10),
    ]);
    expect(totals.subtotal, 200);
    expect(totals.grandTotal, greaterThan(200));
  });

  test('validateOrder rejects empty lines', () {
    final result = engine.validateOrder(lines: const [], customerId: 'c1', creditLimit: 0, outstandingCredit: 0, orderTotal: 0);
    expect(result.isValid, isFalse);
  });

  test('canTransitionOrder allows draft to confirmed', () {
    expect(engine.canTransitionOrder(SalesOrderStatus.draft, SalesOrderStatus.confirmed).allowed, isTrue);
  });

  test('planReservations creates backorder shortfall', () {
    final plans = engine.planReservations(
      lines: [const OrderLineInput(productId: 'p1', quantity: 10, unitPrice: 5)],
      defaultWarehouseId: 'w1',
      availableByProduct: {'p1': 3},
    );
    expect(plans.first.shortfall, 7);
    expect(plans.first.quantity, 3);
  });

  test('validateReturn enforces max returnable', () {
    final v = engine.validateReturn(originalQty: 10, returnQty: 11, alreadyReturned: 0);
    expect(v.isValid, isFalse);
  });

  test('conversionRate calculates percent', () {
    expect(engine.conversionRate(quotationsSent: 10, ordersCreated: 3), 30);
  });
}
