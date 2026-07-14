import 'package:fashion_pos_enterprise/core/pos/pos_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('PosCartSnapshot serializes and deserializes', () {
    final cart = PosCartSnapshot(
      id: 'cart-1',
      tenantId: 'tenant-1',
      storeId: 'store-1',
      employeeId: 'emp-1',
      lines: const [
        PosCartLine(
          productId: 'prod-1',
          name: 'Blue Shirt',
          quantity: 2,
          unitPrice: 29.99,
          sku: 'SHIRT-BLU-M',
        ),
      ],
      updatedAt: DateTime.utc(2026, 7, 11, 12),
    );

    final restored = PosCartSnapshot.fromJson(cart.toJson());
    expect(restored.id, cart.id);
    expect(restored.lines.length, 1);
    expect(restored.subtotal, closeTo(59.98, 0.01));
    expect(restored.itemCount, 2);
  });

  test('PosRecoveryBundle detects recoverable state', () {
    const empty = PosRecoveryBundle();
    expect(empty.hasRecoverableState, false);

    final withCart = PosRecoveryBundle(
      activeCart: PosCartSnapshot(
        id: 'c1',
        tenantId: 't1',
        storeId: 's1',
        employeeId: 'e1',
        lines: const [],
        updatedAt: DateTime.utc(2026),
      ),
    );
    expect(withCart.hasRecoverableState, true);
  });
}
