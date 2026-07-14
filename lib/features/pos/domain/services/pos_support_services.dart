import 'package:uuid/uuid.dart';

import 'package:fashion_pos_enterprise/core/audit/audit_action.dart';
import 'package:fashion_pos_enterprise/core/audit/audit_service.dart';
import 'package:fashion_pos_enterprise/core/business/domain/enums/business_enums.dart';
import 'package:fashion_pos_enterprise/core/business/engines/number_generator_engine.dart';
import 'package:fashion_pos_enterprise/core/business/domain/entities/receipt_models.dart' as receipt_models;
import 'package:fashion_pos_enterprise/core/business/domain/value_objects/money.dart';
import 'package:fashion_pos_enterprise/core/business/engines/sales/sales_engine.dart';
import 'package:fashion_pos_enterprise/core/errors/failure.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/hardware/printer_abstraction.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_engine.dart';
import 'package:fashion_pos_enterprise/core/result/result.dart';
import 'package:fashion_pos_enterprise/core/search/product_search_service.dart';
import 'package:fashion_pos_enterprise/features/auth/domain/entities/auth_user.dart';
import 'package:fashion_pos_enterprise/core/business/engines/receipt_engine.dart';
import 'package:fashion_pos_enterprise/features/customers/domain/entities/customer.dart';
import 'package:fashion_pos_enterprise/features/customers/domain/services/customer_lookup_service.dart';
import 'package:fashion_pos_enterprise/features/pos/domain/entities/coupon.dart';
import 'package:fashion_pos_enterprise/features/pos/domain/entities/gift_receipt.dart';
import 'package:fashion_pos_enterprise/features/pos/domain/entities/layaway_order.dart';
import 'package:fashion_pos_enterprise/features/pos/domain/entities/payment.dart';
import 'package:fashion_pos_enterprise/features/pos/domain/entities/receipt.dart';
import 'package:fashion_pos_enterprise/features/pos/domain/entities/return_reference.dart';
import 'package:fashion_pos_enterprise/features/pos/domain/entities/sale.dart';
import 'package:fashion_pos_enterprise/features/pos/domain/entities/sale_line.dart';
import 'package:fashion_pos_enterprise/features/pos/domain/enums/pos_enums.dart';
import 'package:fashion_pos_enterprise/features/pos/domain/repositories/coupon_repository.dart';
import 'package:fashion_pos_enterprise/features/pos/domain/repositories/receipt_repository.dart';
import 'package:fashion_pos_enterprise/features/pos/domain/repositories/sale_repository.dart';

class ReceiptService {
  ReceiptService({
    required ReceiptRepository repository,
    required ReceiptEngine receiptEngine,
    required PrinterHub printerHub,
    required AuditService auditService,
    required PermissionEngine permissionEngine,
    required NumberGeneratorEngine numberGenerator,
    Uuid? uuid,
  })  : _repo = repository,
        _engine = receiptEngine,
        _printer = printerHub,
        _audit = auditService,
        _permissions = permissionEngine,
        _numbers = numberGenerator,
        _uuid = uuid ?? const Uuid();

  final ReceiptRepository _repo;
  final ReceiptEngine _engine;
  final PrinterHub _printer;
  final AuditService _audit;
  final PermissionEngine _permissions;
  final NumberGeneratorEngine _numbers;
  final Uuid _uuid;

