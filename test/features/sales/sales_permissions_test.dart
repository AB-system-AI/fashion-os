import 'package:flutter_test/flutter_test.dart';

import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';

void main() {
  test('sales OMS permission codes are stable', () {
    expect(SalesOmsPermissions.view, 'sales.view');
    expect(SalesOmsPermissions.manage, 'sales.manage');
    expect(QuotationPermissions.create, 'quotation.create');
    expect(QuotationPermissions.approve, 'quotation.approve');
    expect(SalesApprovalPermissions.approve, 'sales.approve');
    expect(ShipmentPermissions.manage, 'shipment.manage');
    expect(DeliveryPermissions.manage, 'delivery.manage');
    expect(SalesInvoicePermissions.create, 'invoice.create');
    expect(SalesReturnPermissions.manage, 'return.manage');
    expect(SalesExchangePermissions.manage, 'exchange.manage');
  });
}
