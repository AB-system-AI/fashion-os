import 'package:flutter_test/flutter_test.dart';

import 'package:fashion_pos_enterprise/features/treasury/data/datasources/treasury_remote_datasource.dart';
import 'package:fashion_pos_enterprise/features/treasury/data/sync/treasury_sync_processor.dart';
import 'package:fashion_pos_enterprise/features/treasury/domain/entities/accounts.dart';
import 'package:fashion_pos_enterprise/features/treasury/domain/entities/cheques.dart';
import 'package:fashion_pos_enterprise/features/treasury/domain/entities/movements.dart';
import 'package:fashion_pos_enterprise/features/treasury/domain/entities/vouchers.dart';

void main() {
  test('treasury sync processors map entity types to remote tables', () {
    final remote = TreasuryRemoteDataSource();
    expect(TreasurySyncProcessor(remote: remote, entityTypeName: CashBox.entityTypeName, remoteTable: 'cash_boxes').entityType, 'cash_box');
    expect(TreasurySyncProcessor(remote: remote, entityTypeName: Bank.entityTypeName, remoteTable: 'banks').entityType, 'bank');
    expect(TreasurySyncProcessor(remote: remote, entityTypeName: Transfer.entityTypeName, remoteTable: 'treasury_transfers').entityType, 'transfer');
    expect(TreasurySyncProcessor(remote: remote, entityTypeName: PaymentVoucher.entityTypeName, remoteTable: 'payment_vouchers').entityType, 'payment_voucher');
    expect(TreasurySyncProcessor(remote: remote, entityTypeName: Cheque.entityTypeName, remoteTable: 'cheques').entityType, 'cheque');
  });
}