  Future<Result<Receipt>> generateAndPrint({
    required AuthUser user,
    required Sale sale,
    ReceiptFormat format = ReceiptFormat.thermal,
  }) async {
    try {
      _permissions.require(user, SalePermissions.print);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }

    final numberResult = await _numbers.next(
      type: DocumentNumberType.receipt,
      tenantId: sale.tenantId,
      storeId: sale.storeId,
    );
    if (numberResult.isFailure) return Error(numberResult.failureOrNull!);

    final receiptLines = sale.lines
        .map(
          (l) => receipt_models.ReceiptLine(
            description: l.productName,
            quantity: l.quantity,
            unitPrice: Money.fromMajor(l.unitPrice),
            lineTotal: Money.fromMajor(l.lineTotal),
            sku: l.sku,
          ),
        )
        .toList();

    final receiptResult = _engine.generate(
      receipt_models.ReceiptRequest(
        receiptNumber: numberResult.dataOrNull!.value,
        storeName: 'Store',
        lines: receiptLines,
        subtotal: Money.fromMajor(sale.subtotal),
        discountTotal: Money.fromMajor(sale.discountTotal),
        taxTotal: Money.fromMajor(sale.taxTotal),
        grandTotal: Money.fromMajor(sale.grandTotal),
        currencyCode: sale.currency,
        saleId: sale.id,
      ),
    );
    if (receiptResult.isFailure) return Error(receiptResult.failureOrNull!);

    final businessReceipt = (receiptResult as Success<receipt_models.BusinessReceipt>).data;
    final textLines = _engine.formatAsTextLines(businessReceipt);

    final now = DateTime.now().toUtc();
    final receipt = Receipt(
      id: _uuid.v4(),
      tenantId: sale.tenantId,
      storeId: sale.storeId,
      saleOrderId: sale.id,
      receiptNumber: numberResult.dataOrNull!.value,
      format: format,
      content: textLines.join('\n'),
      qrCode: businessReceipt.qrCodeData,
      barcode: businessReceipt.barcodeData,
      printedAt: now,
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    );
    final saved = await _repo.create(receipt);

    await _printer.printReceipt(
      ReceiptDocument(
        lines: textLines.map((t) => ReceiptLine(text: t)).toList(),
        qrCodeData: businessReceipt.qrCodeData,
        barcodeData: businessReceipt.barcodeData,
        footerText: businessReceipt.footerText,
      ),
    );

    await _audit.log(
      action: AuditAction.create,
      entityType: Receipt.entityTypeName,
      entityId: saved.id,
      employeeId: user.employeeId,
      tenantId: sale.tenantId,
      storeId: sale.storeId,
    );
    return Success(saved);
  }

  Future<Result<Receipt>> reprint({required AuthUser user, required String receiptId}) async {
    try {
      _permissions.require(user, ReceiptPermissions.reprint);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }

    final receipt = await _repo.getById(receiptId, tenantId: user.tenantId);
    if (receipt == null) {
      return const Error(ValidationFailure(message: 'Receipt not found', code: 'not_found'));
    }

    await _printer.printReceipt(
      ReceiptDocument(
        lines: (receipt.content ?? '').split('\n').map((t) => ReceiptLine(text: t)).toList(),
      ),
    );

    final updated = await _repo.update(
      receipt.copyWith(
        reprintCount: receipt.reprintCount + 1,
        printedAt: DateTime.now().toUtc(),
        version: receipt.version + 1,
        updatedAt: DateTime.now().toUtc(),
        syncStatus: LocalSyncStatus.pending,
        isDirty: true,
      ),
    );
    return Success(updated);
  }
}

class CouponService {
  CouponService({
    required CouponRepository repository,
    required SalesEngine salesEngine,
    required AuditService auditService,
    required PermissionEngine permissionEngine,
  })  : _repo = repository,
        _engine = salesEngine,
        _audit = auditService,
        _permissions = permissionEngine;

  final CouponRepository _repo;
  final SalesEngine _engine;
  final AuditService _audit;
  final PermissionEngine _permissions;

  Future<Result<Coupon>> validateAndApply({
    required AuthUser user,
    required String tenantId,
    required String code,
    required double subtotal,
    String? customerId,
  }) async {
    try {
      _permissions.require(user, SalePermissions.discount);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }

    final coupon = await _repo.findByCode(tenantId, code);
    if (coupon == null) {
      return const Error(ValidationFailure(message: 'Coupon not found', code: 'coupon_not_found'));
    }

    final validation = _engine.validateCoupon(coupon: coupon, orderSubtotal: subtotal, customerId: customerId);
    if (validation.isFailure) return Error(validation.failureOrNull!);

    await _audit.log(
      action: AuditAction.update,
      entityType: Coupon.entityTypeName,
      entityId: coupon.id,
      employeeId: user.employeeId,
      tenantId: tenantId,
      metadata: {'code': code},
    );
    return Success(coupon);
  }
}

