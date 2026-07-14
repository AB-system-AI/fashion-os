import 'package:fashion_pos_enterprise/features/assets/domain/enums/assets_enums.dart';

class AssetInput {
  const AssetInput({
    required this.name,
    required this.categoryId,
    required this.locationId,
    required this.acquisitionCost,
    this.assetTag,
    this.serialNumber,
    this.description,
    this.acquisitionDate,
    this.usefulLifeMonths = 60,
    this.salvageValue = 0,
    this.depreciationMethod = DepreciationMethod.straightLine,
  });

  final String name;
  final String? assetTag;
  final String? serialNumber;
  final String? description;
  final String categoryId;
  final String locationId;
  final double acquisitionCost;
  final DateTime? acquisitionDate;
  final int usefulLifeMonths;
  final double salvageValue;
  final DepreciationMethod depreciationMethod;
}

class TransferInput {
  const TransferInput({
    required this.assetId,
    required this.toLocationId,
    this.fromLocationId,
    this.notes,
  });

  final String assetId;
  final String? fromLocationId;
  final String toLocationId;
  final String? notes;
}

class DisposalInput {
  const DisposalInput({
    required this.assetId,
    required this.method,
    this.proceeds = 0,
    this.notes,
  });

  final String assetId;
  final DisposalMethod method;
  final double proceeds;
  final String? notes;
}

class MaintenanceRequestInput {
  const MaintenanceRequestInput({
    required this.assetId,
    required this.title,
    this.description,
    this.priority = 1,
    this.scheduleType = MaintenanceScheduleType.corrective,
  });

  final String assetId;
  final String title;
  final String? description;
  final int priority;
  final MaintenanceScheduleType scheduleType;
}

class UtilizationKpis {
  const UtilizationKpis({
    required this.totalAssets,
    required this.activeAssets,
    required this.inMaintenance,
    required this.utilizationRate,
    required this.averageAgeMonths,
    required this.totalBookValue,
  });

  final int totalAssets;
  final int activeAssets;
  final int inMaintenance;
  final double utilizationRate;
  final double averageAgeMonths;
  final double totalBookValue;
}

class DepreciationScheduleEntry {
  const DepreciationScheduleEntry({
    required this.period,
    required this.depreciationAmount,
    required this.accumulatedDepreciation,
    required this.bookValue,
  });

  final int period;
  final double depreciationAmount;
  final double accumulatedDepreciation;
  final double bookValue;
}
