/// Stock movement direction and business reason.
enum MovementType {
  purchase,
  sale,
  returnItem,
  adjustment,
  transferIn,
  transferOut,
  damage,
  initialStock;

  String get value => switch (this) {
        MovementType.returnItem => 'RETURN',
        MovementType.transferIn => 'TRANSFER_IN',
        MovementType.transferOut => 'TRANSFER_OUT',
        MovementType.initialStock => 'INITIAL_STOCK',
        _ => name.toUpperCase(),
      };

  static MovementType fromValue(String value) {
    return MovementType.values.firstWhere(
      (e) => e.value == value.toUpperCase() || e.name == value.toLowerCase(),
      orElse: () => MovementType.adjustment,
    );
  }
}

enum MovementReason {
  receipt,
  issue,
  correction,
  transfer,
  countVariance,
  damage,
  returnToVendor,
  customerReturn,
  initial,
  reversal;

  String get value => name;
}

enum StockStatus {
  inStock,
  lowStock,
  outOfStock,
  negative,
  reserved;

  String get value => name;
}

enum TransferStatus {
  draft,
  pendingApproval,
  shipped,
  received,
  completed,
  cancelled;

  String get value => switch (this) {
        TransferStatus.pendingApproval => 'PENDING_APPROVAL',
        _ => name.toUpperCase(),
      };

  static TransferStatus fromValue(String value) {
    return TransferStatus.values.firstWhere(
      (e) => e.value == value.toUpperCase(),
      orElse: () => TransferStatus.draft,
    );
  }
}

enum StockCountStatus {
  draft,
  inProgress,
  completed,
  cancelled;

  String get value => switch (this) {
        StockCountStatus.inProgress => 'IN_PROGRESS',
        _ => name.toUpperCase(),
      };

  static StockCountStatus fromValue(String value) {
    return StockCountStatus.values.firstWhere(
      (e) => e.value == value.toUpperCase(),
      orElse: () => StockCountStatus.draft,
    );
  }
}

enum AdjustmentStatus {
  draft,
  posted,
  cancelled;

  String get value => name.toUpperCase();
}
