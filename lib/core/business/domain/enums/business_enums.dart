/// Price list types supported by the pricing engine.
enum PriceListType {
  retail,
  wholesale,
  vip,
  distributor,
  tier,
  customerGroup,
  timeBased,
  happyHour,
  seasonal,
  manualOverride,
}

/// Discount application method.
enum DiscountType {
  percentage,
  fixedAmount,
  buyXGetY,
  bundle,
  combo,
  category,
  brand,
  customer,
  coupon,
  voucher,
  loyalty,
}

/// Tax calculation mode.
enum TaxMode {
  inclusive,
  exclusive,
}

/// Tax category for regional readiness.
enum TaxCategory {
  vat,
  salesTax,
  gst,
  regional,
  exempt,
}

/// Loyalty tier levels.
enum LoyaltyTier {
  standard,
  silver,
  gold,
  vip,
}

/// Loyalty transaction type.
enum LoyaltyTransactionType {
  earn,
  redeem,
  adjust,
  birthdayBonus,
  tierUpgrade,
  tierDowngrade,
  expire,
}

/// Inventory stock classification.
enum StockClassification {
  onHand,
  reserved,
  available,
  incoming,
  damaged,
  returned,
}

/// Workflow types.
enum WorkflowType {
  purchase,
  receiving,
  sale,
  returnOrder,
  exchange,
  inventoryTransfer,
  approval,
  cancellation,
}

/// Workflow step status.
enum WorkflowStepStatus {
  pending,
  inProgress,
  completed,
  rejected,
  cancelled,
}

/// Number sequence document types.
enum DocumentNumberType {
  invoice,
  purchase,
  customer,
  supplier,
  returnOrder,
  exchange,
  receipt,
  barcode,
  sku,
  saleOrder,
  cashSession,
  layaway,
  journalEntry,
  payrollRun,
  productionOrder,
  workOrder,
  quotation,
  shipmentDoc,
  paymentVoucher,
  receiptVoucher,
  transfer,
  cheque,
  expenseRequest,
}

/// Notification channel.
enum NotificationChannel {
  push,
  email,
  sms,
  whatsApp,
  inApp,
  background,
  slack,
  teams,
  webhook,
}

/// Promotion conflict resolution strategy.
enum PromotionConflictStrategy {
  highestPriority,
  bestForCustomer,
  stackable,
  exclusive,
}

/// Business rule operator.
enum RuleOperator {
  lessThan,
  lessThanOrEqual,
  greaterThan,
  greaterThanOrEqual,
  equal,
  notEqual,
}

/// Currency rounding mode.
enum RoundingMode {
  halfUp,
  halfDown,
  up,
  down,
  none,
}

/// Barcode format.
enum BarcodeFormat {
  ean13,
  code128,
  qr,
  customSku,
}

/// Cash session movement type.
enum CashMovementType {
  sale,
  refund,
  cashIn,
  cashOut,
  openingFloat,
  closingFloat,
}

/// Calendar event type.
enum CalendarEventType {
  workingHours,
  holiday,
  financialYearStart,
  financialYearEnd,
  dailyClosing,
  monthlyClosing,
}
