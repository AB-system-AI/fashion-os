import 'package:fashion_pos_enterprise/core/business/domain/entities/receipt_models.dart';
import 'package:fashion_pos_enterprise/core/result/result.dart';
import 'package:fashion_pos_enterprise/core/errors/failure.dart';

/// Generates business receipts from templates with QR, barcode, and tax breakdown.
class ReceiptEngine {
  Result<BusinessReceipt> generate(ReceiptRequest request) {
    if (request.lines.isEmpty) {
      return const Error(ValidationFailure(message: 'Receipt must have at least one line', code: 'invalid_receipt'));
    }

    final template = request.template;
    final qrData = template?.showQrCode == true
        ? 'RECEIPT:${request.receiptNumber}|TOTAL:${request.grandTotal.minorUnits}'
        : null;
    final barcodeData = template?.showBarcode == true ? request.receiptNumber : null;

    return Success(
      BusinessReceipt(
        receiptNumber: request.receiptNumber,
        storeName: request.storeName,
        lines: request.lines,
        subtotal: request.subtotal,
        discountTotal: request.discountTotal,
        taxTotal: request.taxTotal,
        grandTotal: request.grandTotal,
        currencyCode: request.currencyCode,
        issuedAt: DateTime.now().toUtc(),
        template: template,
        taxLines: request.taxLines,
        qrCodeData: qrData,
        barcodeData: barcodeData,
        footerText: template?.footerText,
        customFields: template?.customFields ?? const {},
        digitalReceiptUrl: request.saleId != null ? 'https://receipts.fashionpos.local/${request.saleId}' : null,
      ),
    );
  }

  List<String> formatAsTextLines(BusinessReceipt receipt) {
    final lines = <String>[
      receipt.storeName,
      'Receipt: ${receipt.receiptNumber}',
      'Date: ${receipt.issuedAt.toIso8601String()}',
      '---',
    ];

    for (final line in receipt.lines) {
      lines.add('${line.description} x${line.quantity} = ${line.lineTotal.majorUnits}');
    }

    lines.addAll([
      '---',
      'Subtotal: ${receipt.subtotal.majorUnits}',
      'Discount: -${receipt.discountTotal.majorUnits}',
      'Tax: ${receipt.taxTotal.majorUnits}',
      'TOTAL: ${receipt.grandTotal.majorUnits} ${receipt.currencyCode}',
    ]);

    if (receipt.footerText != null) lines.add(receipt.footerText!);
    if (receipt.qrCodeData != null) lines.add('QR: ${receipt.qrCodeData}');

    return lines;
  }
}
