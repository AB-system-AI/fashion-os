import 'package:fashion_pos_enterprise/core/infrastructure/pagination/paginated_result.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/repository/base_local_repository.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/repository/repository_query.dart';
import 'package:fashion_pos_enterprise/features/sales/domain/entities/delivery.dart';
import 'package:fashion_pos_enterprise/features/sales/domain/entities/order.dart';
import 'package:fashion_pos_enterprise/features/sales/domain/entities/quotation.dart';
import 'package:fashion_pos_enterprise/features/sales/domain/entities/returns.dart';
import 'package:fashion_pos_enterprise/features/sales/domain/entities/shipment.dart';
import 'package:fashion_pos_enterprise/features/sales/domain/entities/timeline.dart';
import 'package:fashion_pos_enterprise/features/sales/domain/enums/sales_enums.dart';

abstract class QuotationRepository implements BaseLocalRepository<Quotation> {
  Future<List<QuotationLine>> listLines(String tenantId, String quotationId);
  Future<QuotationLine> createLine(QuotationLine line);
  Future<List<Quotation>> listByStatus(String tenantId, QuotationStatus status);
}

abstract class SalesOrderRepository implements BaseLocalRepository<SalesOrder> {
  Future<List<SalesOrderLine>> listLines(String tenantId, String orderId);
  Future<SalesOrderLine> createLine(SalesOrderLine line);
  Future<SalesOrderLine> updateLine(SalesOrderLine line);
  Future<List<SalesOrder>> listByStatus(String tenantId, SalesOrderStatus status);
  Future<SalesInvoiceReference> createInvoiceReference(SalesInvoiceReference ref);
}

abstract class SalesReservationRepository implements BaseLocalRepository<SalesReservation> {
  Future<List<SalesReservation>> listByOrder(String tenantId, String orderId);
  Future<List<BackOrder>> listBackOrders(String tenantId, {BackOrderStatus? status});
  Future<BackOrder> createBackOrder(BackOrder backOrder);
}

abstract class ShipmentRepository implements BaseLocalRepository<Shipment> {
  Future<List<ShipmentLine>> listLines(String tenantId, String shipmentId);
  Future<ShipmentLine> createLine(ShipmentLine line);
  Future<List<Shipment>> listByStatus(String tenantId, ShipmentStatus status);
}

abstract class DeliveryRepository implements BaseLocalRepository<Delivery> {
  Future<List<DeliveryLine>> listLines(String tenantId, String deliveryId);
  Future<DeliveryLine> createLine(DeliveryLine line);
}

abstract class ReturnRepository implements BaseLocalRepository<SalesReturnRequest> {
  Future<PaginatedResult<SalesReturnRequest>> listByOrder(String tenantId, String orderId);
}

abstract class ExchangeRepository implements BaseLocalRepository<ExchangeRequest> {}

abstract class CustomerTimelineRepository implements BaseLocalRepository<CustomerOrderTimeline> {
  Future<List<CustomerOrderTimeline>> listByCustomer(String tenantId, String customerId);
}

abstract class SalesSettingsRepository implements BaseLocalRepository<SalesSettings> {
  Future<SalesSettings?> getSettings(String tenantId);
  Future<SalesSettings> saveSettings(SalesSettings settings);
}
