import 'package:fashion_pos_enterprise/core/business/domain/entities/rule_models.dart';
import 'package:fashion_pos_enterprise/core/business/domain/enums/business_enums.dart';
import 'package:fashion_pos_enterprise/core/business/contracts/sequence_store.dart';
import 'package:fashion_pos_enterprise/core/result/result.dart';
import 'package:fashion_pos_enterprise/core/errors/failure.dart';

/// Generates configurable document numbers (invoice, PO, SKU, etc.).
class NumberGeneratorEngine {
  NumberGeneratorEngine(this._sequenceStore, {Map<DocumentNumberType, NumberSequenceFormat>? formats})
      : _formats = formats ?? _defaultFormats;

  final SequenceStore _sequenceStore;
  final Map<DocumentNumberType, NumberSequenceFormat> _formats;

  static final Map<DocumentNumberType, NumberSequenceFormat> _defaultFormats = {
    DocumentNumberType.invoice: const NumberSequenceFormat(type: DocumentNumberType.invoice, prefix: 'INV-', padding: 6),
    DocumentNumberType.purchase: const NumberSequenceFormat(type: DocumentNumberType.purchase, prefix: 'PO-', padding: 6),
    DocumentNumberType.customer: const NumberSequenceFormat(type: DocumentNumberType.customer, prefix: 'CUS-', padding: 5, includeDate: false),
    DocumentNumberType.supplier: const NumberSequenceFormat(type: DocumentNumberType.supplier, prefix: 'SUP-', padding: 5, includeDate: false),
    DocumentNumberType.returnOrder: const NumberSequenceFormat(type: DocumentNumberType.returnOrder, prefix: 'RET-', padding: 6),
    DocumentNumberType.exchange: const NumberSequenceFormat(type: DocumentNumberType.exchange, prefix: 'EXC-', padding: 6),
    DocumentNumberType.receipt: const NumberSequenceFormat(type: DocumentNumberType.receipt, prefix: 'RCP-', padding: 6),
    DocumentNumberType.saleOrder: const NumberSequenceFormat(type: DocumentNumberType.saleOrder, prefix: 'SO-', padding: 6),
    DocumentNumberType.cashSession: const NumberSequenceFormat(type: DocumentNumberType.cashSession, prefix: 'CS-', padding: 6),
    DocumentNumberType.layaway: const NumberSequenceFormat(type: DocumentNumberType.layaway, prefix: 'LAY-', padding: 6),
    DocumentNumberType.journalEntry: const NumberSequenceFormat(type: DocumentNumberType.journalEntry, prefix: 'JE-', padding: 6),
    DocumentNumberType.payrollRun: const NumberSequenceFormat(type: DocumentNumberType.payrollRun, prefix: 'PR-', padding: 6),
    DocumentNumberType.productionOrder: const NumberSequenceFormat(type: DocumentNumberType.productionOrder, prefix: 'MO-', padding: 6),
    DocumentNumberType.workOrder: const NumberSequenceFormat(type: DocumentNumberType.workOrder, prefix: 'WO-', padding: 6),
    DocumentNumberType.quotation: const NumberSequenceFormat(type: DocumentNumberType.quotation, prefix: 'QUO-', padding: 6),
    DocumentNumberType.shipmentDoc: const NumberSequenceFormat(type: DocumentNumberType.shipmentDoc, prefix: 'SHP-', padding: 6),
    DocumentNumberType.paymentVoucher: const NumberSequenceFormat(type: DocumentNumberType.paymentVoucher, prefix: 'PV-', padding: 6),
    DocumentNumberType.receiptVoucher: const NumberSequenceFormat(type: DocumentNumberType.receiptVoucher, prefix: 'RV-', padding: 6),
    DocumentNumberType.transfer: const NumberSequenceFormat(type: DocumentNumberType.transfer, prefix: 'TRF-', padding: 6),
    DocumentNumberType.cheque: const NumberSequenceFormat(type: DocumentNumberType.cheque, prefix: 'CHQ-', padding: 6),
    DocumentNumberType.expenseRequest: const NumberSequenceFormat(type: DocumentNumberType.expenseRequest, prefix: 'EXP-', padding: 6),
    DocumentNumberType.barcode: const NumberSequenceFormat(type: DocumentNumberType.barcode, prefix: 'BC', padding: 10, includeDate: false),
    DocumentNumberType.sku: const NumberSequenceFormat(type: DocumentNumberType.sku, prefix: 'SKU-', padding: 8, includeDate: false),
  };

  void registerFormat(NumberSequenceFormat format) {
    _formats[format.type] = format;
  }

  Future<Result<GeneratedNumber>> next({
    required DocumentNumberType type,
    required String tenantId,
    String? storeId,
    DateTime? at,
  }) async {
    final format = _formats[type];
    if (format == null) {
      return Error(ValidationFailure(message: 'No format registered for $type', code: 'invalid_sequence'));
    }

    final sequence = await _sequenceStore.nextSequence(
      tenantId: tenantId,
      storeId: storeId,
      documentType: type,
    );

    final generatedAt = at ?? DateTime.now().toUtc();
    return Success(
      GeneratedNumber(
        type: type,
        value: format.format(sequence, generatedAt),
        sequence: sequence,
        generatedAt: generatedAt,
      ),
    );
  }
}
