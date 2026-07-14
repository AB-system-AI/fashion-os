import 'package:fashion_pos_enterprise/core/business/engines/purchasing/purchase_engine.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/repository/repository_query.dart';
import 'package:fashion_pos_enterprise/features/purchasing/domain/entities/purchase_order.dart';
import 'package:fashion_pos_enterprise/features/purchasing/domain/entities/supplier.dart';
import 'package:fashion_pos_enterprise/features/purchasing/domain/enums/purchasing_enums.dart';
import 'package:fashion_pos_enterprise/features/purchasing/domain/repositories/purchasing_repositories.dart';

class SupplierPurchaseSummary {
  const SupplierPurchaseSummary({
    required this.supplier,
    required this.orderCount,
    required this.totalPurchases,
    required this.outstanding,
  });

  final Supplier supplier;
  final int orderCount;
  final double totalPurchases;
  final double outstanding;
}

class PurchasingReportService {
  PurchasingReportService({
    required SupplierRepository supplierRepository,
    required PurchaseOrderRepository purchaseOrderRepository,
    required PurchaseReceiptRepository receiptRepository,
    required PurchaseEngine purchaseEngine,
  })  : _suppliers = supplierRepository,
        _orders = purchaseOrderRepository,
        _receipts = receiptRepository,
        _engine = purchaseEngine;

  final SupplierRepository _suppliers;
  final PurchaseOrderRepository _orders;
  final PurchaseReceiptRepository _receipts;
  final PurchaseEngine _engine;

  Future<List<SupplierPurchaseSummary>> supplierPurchases(String tenantId) async {
    final suppliers = await _suppliers.getPage(
      RepositoryQuery(tenantId: tenantId, pageSize: 500),
    );
    final summaries = <SupplierPurchaseSummary>[];
    for (final supplier in suppliers.items) {
      final orders = await _orders.listBySupplier(tenantId, supplier.id);
      final total = orders.fold<double>(0, (sum, o) => sum + o.grandTotal);
      summaries.add(
        SupplierPurchaseSummary(
          supplier: supplier,
          orderCount: orders.length,
          totalPurchases: total,
          outstanding: supplier.currentBalance,
        ),
      );
    }
    summaries.sort((a, b) => b.totalPurchases.compareTo(a.totalPurchases));
    return summaries;
  }

  Future<List<PurchaseOrder>> outstandingOrders(String tenantId) async {
    final orders = await _orders.getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    return orders.items
        .where(
          (o) =>
              o.status == PurchaseOrderStatus.sent ||
              o.status == PurchaseOrderStatus.partiallyReceived ||
              o.status == PurchaseOrderStatus.approved,
        )
        .toList();
  }

  Future<List<PurchaseOrder>> purchaseHistory(String tenantId, {int limit = 100}) async {
    final page = await _orders.getPage(
      RepositoryQuery(tenantId: tenantId, pageSize: limit, sortBy: 'updated_at'),
    );
    return page.items;
  }

  Future<List<Supplier>> supplierBalances(String tenantId) async {
    final page = await _suppliers.getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    final suppliers = page.items.toList()..sort((a, b) => b.currentBalance.compareTo(a.currentBalance));
    return suppliers;
  }

  Future<List<SupplierPurchaseSummary>> topSuppliers(String tenantId, {int limit = 10}) async {
    final all = await supplierPurchases(tenantId);
    return all.take(limit).toList();
  }

  Future<int> receivingCount(String tenantId) async {
    final receipts = await _receipts.getPage(RepositoryQuery(tenantId: tenantId, pageSize: 1000));
    return receipts.items.length;
  }
}
