import 'package:flutter_test/flutter_test.dart';

import 'package:fashion_pos_enterprise/features/sales/data/datasources/sales_remote_datasource.dart';
import 'package:fashion_pos_enterprise/features/sales/data/sync/sales_sync_processor.dart';
import 'package:fashion_pos_enterprise/features/sales/domain/entities/order.dart';
import 'package:fashion_pos_enterprise/features/sales/domain/entities/quotation.dart';
import 'package:fashion_pos_enterprise/features/sales/domain/entities/shipment.dart';

void main() {
  test('sales sync processors map entity types to remote tables', () {
    final remote = SalesRemoteDataSource();
    expect(SalesSyncProcessor(remote: remote, entityTypeName: Quotation.entityTypeName, remoteTable: 'quotations').entityType, 'quotation');
    expect(SalesSyncProcessor(remote: remote, entityTypeName: SalesOrder.entityTypeName, remoteTable: 'sales_orders').entityType, 'sales_order');
    expect(SalesSyncProcessor(remote: remote, entityTypeName: Shipment.entityTypeName, remoteTable: 'shipments').entityType, 'shipment');
  });
}
