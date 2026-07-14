import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fashion_pos_enterprise/core/business/business_engine_facade.dart';
import 'package:fashion_pos_enterprise/core/business/contracts/exchange_rate_provider.dart';
import 'package:fashion_pos_enterprise/core/business/contracts/sequence_store.dart';
import 'package:fashion_pos_enterprise/core/business/engines/barcode_engine.dart';
import 'package:fashion_pos_enterprise/core/business/engines/business_calendar_engine.dart';
import 'package:fashion_pos_enterprise/core/business/engines/cash_session_engine.dart';
import 'package:fashion_pos_enterprise/core/business/engines/currency_engine.dart';
import 'package:fashion_pos_enterprise/core/business/engines/discount_engine.dart';
import 'package:fashion_pos_enterprise/core/business/engines/exchange_rate_engine.dart';
import 'package:fashion_pos_enterprise/core/business/engines/inventory/inventory_engine.dart';
import 'package:fashion_pos_enterprise/core/business/engines/purchasing/purchase_engine.dart';
import 'package:fashion_pos_enterprise/core/business/engines/inventory_rules_engine.dart';
import 'package:fashion_pos_enterprise/core/business/engines/loyalty_engine.dart';
import 'package:fashion_pos_enterprise/core/business/domain/enums/business_enums.dart';
import 'package:fashion_pos_enterprise/core/business/engines/notification_engine.dart';
import 'package:fashion_pos_enterprise/core/business/engines/number_generator_engine.dart';
import 'package:fashion_pos_enterprise/core/business/engines/pricing_engine.dart';
import 'package:fashion_pos_enterprise/core/business/engines/promotion_engine.dart';
import 'package:fashion_pos_enterprise/core/business/engines/receipt_engine.dart';
import 'package:fashion_pos_enterprise/core/business/engines/rule_engine.dart';
import 'package:fashion_pos_enterprise/core/business/engines/admin/administration_engine.dart';
import 'package:fashion_pos_enterprise/core/business/engines/assets/assets_engine.dart';
import 'package:fashion_pos_enterprise/core/business/engines/automation/automation_engine.dart';
import 'package:fashion_pos_enterprise/core/business/engines/automation/scheduler_engine.dart';
import 'package:fashion_pos_enterprise/core/business/engines/accounting/accounting_engine.dart';
import 'package:fashion_pos_enterprise/core/business/engines/hr/hr_engine.dart';
import 'package:fashion_pos_enterprise/core/business/engines/integration/integration_connector_engine.dart';
import 'package:fashion_pos_enterprise/core/business/engines/sales_order/sales_order_engine.dart';
import 'package:fashion_pos_enterprise/core/business/engines/treasury/treasury_engine.dart';
import 'package:fashion_pos_enterprise/core/business/engines/analytics/analytics_engine.dart';
import 'package:fashion_pos_enterprise/core/business/engines/manufacturing/manufacturing_engine.dart';
import 'package:fashion_pos_enterprise/core/business/engines/sales/sales_engine.dart';
import 'package:fashion_pos_enterprise/core/business/engines/tax_engine.dart';
import 'package:fashion_pos_enterprise/core/business/engines/validation_engine.dart';
import 'package:fashion_pos_enterprise/core/business/engines/workflow/approval_engine.dart';
import 'package:fashion_pos_enterprise/core/business/engines/workflow/scheduler_engine.dart';
import 'package:fashion_pos_enterprise/core/business/engines/workflow/workflow_designer_engine.dart';
import 'package:fashion_pos_enterprise/core/business/engines/workflow_engine.dart';
import 'package:fashion_pos_enterprise/core/business/events/domain_event_bus.dart';

final domainEventBusProvider = Provider<DomainEventBus>((ref) {
  final bus = DomainEventBus();
  ref.onDispose(bus.clear);
  return bus;
});

final sequenceStoreProvider = Provider<SequenceStore>((ref) => InMemorySequenceStore());

final exchangeRateProviderProvider = Provider<ExchangeRateProvider>(
  (ref) => StaticExchangeRateProvider(),
);

