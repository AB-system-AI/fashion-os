import 'package:flutter_test/flutter_test.dart';

import 'package:fashion_pos_enterprise/features/pos/data/datasources/pos_remote_datasource.dart';
import 'package:fashion_pos_enterprise/features/pos/data/sync/pos_sync_processor.dart';

void main() {
  test('sync processors map entity types to remote tables', () {
    final remote = PosRemoteDataSource();
    final sales = PosSyncProcessor(remote: remote, entityTypeName: 'sale_order', remoteTable: 'sale_orders');
    final cash = PosSyncProcessor(remote: remote, entityTypeName: 'cash_session', remoteTable: 'cash_sessions');
    final receipt = PosSyncProcessor(remote: remote, entityTypeName: 'receipt', remoteTable: 'receipt_history');

    expect(sales.entityType, 'sale_order');
    expect(cash.entityType, 'cash_session');
    expect(receipt.entityType, 'receipt');
  });
}
