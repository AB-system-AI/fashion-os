import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/hardware/barcode_label_generator_impl.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/hardware/pdf_printer_adapter.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/hardware/printer_hub_impl.dart';

final pdfPrinterAdapterProvider = Provider<PdfPrinterAdapter>((ref) => PdfPrinterAdapter());

final barcodeLabelGeneratorProvider = Provider<BarcodeLabelGeneratorImpl>((ref) {
  return BarcodeLabelGeneratorImpl();
});

final printerHubProvider = Provider<PrinterHubImpl>((ref) {
  return PrinterHubImpl(
    adapters: [ref.watch(pdfPrinterAdapterProvider)],
    labelGenerator: ref.watch(barcodeLabelGeneratorProvider),
  );
});
