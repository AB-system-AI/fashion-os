import 'package:flutter_test/flutter_test.dart';

import 'package:fashion_pos_enterprise/core/business/engines/assets/assets_engine.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/features/assets/domain/entities/asset.dart';
import 'package:fashion_pos_enterprise/features/assets/domain/entities/contracts.dart';
import 'package:fashion_pos_enterprise/features/assets/domain/enums/assets_enums.dart';

Asset _asset({double cost = 10000, int life = 60, double salvage = 1000}) {
  final now = DateTime.utc(2025, 1, 1);
  return Asset(
    id: 'asset-1',
    tenantId: 'tenant-1',
    name: 'Sewing Machine',
    categoryId: 'cat-1',
    locationId: 'loc-1',
    acquisitionCost: cost,
    bookValue: cost,
    usefulLifeMonths: life,
    salvageValue: salvage,
    version: 1,
    createdAt: now,
    updatedAt: now,
    syncStatus: LocalSyncStatus.synced,
    isDirty: false,
  );
}

void main() {
  late AssetsEngine engine;

  setUp(() => engine = AssetsEngine());

  test('buildDepreciationSchedule straight-line reduces book value', () {
    final schedule = engine.buildDepreciationSchedule(
      acquisitionCost: 10000,
      salvageValue: 1000,
      usefulLifeMonths: 60,
      periods: 3,
    );
    expect(schedule, hasLength(3));
    expect(schedule.first.depreciationAmount, closeTo(150, 0.01));
    expect(schedule.last.bookValue, lessThan(10000));
  });

  test('validateDisposal rejects disposed asset', () {
    final disposed = _asset().copyWith(status: AssetStatus.disposed);
    final result = engine.validateDisposal(disposed);
    expect(result.isFailure, isTrue);
  });

  test('calculateUtilizationKpis computes active ratio', () {
    final now = DateTime.utc(2025, 1, 1);
    final kpis = engine.calculateUtilizationKpis(assets: [
      _asset(),
      Asset(
        id: 'a2',
        tenantId: 'tenant-1',
        name: 'Press',
        categoryId: 'cat-1',
        locationId: 'loc-1',
        status: AssetStatus.inMaintenance,
        acquisitionCost: 5000,
        bookValue: 4000,
        version: 1,
        createdAt: now,
        updatedAt: now,
        syncStatus: LocalSyncStatus.synced,
        isDirty: false,
      ),
      Asset(
        id: 'a3',
        tenantId: 'tenant-1',
        name: 'Retired',
        categoryId: 'cat-1',
        locationId: 'loc-1',
        status: AssetStatus.disposed,
        acquisitionCost: 2000,
        bookValue: 0,
        version: 1,
        createdAt: now,
        updatedAt: now,
        syncStatus: LocalSyncStatus.synced,
        isDirty: false,
      ),
    ]);
    expect(kpis.totalAssets, 2);
    expect(kpis.activeAssets, 1);
    expect(kpis.utilizationRate, closeTo(0.5, 0.01));
  });

  test('isWarrantyValid returns false for expired warranty', () {
    final warranty = Warranty(
      id: 'w1',
      tenantId: 't1',
      assetId: 'a1',
      provider: 'Vendor',
      status: WarrantyStatus.active,
      endDate: DateTime.utc(2020, 1, 1),
      version: 1,
      createdAt: DateTime.utc(2025, 1, 1),
      updatedAt: DateTime.utc(2025, 1, 1),
      syncStatus: LocalSyncStatus.synced,
      isDirty: false,
    );
    expect(engine.isWarrantyValid(warranty, asOf: DateTime.utc(2025, 6, 1)), isFalse);
  });
}
