import 'package:uuid/uuid.dart';

import 'package:fashion_pos_enterprise/core/business/engines/accounting/accounting_engine.dart';
import 'package:fashion_pos_enterprise/core/business/events/business_events.dart';
import 'package:fashion_pos_enterprise/core/business/events/domain_event_bus.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/features/accounting/domain/entities/account.dart';
import 'package:fashion_pos_enterprise/features/accounting/domain/enums/accounting_enums.dart';
import 'package:fashion_pos_enterprise/features/accounting/domain/repositories/accounting_repositories.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/repository/repository_query.dart';
import 'package:fashion_pos_enterprise/features/accounting/domain/services/accounting_services.dart';
import 'package:fashion_pos_enterprise/features/manufacturing/domain/repositories/manufacturing_repositories.dart';
import 'package:fashion_pos_enterprise/features/products/domain/repositories/product_repository.dart';

/// Subscribes to domain events from POS, Purchasing, Inventory, CRM, and Manufacturing to auto-post journals.
class AccountingIntegrationService {
  AccountingIntegrationService({
    required DomainEventBus eventBus,
    required PostingService postingService,
    required AccountingRepository accountingRepository,
    required AccountingEngine accountingEngine,
    ProductionRepository? productionRepository,
    ProductRepository? productRepository,
    Uuid? uuid,
  })  : _eventBus = eventBus,
        _posting = postingService,
        _accounts = accountingRepository,
        _engine = accountingEngine,
        _production = productionRepository,
        _products = productRepository,
        _uuid = uuid ?? const Uuid();

  final DomainEventBus _eventBus;
  final PostingService _posting;
  final AccountingRepository _accounts;
  final AccountingEngine _engine;
  final ProductionRepository? _production;
  final ProductRepository? _products;
  final Uuid _uuid;

  void register() {
    _eventBus.subscribe(DomainEventTypes.saleCompleted, _onSaleCompleted);
    _eventBus.subscribe(DomainEventTypes.saleCancelled, _onSaleCancelled);
    _eventBus.subscribe(DomainEventTypes.cashSessionClosed, _onCashSessionClosed);
    _eventBus.subscribe(DomainEventTypes.purchaseReceived, _onPurchaseReceived);
    _eventBus.subscribe(DomainEventTypes.stockChanged, _onStockChanged);
    _eventBus.subscribe(DomainEventTypes.paymentReceived, _onPaymentReceived);
    _eventBus.subscribe(DomainEventTypes.payrollApproved, _onPayrollApproved);
    _eventBus.subscribe(DomainEventTypes.productionStarted, _onProductionStarted);
    _eventBus.subscribe(DomainEventTypes.productionCompleted, _onProductionCompleted);
    _eventBus.subscribe(DomainEventTypes.materialIssued, _onMaterialIssued);
    _eventBus.subscribe(DomainEventTypes.materialReturned, _onMaterialReturned);
    _eventBus.subscribe(DomainEventTypes.finishedGoodsReceived, _onFinishedGoodsReceived);
  }

  Future<void> ensureDefaultChart(String tenantId) async {
    final defaults = [
      (SystemAccounts.cash, 'Cash', AccountType.asset, AccountNormalBalance.debit),
      (SystemAccounts.accountsReceivable, 'Accounts Receivable', AccountType.asset, AccountNormalBalance.debit),
      (SystemAccounts.inventory, 'Inventory', AccountType.asset, AccountNormalBalance.debit),
      (SystemAccounts.accountsPayable, 'Accounts Payable', AccountType.liability, AccountNormalBalance.credit),
      (SystemAccounts.taxPayable, 'Tax Payable', AccountType.liability, AccountNormalBalance.credit),
      (SystemAccounts.loyaltyLiability, 'Loyalty Liability', AccountType.liability, AccountNormalBalance.credit),
      (SystemAccounts.walletLiability, 'Wallet Liability', AccountType.liability, AccountNormalBalance.credit),
      (SystemAccounts.salesRevenue, 'Sales Revenue', AccountType.revenue, AccountNormalBalance.credit),
      (SystemAccounts.cogs, 'Cost of Goods Sold', AccountType.cogs, AccountNormalBalance.debit),
      (SystemAccounts.cashOverShort, 'Cash Over/Short', AccountType.expense, AccountNormalBalance.debit),
      (SystemAccounts.salariesExpense, 'Salaries Expense', AccountType.expense, AccountNormalBalance.debit),
      (SystemAccounts.payrollPayable, 'Payroll Payable', AccountType.liability, AccountNormalBalance.credit),
      (SystemAccounts.payrollTaxPayable, 'Payroll Tax Payable', AccountType.liability, AccountNormalBalance.credit),
      (SystemAccounts.wip, 'Work In Process', AccountType.asset, AccountNormalBalance.debit),
      (SystemAccounts.manufacturingVariance, 'Manufacturing Variance', AccountType.expense, AccountNormalBalance.debit),
      (SystemAccounts.scrapExpense, 'Scrap Expense', AccountType.expense, AccountNormalBalance.debit),
      (SystemAccounts.manufacturingOverhead, 'Manufacturing Overhead', AccountType.expense, AccountNormalBalance.debit),
    ];

    final now = DateTime.now().toUtc();
    for (final d in defaults) {
      final existing = await _accounts.findByCode(tenantId, d.$1);
      if (existing != null) continue;
      await _accounts.create(
        Account(
          id: _uuid.v4(),
          tenantId: tenantId,
          code: d.$1,
          name: d.$2,
          accountType: d.$3,
          normalBalance: d.$4,
          isSystem: true,
          version: 1,
          createdAt: now,
          updatedAt: now,
          syncStatus: LocalSyncStatus.pending,
          isDirty: true,
        ),
      );
    }
  }

