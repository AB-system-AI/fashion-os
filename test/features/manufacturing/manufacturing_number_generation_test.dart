import 'package:flutter_test/flutter_test.dart';

import 'package:fashion_pos_enterprise/core/business/domain/enums/business_enums.dart';

void main() {
  test('MO and WO barcode format conventions', () {
    expect('MO:${'MO-000001'}', 'MO:MO-000001');
    expect('WO:${'WO-000042'}', 'WO:WO-000042');
  });

  test('DocumentNumberType includes production and work order', () {
    expect(DocumentNumberType.productionOrder.name, 'productionOrder');
    expect(DocumentNumberType.workOrder.name, 'workOrder');
  });
}
