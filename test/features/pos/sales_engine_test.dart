import 'package:flutter_test/flutter_test.dart';

import 'package:fashion_pos_enterprise/core/business/engines/sales/sales_engine.dart';
import 'package:fashion_pos_enterprise/features/pos/domain/entities/coupon.dart';
import 'package:fashion_pos_enterprise/features/pos/domain/entities/payment.dart';
import 'package:fashion_pos_enterprise/features/pos/domain/entities/sale.dart';
import 'package:fashion_pos_enterprise/features/pos/domain/entities/sale_line.dart';
import 'package:fashion_pos_enterprise/features/pos/domain/enums/pos_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';

void main() {
  late SalesEngine engine;

  setUp(() {
    engine = SalesEngine();
  });

  test('calculateSale totals lines correctly', () {
    final totals = engine.calculateSale([
      const SaleLine(
        id: '1',
        variantId: 'v1',
        productId: 'p1',
        productName: 'Shirt',
        sku: 'SKU1',
        quantity: 2,
        unitPrice: 50,
        taxAmount: 5,
      ),
    ]);

    expect(totals.subtotal, 100);
    expect(totals.taxTotal, 5);
    expect(totals.grandTotal, 105);
  });

  test('validateCoupon rejects expired coupon', () {
    final coupon = Coupon(
      id: 'c1',
      tenantId: 't1',
      code: 'SAVE10',
      couponType: CouponType.percentage,
      value: 10,
      endsAt: DateTime.utc(2020),
      version: 1,
      createdAt: DateTime.utc(2025),
      updatedAt: DateTime.utc(2025),
      syncStatus: LocalSyncStatus.synced,
      isDirty: false,
    );

    final result = engine.validateCoupon(coupon: coupon, orderSubtotal: 100);
    expect(result.isFailure, isTrue);
  });

  test('calculateSplitPayments balances payments', () {
    final payments = [
      Payment(
        id: 'p1',
        tenantId: 't1',
        saleOrderId: 's1',
        paymentMethodId: 'cash',
        methodKind: PaymentMethodKind.cash,
        amount: 60,
        version: 1,
        createdAt: DateTime.utc(2025),
        updatedAt: DateTime.utc(2025),
        syncStatus: LocalSyncStatus.synced,
        isDirty: false,
      ),
      Payment(
        id: 'p2',
        tenantId: 't1',
        saleOrderId: 's1',
        paymentMethodId: 'card',
        methodKind: PaymentMethodKind.visa,
        amount: 40,
        version: 1,
        createdAt: DateTime.utc(2025),
        updatedAt: DateTime.utc(2025),
        syncStatus: LocalSyncStatus.synced,
        isDirty: false,
      ),
    ];

    final result = engine.calculateSplitPayments(payments: payments, grandTotal: 100);
    expect(result.isBalanced, isTrue);
    expect(result.changeDue, 0);
  });

  test('validateRefund allows partial refund', () {
    final sale = Sale(
      id: 's1',
      tenantId: 't1',
      storeId: 'st1',
      orderNumber: 'SO-1',
      employeeId: 'e1',
      status: SaleStatus.completed,
      lines: const [],
      grandTotal: 100,
      version: 1,
      createdAt: DateTime.utc(2025),
      updatedAt: DateTime.utc(2025),
      syncStatus: LocalSyncStatus.synced,
      isDirty: false,
    );

    final validation = engine.validateRefund(originalSale: sale, refundAmount: 25, isPartial: true);
    expect(validation.isValid, isTrue);
  });

  test('calculateLayaway computes deposit and installments', () {
    final calc = engine.calculateLayaway(totalAmount: 200, depositPercent: 25, installmentCount: 3);
    expect(calc.depositAmount, 50);
    expect(calc.remainingBalance, 150);
    expect(calc.installmentAmount, 50);
  });
}