  Future<Map<String, Account>> _accountsByCode(String tenantId) async {
    await ensureDefaultChart(tenantId);
    final page = await _accounts.getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    return {for (final a in page.items) a.code: a};
  }

  Future<void> _onSaleCompleted(DomainEvent event) async {
    if (event is! SaleCompletedEvent || event.tenantId == null) return;
    final map = await _accountsByCode(event.tenantId!);
    final grandTotal = event.grandTotalMinor / 100;
    final lines = _engine.saleJournalLines(grandTotal: grandTotal, taxTotal: 0, accountsByCode: map);
    await _posting.createAutoJournal(
      tenantId: event.tenantId!,
      storeId: event.storeId,
      source: JournalSource.sale,
      referenceType: 'sale_order',
      referenceId: event.saleId,
      lines: lines,
      description: 'Auto-post sale ${event.saleId}',
    );
  }

  Future<void> _onSaleCancelled(DomainEvent event) async {
    if (event is! SaleCancelledEvent || event.tenantId == null) return;
    // Reversal handled by reverse journal in future; idempotent skip for now
  }

  Future<void> _onCashSessionClosed(DomainEvent event) async {
    if (event is! CashSessionClosedEvent || event.tenantId == null) return;
    final difference = event.differenceMinor / 100;
    if (difference.abs() < 0.01) return;
    final map = await _accountsByCode(event.tenantId!);
    final lines = _engine.cashSessionVarianceLines(difference: difference, accountsByCode: map);
    if (lines.isEmpty) return;
    await _posting.createAutoJournal(
      tenantId: event.tenantId!,
      storeId: event.storeId,
      source: JournalSource.cashSession,
      referenceType: 'cash_session',
      referenceId: event.sessionId,
      lines: lines,
      description: 'Cash session variance',
    );
  }

  Future<void> _onPurchaseReceived(DomainEvent event) async {
    if (event is! PurchaseReceivedEvent || event.tenantId == null) return;
    final map = await _accountsByCode(event.tenantId!);
    // Amount placeholder — full integration reads purchase receipt total
    final lines = _engine.purchaseReceiptLines(amount: 0, accountsByCode: map);
    if (lines.every((l) => l.debit == 0 && l.credit == 0)) return;
    await _posting.createAutoJournal(
      tenantId: event.tenantId!,
      storeId: event.storeId,
      source: JournalSource.purchase,
      referenceType: 'purchase_receipt',
      referenceId: event.purchaseId,
      lines: lines,
      description: 'Auto-post purchase receipt',
    );
  }

  Future<void> _onStockChanged(DomainEvent event) async {
    if (event is! StockChangedEvent || event.tenantId == null) return;
    if (event.movementType != 'sale') return;
    // COGS posting optional — inventory valuation extension point
  }

  Future<void> _onPaymentReceived(DomainEvent event) async {
    if (event is! PaymentReceivedEvent || event.tenantId == null) return;
    _engine.publishPaymentRecorded(
      paymentId: event.paymentId,
      amount: event.amountMinor / 100,
      tenantId: event.tenantId,
    );
  }

