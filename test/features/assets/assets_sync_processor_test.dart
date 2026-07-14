import 'package:flutter_test/flutter_test.dart';

import 'package:fashion_pos_enterprise/features/assets/data/datasources/assets_remote_datasource.dart';
import 'package:fashion_pos_enterprise/features/assets/data/sync/assets_sync_processor.dart';
import 'package:fashion_pos_enterprise/features/assets/domain/entities/asset.dart';
import 'package:fashion_pos_enterprise/features/assets/domain/entities/depreciation.dart';
import 'package:fashion_pos_enterprise/features/assets/domain/entities/disposal.dart';
import 'package:fashion_pos_enterprise/features/assets/domain/entities/maintenance.dart';

void main() {
  test('assets sync processors map entity types to remote tables', () {
    final remote = AssetsRemoteDataSource();
    expect(
      AssetsSyncProcessor(remote: remote, entityTypeName: Asset.entityTypeName, remoteTable: 'assets').entityType,
      'asset',
    );
    expect(
      AssetsSyncProcessor(remote: remote, entityTypeName: AssetDepreciation.entityTypeName, remoteTable: 'asset_depreciation').entityType,
      'asset_depreciation',
    );
    expect(
      AssetsSyncProcessor(remote: remote, entityTypeName: MaintenanceRequest.entityTypeName, remoteTable: 'maintenance_requests').entityType,
      'maintenance_request',
    );
    expect(
      AssetsSyncProcessor(remote: remote, entityTypeName: AssetDisposal.entityTypeName, remoteTable: 'asset_disposals').entityType,
      'asset_disposal',
    );
  });
}
