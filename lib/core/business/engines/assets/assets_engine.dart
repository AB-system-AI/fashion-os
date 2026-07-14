import 'package:fashion_pos_enterprise/core/business/events/business_events.dart';
import 'package:fashion_pos_enterprise/core/business/events/domain_event_bus.dart';
import 'package:uuid/uuid.dart';
import 'package:fashion_pos_enterprise/core/errors/failure.dart';
import 'package:fashion_pos_enterprise/core/result/result.dart';
import 'package:fashion_pos_enterprise/features/assets/domain/entities/asset.dart';
import 'package:fashion_pos_enterprise/features/assets/domain/entities/contracts.dart';
import 'package:fashion_pos_enterprise/features/assets/domain/entities/depreciation.dart';
import 'package:fashion_pos_enterprise/features/assets/domain/entities/disposal.dart';
import 'package:fashion_pos_enterprise/features/assets/domain/entities/maintenance.dart';
import 'package:fashion_pos_enterprise/features/assets/domain/entities/transfer.dart';
import 'package:fashion_pos_enterprise/features/assets/domain/enums/assets_enums.dart';
import 'package:fashion_pos_enterprise/features/assets/domain/value_objects/assets_value_objects.dart';

class LifecycleTransitionResult {
  const LifecycleTransitionResult({required this.allowed, this.reason});

  final bool allowed;
  final String? reason;
}

class DisposalCalculation {
  const DisposalCalculation({
    required this.bookValue,
    required this.proceeds,
    required this.gainLoss,
  });

  final double bookValue;
  final double proceeds;
  final double gainLoss;
}

class MaintenanceCostSummary {
  const MaintenanceCostSummary({
    required this.laborCost,
    required this.partsCost,
    required this.otherCost,
    required this.totalCost,
  });

  final double laborCost;
  final double partsCost;
  final double otherCost;
  final double totalCost;
}

/// Pure asset lifecycle, depreciation, transfer, disposal, maintenance, warranty, and utilization logic.
class AssetsEngine {
  AssetsEngine({DomainEventBus? eventBus, Uuid? uuid})
      : _eventBus = eventBus,
        _uuid = uuid ?? const Uuid();

  final DomainEventBus? _eventBus;
  final Uuid _uuid;

  Result<void> validateLifecycleTransition(AssetStatus from, AssetStatus to) {
    const allowed = {
      AssetStatus.active: {AssetStatus.idle, AssetStatus.inMaintenance, AssetStatus.transferred, AssetStatus.disposed},
      AssetStatus.idle: {AssetStatus.active, AssetStatus.inMaintenance, AssetStatus.transferred, AssetStatus.disposed},
      AssetStatus.inMaintenance: {AssetStatus.active, AssetStatus.idle, AssetStatus.disposed},
      AssetStatus.transferred: {AssetStatus.active, AssetStatus.idle},
      AssetStatus.disposed: <AssetStatus>{},
    };
    if (!(allowed[from]?.contains(to) ?? false)) {
      return Error(ValidationFailure(
        message: 'Cannot transition asset from ${from.value} to ${to.value}',
        code: 'invalid_lifecycle_transition',
      ));
    }
    return const Success(null);
  }

  List<DepreciationScheduleEntry> buildDepreciationSchedule({
    required double acquisitionCost,
    required double salvageValue,
    required int usefulLifeMonths,
    DepreciationMethod method = DepreciationMethod.straightLine,
    int periods = 12,
  }) {
    if (usefulLifeMonths <= 0) return const [];
    final depreciableBase = acquisitionCost - salvageValue;
    if (depreciableBase <= 0) return const [];

    final entries = <DepreciationScheduleEntry>[];
    var accumulated = 0.0;
    var bookValue = acquisitionCost;

    for (var period = 1; period <= periods && period <= usefulLifeMonths; period++) {
      final amount = switch (method) {
        DepreciationMethod.straightLine => depreciableBase / usefulLifeMonths,
        DepreciationMethod.decliningBalance => bookValue * (2 / usefulLifeMonths),
      };
      final capped = (accumulated + amount > depreciableBase) ? depreciableBase - accumulated : amount;
      accumulated += capped;
      bookValue = acquisitionCost - accumulated;
      entries.add(DepreciationScheduleEntry(
        period: period,
        depreciationAmount: capped,
        accumulatedDepreciation: accumulated,
        bookValue: bookValue < salvageValue ? salvageValue : bookValue,
      ));
    }
    return entries;
  }

  AssetDepreciation calculateNextDepreciation({
    required Asset asset,
    required int period,
    AssetDepreciation? previous,
  }) {
    final schedule = buildDepreciationSchedule(
      acquisitionCost: asset.acquisitionCost,
      salvageValue: asset.salvageValue,
      usefulLifeMonths: asset.usefulLifeMonths,
      method: asset.depreciationMethod,
      periods: period,
    );
    final entry = schedule.isNotEmpty ? schedule.last : null;
    final amount = entry?.depreciationAmount ?? 0;
    final accumulated = entry?.accumulatedDepreciation ?? asset.accumulatedDepreciation;
    final bookValue = entry?.bookValue ?? asset.bookValue;

    return AssetDepreciation(
      id: '',
      tenantId: asset.tenantId,
      assetId: asset.id,
      period: period,
      depreciationAmount: amount,
      accumulatedDepreciation: accumulated,
      bookValue: bookValue,
      version: 1,
      createdAt: DateTime.now().toUtc(),
      updatedAt: DateTime.now().toUtc(),
      syncStatus: previous?.syncStatus ?? asset.syncStatus,
      isDirty: true,
    );
  }