  Future<void> _onPayrollApproved(DomainEvent event) async {
    if (event is! PayrollApprovedEvent || event.tenantId == null) return;
    final map = await _accountsByCode(event.tenantId!);
    final gross = event.totalGrossMinor / 100;
    final tax = event.totalTaxMinor / 100;
    final net = event.totalNetMinor / 100;
    final lines = _engine.payrollApprovedLines(
      grossSalary: gross,
      taxAmount: tax,
      netPay: net,
      accountsByCode: map,
    );
    await _posting.createAutoJournal(
      tenantId: event.tenantId!,
      source: JournalSource.manual,
      referenceType: 'payroll_run',
      referenceId: event.payrollRunId,
      lines: lines,
      description: 'Auto-post payroll ${event.payrollRunId}',
    );
  }

  Future<double> _productCost(String tenantId, String productId) async {
    final product = await _products?.getById(productId, tenantId: tenantId);
    return product?.cost ?? 0;
  }

  Future<void> _onProductionStarted(DomainEvent event) async {
    if (event is! ProductionStartedEvent || event.tenantId == null || _production == null) return;
    final order = await _production!.getById(event.productionOrderId, tenantId: event.tenantId);
    if (order == null) return;
    final map = await _accountsByCode(event.tenantId!);
    final materialValue = order.plannedQty * await _productCost(event.tenantId!, order.productId);
    final lines = _engine.wipStartLines(amount: materialValue * 0.1, accountsByCode: map);
    if (lines.isEmpty) return;
    await _posting.createAutoJournal(
      tenantId: event.tenantId!,
      source: JournalSource.manufacturing,
      referenceType: 'production_order',
      referenceId: event.productionOrderId,
      lines: lines,
      description: 'Production started ${order.orderNumber}',
    );
  }

  Future<void> _onProductionCompleted(DomainEvent event) async {
    if (event is! ProductionCompletedEvent || event.tenantId == null || _production == null) return;
    final order = await _production!.getById(event.productionOrderId, tenantId: event.tenantId);
    if (order == null) return;
    final map = await _accountsByCode(event.tenantId!);
    final unitCost = await _productCost(event.tenantId!, order.productId);
    final plannedValue = order.plannedQty * unitCost;
    final actualValue = event.completedQty * unitCost;
    final variance = actualValue - plannedValue;
    final lines = _engine.manufacturingVarianceLines(varianceAmount: variance, accountsByCode: map);
    if (lines.isEmpty) return;
    await _posting.createAutoJournal(
      tenantId: event.tenantId!,
      source: JournalSource.manufacturing,
      referenceType: 'production_order',
      referenceId: event.productionOrderId,
      lines: lines,
      description: 'Production variance ${order.orderNumber}',
    );
  }

  Future<void> _onMaterialIssued(DomainEvent event) async {
    if (event is! MaterialIssuedEvent || event.tenantId == null) return;
    final map = await _accountsByCode(event.tenantId!);
    final cost = await _productCost(event.tenantId!, event.productId);
    final amount = event.quantity * cost;
    final lines = _engine.materialIssueLines(amount: amount, accountsByCode: map);
    if (lines.isEmpty) return;
    await _posting.createAutoJournal(
      tenantId: event.tenantId!,
      source: JournalSource.manufacturing,
      referenceType: 'material_issue',
      referenceId: event.issueId,
      lines: lines,
      description: 'Material issue ${event.issueId}',
    );
  }

  Future<void> _onMaterialReturned(DomainEvent event) async {
    if (event is! MaterialReturnedEvent || event.tenantId == null) return;
    final map = await _accountsByCode(event.tenantId!);
    final cost = await _productCost(event.tenantId!, event.productId);
    final amount = event.quantity * cost;
    final lines = _engine.materialReturnLines(amount: amount, accountsByCode: map);
    if (lines.isEmpty) return;
    await _posting.createAutoJournal(
      tenantId: event.tenantId!,
      source: JournalSource.manufacturing,
      referenceType: 'material_return',
      referenceId: event.returnId,
      lines: lines,
      description: 'Material return ${event.returnId}',
    );
  }

  Future<void> _onFinishedGoodsReceived(DomainEvent event) async {
    if (event is! FinishedGoodsReceivedEvent || event.tenantId == null) return;
    final map = await _accountsByCode(event.tenantId!);
    final cost = await _productCost(event.tenantId!, event.productId);
    final amount = event.quantity * cost;
    final lines = _engine.finishedGoodsReceiptLines(amount: amount, accountsByCode: map);
    if (lines.isEmpty) return;
    await _posting.createAutoJournal(
      tenantId: event.tenantId!,
      source: JournalSource.manufacturing,
      referenceType: 'finished_goods_receipt',
      referenceId: event.receiptId,
      lines: lines,
      description: 'Finished goods receipt ${event.receiptId}',
    );
  }
}