class SplitPaymentService {
  SplitPaymentService({required SalesEngine salesEngine}) : _engine = salesEngine;

  final SalesEngine _engine;

  Result<SplitPaymentResult> validatePayments({
    required List<Payment> payments,
    required double grandTotal,
  }) {
    final result = _engine.calculateSplitPayments(payments: payments, grandTotal: grandTotal);
    if (!result.isBalanced) {
      return const Error(ValidationFailure(message: 'Payments do not balance', code: 'payment_imbalance'));
    }
    return Success(result);
  }

  double calculateChange(double cashTendered, double grandTotal) =>
      _engine.calculateCashChange(cashTendered, grandTotal);
}

class BarcodeSaleService {
  BarcodeSaleService({required ProductSearchService search, required SalesEngine salesEngine})
      : _search = search,
        _engine = salesEngine;

  final ProductSearchService _search;
  final SalesEngine _engine;

  Future<Result<SaleLine>> lineFromBarcode({
    required String tenantId,
    required String barcode,
    double quantity = 1,
  }) async {
    final product = await _search.findByBarcode(tenantId: tenantId, barcode: barcode);
    if (product == null) {
      return const Error(ValidationFailure(message: 'Product not found for barcode', code: 'not_found'));
    }
    return Success(
      SaleLine(
        id: '',
        variantId: product.productId,
        productId: product.productId,
        productName: product.name,
        sku: product.sku,
        barcode: product.barcode,
        quantity: quantity,
        unitPrice: product.retailPrice ?? 0,
      ),
    );
  }
}

class QuickSaleService {
  QuickSaleService({required SalesEngine salesEngine}) : _engine = salesEngine;

  final SalesEngine _engine;

  Sale applyQuickTotals(Sale sale) => _engine.applyTotals(sale);
}

class PosCustomerLookupService {
  PosCustomerLookupService({required CustomerLookupService customerLookup}) : _lookup = customerLookup;

  final CustomerLookupService _lookup;

  Future<Result<Customer>> posLookup({required AuthUser user, required String query}) =>
      _lookup.posLookup(user: user, query: query);
}

class ReturnValidationService {
  ReturnValidationService({required SalesEngine salesEngine, required SaleRepository saleRepository})
      : _engine = salesEngine,
        _sales = saleRepository;

  final SalesEngine _engine;
  final SaleRepository _sales;

  Future<Result<RefundValidation>> validate({
    required String tenantId,
    required String saleOrderId,
    required double refundAmount,
    bool isPartial = false,
  }) async {
    final sale = await _sales.getById(saleOrderId, tenantId: tenantId);
    if (sale == null) {
      return const Error(ValidationFailure(message: 'Sale not found', code: 'not_found'));
    }
    final validation = _engine.validateRefund(originalSale: sale, refundAmount: refundAmount, isPartial: isPartial);
    if (!validation.isValid) {
      return Error(ValidationFailure(message: validation.message ?? 'Invalid refund', code: 'invalid_refund'));
    }
    return Success(validation);
  }
}

class ExchangeValidationService {
  ExchangeValidationService({required SalesEngine salesEngine}) : _engine = salesEngine;

  final SalesEngine _engine;

  Result<ExchangeValidation> validate({required double returnValue, required double newSaleValue}) {
    final validation = _engine.validateExchange(returnValue: returnValue, newSaleValue: newSaleValue);
    if (!validation.isValid) {
      return Error(ValidationFailure(message: validation.message ?? 'Invalid exchange', code: 'invalid_exchange'));
    }
    return Success(validation);
  }
}

