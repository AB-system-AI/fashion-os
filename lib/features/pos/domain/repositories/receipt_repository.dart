import 'package:fashion_pos_enterprise/core/infrastructure/repository/base_local_repository.dart';
import 'package:fashion_pos_enterprise/features/pos/domain/entities/receipt.dart';

abstract class ReceiptRepository implements BaseLocalRepository<Receipt> {
  Future<Receipt?> findBySaleOrder(String tenantId, String saleOrderId);
  Future<Receipt?> findByReceiptNumber(String tenantId, String receiptNumber);
  Future<List<Receipt>> listPrintHistory(String tenantId, String saleOrderId);
}
