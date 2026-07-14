enum ProductionStatus {
  draft,
  planned,
  released,
  inProgress,
  paused,
  completed,
  cancelled,
  closed;

  String get value => name;

  static ProductionStatus fromValue(String? v) =>
      ProductionStatus.values.firstWhere((e) => e.name == v, orElse: () => ProductionStatus.draft);
}

enum WorkOrderStatus {
  draft,
  assigned,
  started,
  paused,
  completed,
  rejected;

  String get value => name;

  static WorkOrderStatus fromValue(String? v) =>
      WorkOrderStatus.values.firstWhere((e) => e.name == v, orElse: () => WorkOrderStatus.draft);
}

enum OperationStatus {
  pending,
  inProgress,
  completed,
  skipped;

  String get value => name;

  static OperationStatus fromValue(String? v) =>
      OperationStatus.values.firstWhere((e) => e.name == v, orElse: () => OperationStatus.pending);
}

enum BomType {
  standard,
  phantom,
  kit,
  subcontract;

  String get value => name;

  static BomType fromValue(String? v) =>
      BomType.values.firstWhere((e) => e.name == v, orElse: () => BomType.standard);
}

enum ConsumptionMethod {
  backflush,
  manual,
  proportional;

  String get value => name;

  static ConsumptionMethod fromValue(String? v) =>
      ConsumptionMethod.values.firstWhere((e) => e.name == v, orElse: () => ConsumptionMethod.manual);
}

enum QualityResult {
  pass,
  fail,
  hold,
  rework,
  scrap;

  String get value => name;

  static QualityResult fromValue(String? v) =>
      QualityResult.values.firstWhere((e) => e.name == v, orElse: () => QualityResult.pass);
}

enum ScrapReason {
  defect,
  damage,
  overrun,
  setup,
  other;

  String get value => name;

  static ScrapReason fromValue(String? v) =>
      ScrapReason.values.firstWhere((e) => e.name == v, orElse: () => ScrapReason.other);
}

enum PlanningMethod {
  mrp,
  makeToOrder,
  makeToStock,
  assembleToOrder;

  String get value => name;

  static PlanningMethod fromValue(String? v) =>
      PlanningMethod.values.firstWhere((e) => e.name == v, orElse: () => PlanningMethod.mrp);
}

enum CapacityStatus {
  available,
  partial,
  overloaded,
  maintenance;

  String get value => name;

  static CapacityStatus fromValue(String? v) =>
      CapacityStatus.values.firstWhere((e) => e.name == v, orElse: () => CapacityStatus.available);
}
