enum AssetStatus {
  active('active'),
  idle('idle'),
  inMaintenance('in_maintenance'),
  disposed('disposed'),
  transferred('transferred');

  const AssetStatus(this.value);
  final String value;

  static AssetStatus fromValue(String? v) =>
      AssetStatus.values.firstWhere((e) => e.value == v, orElse: () => AssetStatus.active);
}

enum DepreciationMethod {
  straightLine('straight_line'),
  decliningBalance('declining_balance');

  const DepreciationMethod(this.value);
  final String value;

  static DepreciationMethod fromValue(String? v) =>
      DepreciationMethod.values.firstWhere((e) => e.value == v, orElse: () => DepreciationMethod.straightLine);
}

enum MaintenanceRequestStatus {
  open('open'),
  scheduled('scheduled'),
  inProgress('in_progress'),
  completed('completed'),
  cancelled('cancelled');

  const MaintenanceRequestStatus(this.value);
  final String value;

  static MaintenanceRequestStatus fromValue(String? v) =>
      MaintenanceRequestStatus.values.firstWhere((e) => e.value == v, orElse: () => MaintenanceRequestStatus.open);
}

enum MaintenanceScheduleType {
  preventive('preventive'),
  corrective('corrective'),
  inspection('inspection');

  const MaintenanceScheduleType(this.value);
  final String value;

  static MaintenanceScheduleType fromValue(String? v) =>
      MaintenanceScheduleType.values.firstWhere((e) => e.value == v, orElse: () => MaintenanceScheduleType.preventive);
}

enum DisposalMethod {
  sale('sale'),
  scrap('scrap'),
  donation('donation'),
  writeOff('write_off');

  const DisposalMethod(this.value);
  final String value;

  static DisposalMethod fromValue(String? v) =>
      DisposalMethod.values.firstWhere((e) => e.value == v, orElse: () => DisposalMethod.writeOff);
}

enum TransferStatus {
  pending('pending'),
  inTransit('in_transit'),
  completed('completed'),
  cancelled('cancelled');

  const TransferStatus(this.value);
  final String value;

  static TransferStatus fromValue(String? v) =>
      TransferStatus.values.firstWhere((e) => e.value == v, orElse: () => TransferStatus.pending);
}

enum WarrantyStatus {
  active('active'),
  expired('expired'),
  voided('voided');

  const WarrantyStatus(this.value);
  final String value;

  static WarrantyStatus fromValue(String? v) =>
      WarrantyStatus.values.firstWhere((e) => e.value == v, orElse: () => WarrantyStatus.active);
}

enum ContractStatus {
  active('active'),
  expired('expired'),
  cancelled('cancelled');

  const ContractStatus(this.value);
  final String value;

  static ContractStatus fromValue(String? v) =>
      ContractStatus.values.firstWhere((e) => e.value == v, orElse: () => ContractStatus.active);
}

enum AssetAuditStatus {
  planned('planned'),
  inProgress('in_progress'),
  completed('completed');

  const AssetAuditStatus(this.value);
  final String value;

  static AssetAuditStatus fromValue(String? v) =>
      AssetAuditStatus.values.firstWhere((e) => e.value == v, orElse: () => AssetAuditStatus.planned);
}
