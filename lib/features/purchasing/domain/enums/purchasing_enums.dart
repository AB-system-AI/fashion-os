/// Purchase order lifecycle statuses.
enum PurchaseOrderStatus {
  draft('DRAFT'),
  pendingApproval('PENDING_APPROVAL'),
  approved('APPROVED'),
  sent('SENT'),
  partiallyReceived('PARTIALLY_RECEIVED'),
  received('RECEIVED'),
  closed('CLOSED'),
  cancelled('CANCELLED');

  const PurchaseOrderStatus(this.value);
  final String value;

  static PurchaseOrderStatus fromValue(String? raw) {
    return PurchaseOrderStatus.values.firstWhere(
      (e) => e.value == raw || e.name == raw,
      orElse: () => PurchaseOrderStatus.draft,
    );
  }

  bool get isEditable => this == PurchaseOrderStatus.draft;
  bool get canReceive =>
      this == PurchaseOrderStatus.sent ||
      this == PurchaseOrderStatus.partiallyReceived ||
      this == PurchaseOrderStatus.approved;
  bool get isClosed =>
      this == PurchaseOrderStatus.closed ||
      this == PurchaseOrderStatus.cancelled ||
      this == PurchaseOrderStatus.received;
}

enum PurchaseReturnStatus {
  draft('DRAFT'),
  pendingApproval('PENDING_APPROVAL'),
  approved('APPROVED'),
  completed('COMPLETED'),
  cancelled('CANCELLED');

  const PurchaseReturnStatus(this.value);
  final String value;

  static PurchaseReturnStatus fromValue(String? raw) {
    return PurchaseReturnStatus.values.firstWhere(
      (e) => e.value == raw || e.name == raw,
      orElse: () => PurchaseReturnStatus.draft,
    );
  }
}

enum SupplierPaymentType {
  payment('PAYMENT'),
  refund('REFUND');

  const SupplierPaymentType(this.value);
  final String value;

  static SupplierPaymentType fromValue(String? raw) {
    return SupplierPaymentType.values.firstWhere(
      (e) => e.value == raw || e.name == raw,
      orElse: () => SupplierPaymentType.payment,
    );
  }
}

enum SupplierTransactionType {
  purchase('PURCHASE'),
  payment('PAYMENT'),
  refund('REFUND'),
  returnCredit('RETURN');

  const SupplierTransactionType(this.value);
  final String value;
}