  Result<AssetTransfer> planTransfer({
    required Asset asset,
    required String toLocationId,
    String? notes,
  }) {
    if (asset.status == AssetStatus.disposed) {
      return const Error(ValidationFailure(message: 'Cannot transfer disposed asset', code: 'asset_disposed'));
    }
    if (asset.locationId == toLocationId) {
      return const Error(ValidationFailure(message: 'Asset already at target location', code: 'same_location'));
    }
  final now = DateTime.now().toUtc();
    return Success(AssetTransfer(
      id: '',
      tenantId: asset.tenantId,
      assetId: asset.id,
      fromLocationId: asset.locationId,
      toLocationId: toLocationId,
      status: TransferStatus.pending,
      notes: notes,
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: asset.syncStatus,
      isDirty: true,
    ));
  }

  Result<TransferStatus> completeTransfer(AssetTransfer transfer) {
    if (transfer.status != TransferStatus.pending && transfer.status != TransferStatus.inTransit) {
      return Error(ValidationFailure(message: 'Transfer is ${transfer.status.value}', code: 'invalid_transfer_status'));
    }
    return const Success(TransferStatus.completed);
  }

  DisposalCalculation calculateDisposal({
    required Asset asset,
    required double proceeds,
  }) {
    final bookValue = asset.bookValue;
    final gainLoss = proceeds - bookValue;
    return DisposalCalculation(bookValue: bookValue, proceeds: proceeds, gainLoss: gainLoss);
  }

  Result<void> validateDisposal(Asset asset) {
    if (asset.status == AssetStatus.disposed) {
      return const Error(ValidationFailure(message: 'Asset already disposed', code: 'already_disposed'));
    }
  if (asset.status == AssetStatus.inMaintenance) {
      return const Error(ValidationFailure(message: 'Complete maintenance before disposal', code: 'in_maintenance'));
    }
    return const Success(null);
  }

  DateTime? scheduleNextMaintenance({
    required MaintenanceSchedule schedule,
    DateTime? completedAt,
  }) {
    final base = completedAt ?? DateTime.now().toUtc();
    return base.add(Duration(days: schedule.intervalDays));
  }

  MaintenanceCostSummary summarizeMaintenanceCosts(List<MaintenanceCost> costs) {
    var labor = 0.0;
    var parts = 0.0;
    var other = 0.0;
    for (final c in costs) {
      switch (c.costType) {
        case 'labor':
          labor += c.amount;
        case 'parts':
          parts += c.amount;
        default:
          other += c.amount;
      }
    }
    return MaintenanceCostSummary(
      laborCost: labor,
      partsCost: parts,
      otherCost: other,
      totalCost: labor + parts + other,
    );
  }

  bool isWarrantyValid(Warranty warranty, {DateTime? asOf}) {
    final now = asOf ?? DateTime.now().toUtc();
    if (warranty.status != WarrantyStatus.active) return false;
    if (warranty.endDate != null && warranty.endDate!.isBefore(now)) return false;
    return true;
  }

  UtilizationKpis calculateUtilizationKpis({
    required List<Asset> assets,
    DateTime? asOf,
  }) {
    final now = asOf ?? DateTime.now().toUtc();
    final active = assets.where((a) => a.status == AssetStatus.active && a.deletedAt == null).length;
    final inMaint = assets.where((a) => a.status == AssetStatus.inMaintenance).length;
    final total = assets.where((a) => a.deletedAt == null && a.status != AssetStatus.disposed).length;
    final bookTotal = assets.fold(0.0, (s, a) => s + (a.deletedAt == null ? a.bookValue : 0));

    var ageSum = 0.0;
    var ageCount = 0;
    for (final a in assets) {
      if (a.acquisitionDate != null && a.deletedAt == null) {
        ageSum += now.difference(a.acquisitionDate!).inDays / 30.0;
        ageCount++;
      }
    }

    return UtilizationKpis(
      totalAssets: total,
      activeAssets: active,
      inMaintenance: inMaint,
      utilizationRate: total == 0 ? 0 : active / total,
      averageAgeMonths: ageCount == 0 ? 0 : ageSum / ageCount,
      totalBookValue: bookTotal,
    );
  }

  void publishAssetDisposed({
    required String tenantId,
    required String assetId,
    required double gainLoss,
    required double proceeds,
  }) {
    _eventBus?.publish(AssetDisposedEvent(
      eventId: _uuid.v4(),
      occurredAt: DateTime.now().toUtc(),
      tenantId: tenantId,
      assetId: assetId,
      gainLoss: gainLoss,
      proceeds: proceeds,
    ));
  }

  void publishAssetTransferred({
    required String tenantId,
    required String assetId,
    required String fromLocationId,
    required String toLocationId,
  }) {
    _eventBus?.publish(AssetTransferredEvent(
      eventId: _uuid.v4(),
      occurredAt: DateTime.now().toUtc(),
      tenantId: tenantId,
      assetId: assetId,
      fromLocationId: fromLocationId,
      toLocationId: toLocationId,
    ));
  }
}
