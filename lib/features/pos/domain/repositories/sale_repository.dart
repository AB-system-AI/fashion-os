import 'package:fashion_pos_enterprise/core/infrastructure/pagination/paginated_result.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/repository/base_local_repository.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/repository/repository_query.dart';
import 'package:fashion_pos_enterprise/features/pos/domain/entities/exchange_reference.dart';
import 'package:fashion_pos_enterprise/features/pos/domain/entities/payment.dart';
import 'package:fashion_pos_enterprise/features/pos/domain/entities/return_reference.dart';
import 'package:fashion_pos_enterprise/features/pos/domain/entities/sale.dart';
import 'package:fashion_pos_enterprise/features/pos/domain/entities/suspended_sale.dart';
import 'package:fashion_pos_enterprise/features/pos/domain/enums/pos_enums.dart';

abstract class SaleRepository implements BaseLocalRepository<Sale> {
  Future<Sale?> findByOrderNumber(String tenantId, String orderNumber);
  Future<List<Sale>> listBySession(String tenantId, String cashSessionId);
  Future<List<Sale>> listByStatus(String tenantId, SaleStatus status, {int limit = 50});
  Future<PaginatedResult<Sale>> getPage(RepositoryQuery query);
}

abstract class PaymentRepository implements BaseLocalRepository<Payment> {
  Future<List<Payment>> listBySale(String tenantId, String saleOrderId);
}

abstract class SuspendedSaleRepository implements BaseLocalRepository<SuspendedSale> {
  Future<List<SuspendedSale>> listByStore(String tenantId, String storeId);
}

abstract class ReturnRepository implements BaseLocalRepository<ReturnReference> {
  Future<ReturnReference?> findByReturnNumber(String tenantId, String returnNumber);
}

abstract class ExchangeRepository implements BaseLocalRepository<ExchangeReference> {
  Future<ExchangeReference?> findByExchangeNumber(String tenantId, String exchangeNumber);
}
