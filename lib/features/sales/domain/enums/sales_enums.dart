enum QuotationStatus {
  draft,
  sent,
  accepted,
  rejected,
  expired;

  String get value => name;

  static QuotationStatus fromValue(String? v) =>
      QuotationStatus.values.firstWhere((e) => e.name == v, orElse: () => QuotationStatus.draft);
}

enum SalesOrderStatus {
  draft,
  confirmed,
  approved,
  reserved,
  picking,
  packed,
  shipped,
  delivered,
  completed,
  cancelled;

  String get value => name;

  static SalesOrderStatus fromValue(String? v) =>
      SalesOrderStatus.values.firstWhere((e) => e.name == v, orElse: () => SalesOrderStatus.draft);
}

enum ShipmentStatus {
  pending,
  picking,
  packed,
  dispatched,
  delivered,
  failed,
  returned;

  String get value => name;

  static ShipmentStatus fromValue(String? v) =>
      ShipmentStatus.values.firstWhere((e) => e.name == v, orElse: () => ShipmentStatus.pending);
}

enum DeliveryStatus {
  pending,
  inTransit,
  delivered,
  failed;

  String get value => name;

  static DeliveryStatus fromValue(String? v) =>
      DeliveryStatus.values.firstWhere((e) => e.name == v, orElse: () => DeliveryStatus.pending);
}

enum BackOrderStatus {
  open,
  partiallyFulfilled,
  fulfilled,
  cancelled;

  String get value => name;

  static BackOrderStatus fromValue(String? v) =>
      BackOrderStatus.values.firstWhere((e) => e.name == v, orElse: () => BackOrderStatus.open);
}

enum ReturnRequestStatus {
  draft,
  submitted,
  approved,
  received,
  refunded,
  rejected;

  String get value => name;

  static ReturnRequestStatus fromValue(String? v) =>
      ReturnRequestStatus.values.firstWhere((e) => e.name == v, orElse: () => ReturnRequestStatus.draft);
}

enum ExchangeRequestStatus {
  draft,
  submitted,
  approved,
  completed,
  rejected;

  String get value => name;

  static ExchangeRequestStatus fromValue(String? v) =>
      ExchangeRequestStatus.values.firstWhere((e) => e.name == v, orElse: () => ExchangeRequestStatus.draft);
}

enum TimelineEventType {
  quotationCreated,
  quotationSent,
  quotationAccepted,
  orderCreated,
  orderConfirmed,
  orderApproved,
  stockReserved,
  shipmentCreated,
  shipmentDispatched,
  delivered,
  returnRequested,
  exchangeRequested,
  note;

  String get value => name;

  static TimelineEventType fromValue(String? v) =>
      TimelineEventType.values.firstWhere((e) => e.name == v, orElse: () => TimelineEventType.note);
}

enum PlanningMethod {
  makeToStock,
  makeToOrder;

  String get value => name;

  static PlanningMethod fromValue(String? v) =>
      PlanningMethod.values.firstWhere((e) => e.name == v, orElse: () => PlanningMethod.makeToStock);
}