final pricingEngineProvider = Provider<PricingEngine>((ref) => PricingEngine());
final discountEngineProvider = Provider<DiscountEngine>((ref) => DiscountEngine());
final promotionEngineProvider = Provider<PromotionEngine>((ref) {
  return PromotionEngine(eventBus: ref.watch(domainEventBusProvider));
});
final taxEngineProvider = Provider<TaxEngine>((ref) => TaxEngine());
final loyaltyEngineProvider = Provider<LoyaltyEngine>((ref) {
  return LoyaltyEngine(eventBus: ref.watch(domainEventBusProvider));
});
final inventoryRulesEngineProvider = Provider<InventoryRulesEngine>((ref) => InventoryRulesEngine());
final inventoryEngineProvider = Provider<InventoryEngine>((ref) {
  return InventoryEngine(
    rulesEngine: ref.watch(inventoryRulesEngineProvider),
    eventBus: ref.watch(domainEventBusProvider),
  );
});
final purchaseEngineProvider = Provider<PurchaseEngine>((ref) => PurchaseEngine());
final validationEngineProvider = Provider<ValidationEngine>((ref) => ValidationEngine());
final receiptEngineProvider = Provider<ReceiptEngine>((ref) => ReceiptEngine());
final barcodeEngineProvider = Provider<BarcodeEngine>((ref) => BarcodeEngine());
final numberGeneratorEngineProvider = Provider<NumberGeneratorEngine>((ref) {
  return NumberGeneratorEngine(ref.watch(sequenceStoreProvider));
});
final workflowEngineProvider = Provider<WorkflowEngine>((ref) => WorkflowEngine());
final approvalEngineProvider = Provider<ApprovalEngine>((ref) {
  return ApprovalEngine(workflowEngine: ref.watch(workflowEngineProvider));
});
final workflowDesignerEngineProvider = Provider<WorkflowDesignerEngine>((ref) => WorkflowDesignerEngine());
final workflowSchedulerEngineProvider = Provider<WorkflowSchedulerEngine>((ref) => WorkflowSchedulerEngine());
final notificationEngineProvider = Provider<NotificationEngine>((ref) {
  return NotificationEngine(
    providers: [
      NoOpNotificationProvider(NotificationChannel.inApp),
      NoOpNotificationProvider(NotificationChannel.push),
      NoOpNotificationProvider(NotificationChannel.email),
      NoOpNotificationProvider(NotificationChannel.sms),
      NoOpNotificationProvider(NotificationChannel.whatsApp),
      NoOpNotificationProvider(NotificationChannel.background),
      NoOpNotificationProvider(NotificationChannel.slack),
      NoOpNotificationProvider(NotificationChannel.teams),
      NoOpNotificationProvider(NotificationChannel.webhook),
    ],
  );
});
final currencyEngineProvider = Provider<CurrencyEngine>((ref) => CurrencyEngine());
final exchangeRateEngineProvider = Provider<ExchangeRateEngine>((ref) {
  return ExchangeRateEngine(ref.watch(exchangeRateProviderProvider));
});
final cashSessionEngineProvider = Provider<CashSessionEngine>((ref) => CashSessionEngine());
final salesEngineProvider = Provider<SalesEngine>((ref) {
  return SalesEngine(eventBus: ref.watch(domainEventBusProvider));
});
final accountingEngineProvider = Provider<AccountingEngine>((ref) {
  return AccountingEngine(eventBus: ref.watch(domainEventBusProvider));
});
final hrEngineProvider = Provider<HREngine>((ref) {
  return HREngine(eventBus: ref.watch(domainEventBusProvider));
});
final manufacturingEngineProvider = Provider<ManufacturingEngine>((ref) {
  return ManufacturingEngine(eventBus: ref.watch(domainEventBusProvider));
});
final analyticsEngineProvider = Provider<AnalyticsEngine>((ref) => AnalyticsEngine());
final salesOrderEngineProvider = Provider<SalesOrderEngine>((ref) => SalesOrderEngine(eventBus: ref.watch(domainEventBusProvider)));
final treasuryEngineProvider = Provider<TreasuryEngine>((ref) => TreasuryEngine(eventBus: ref.watch(domainEventBusProvider)));
final integrationConnectorEngineProvider = Provider<IntegrationConnectorEngine>((ref) => IntegrationConnectorEngine());
final businessCalendarEngineProvider = Provider<BusinessCalendarEngine>((ref) => BusinessCalendarEngine());
final ruleEngineProvider = Provider<RuleEngine>((ref) {
  return RuleEngine(notificationEngine: ref.watch(notificationEngineProvider));
});
final automationEngineProvider = Provider<AutomationEngine>((ref) {
  return AutomationEngine(
    ruleEngine: ref.watch(ruleEngineProvider),
    workflowEngine: ref.watch(workflowEngineProvider),
  );
});
final schedulerEngineProvider = Provider<SchedulerEngine>((ref) => SchedulerEngine());
final assetsEngineProvider = Provider<AssetsEngine>((ref) {
  return AssetsEngine(eventBus: ref.watch(domainEventBusProvider));
});
final administrationEngineProvider = Provider<AdministrationEngine>((ref) => AdministrationEngine());

final businessEngineFacadeProvider = Provider<BusinessEngineFacade>((ref) {
  return BusinessEngineFacade(
    pricing: ref.watch(pricingEngineProvider),
    promotion: ref.watch(promotionEngineProvider),
    discount: ref.watch(discountEngineProvider),
    tax: ref.watch(taxEngineProvider),
  );
});
