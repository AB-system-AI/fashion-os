import 'package:flutter_test/flutter_test.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/hardware/barcode_abstraction.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/hardware/barcode_label_generator_impl.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/hardware/pdf_printer_adapter.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/hardware/printer_hub_impl.dart';
import 'package:fashion_pos_enterprise/features/products/domain/services/barcode_label_print_service.dart';

void main() {
  test('BarcodeLabelGeneratorImpl generates PNG preview offline', () async {
    final generator = BarcodeLabelGeneratorImpl();
    final bytes = await generator.generateImage(
      const BarcodeLabelRequest(
        value: '123456789012',
        productName: 'Test Product',
        sku: 'SKU-1',
        price: 19.99,
      ),
    );
    expect(bytes, isNotEmpty);
    expect(bytes.length, greaterThan(100));
  });

  test('PrinterHub previewLabelImage uses generator abstraction', () async {
    final hub = PrinterHubImpl(
      adapters: [PdfPrinterAdapter()],
      labelGenerator: BarcodeLabelGeneratorImpl(),
    );
    final preview = await hub.previewLabelImage(
      const BarcodeLabelRequest(value: 'ABC123', productName: 'Jacket', sku: 'J-1'),
    );
    expect(preview, isNotEmpty);
  });

  test('BarcodeLabelLayout enum includes qr option', () {
    expect(BarcodeLabelLayout.values, contains(BarcodeLabelLayout.qr));
  });
}