class LayawayService {
  LayawayService({
    required SalesEngine salesEngine,
    required AuditService auditService,
    required PermissionEngine permissionEngine,
    required NumberGeneratorEngine numberGenerator,
    Uuid? uuid,
  })  : _engine = salesEngine,
        _audit = auditService,
        _permissions = permissionEngine,
        _numbers = numberGenerator,
        _uuid = uuid ?? const Uuid();

  final SalesEngine _engine;
  final AuditService _audit;
  final PermissionEngine _permissions;
  final NumberGeneratorEngine _numbers;
  final Uuid _uuid;

  Future<Result<LayawayOrder>> createLayaway({
    required AuthUser user,
    required Sale sale,
    required String customerId,
    double depositPercent = 25,
    int installmentCount = 3,
  }) async {
    try {
      _permissions.require(user, LayawayPermissions.manage);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }

    final calc = _engine.calculateLayaway(
      totalAmount: sale.grandTotal,
      depositPercent: depositPercent,
      installmentCount: installmentCount,
    );

    final numberResult = await _numbers.next(
      type: DocumentNumberType.layaway,
      tenantId: sale.tenantId,
      storeId: sale.storeId,
    );
    if (numberResult.isFailure) return Error(numberResult.failureOrNull!);

    final now = DateTime.now().toUtc();
    final layaway = LayawayOrder(
      id: _uuid.v4(),
      tenantId: sale.tenantId,
      storeId: sale.storeId,
      layawayNumber: numberResult.dataOrNull!.value,
      saleOrderId: sale.id,
      customerId: customerId,
      totalAmount: calc.totalAmount,
      depositAmount: calc.depositAmount,
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    );

    await _audit.log(
      action: AuditAction.create,
      entityType: LayawayOrder.entityTypeName,
      entityId: layaway.id,
      employeeId: user.employeeId,
      tenantId: sale.tenantId,
      storeId: sale.storeId,
    );
    return Success(layaway);
  }
}

class PromotionApplicationService {
  PromotionApplicationService({required SalesEngine salesEngine}) : _engine = salesEngine;

  final SalesEngine _engine;

  Sale applyPromotionDiscount(Sale sale, double discountAmount) {
    return _engine.applyTotals(
      sale.copyWith(discountTotal: sale.discountTotal + discountAmount),
    );
  }
}

class GiftReceiptService {
  GiftReceiptService({
    required AuditService auditService,
    required PermissionEngine permissionEngine,
    required NumberGeneratorEngine numberGenerator,
    Uuid? uuid,
  })  : _audit = auditService,
        _permissions = permissionEngine,
        _numbers = numberGenerator,
        _uuid = uuid ?? const Uuid();

  final AuditService _audit;
  final PermissionEngine _permissions;
  final NumberGeneratorEngine _numbers;
  final Uuid _uuid;

  Future<Result<GiftReceipt>> create({
    required AuthUser user,
    required Sale sale,
    String? recipientName,
    String? message,
  }) async {
    try {
      _permissions.require(user, GiftReceiptPermissions.create);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }

    final numberResult = await _numbers.next(
      type: DocumentNumberType.receipt,
      tenantId: sale.tenantId,
      storeId: sale.storeId,
    );
    if (numberResult.isFailure) return Error(numberResult.failureOrNull!);

    final now = DateTime.now().toUtc();
    final gift = GiftReceipt(
      id: _uuid.v4(),
      tenantId: sale.tenantId,
      saleOrderId: sale.id,
      giftNumber: numberResult.dataOrNull!.value,
      recipientName: recipientName,
      message: message,
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    );

    await _audit.log(
      action: AuditAction.create,
      entityType: GiftReceipt.entityTypeName,
      entityId: gift.id,
      employeeId: user.employeeId,
      tenantId: sale.tenantId,
      storeId: sale.storeId,
    );
    return Success(gift);
  }
}
