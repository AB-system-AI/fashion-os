import 'package:flutter_test/flutter_test.dart';

import 'package:fashion_pos_enterprise/core/import_export/import_export_service.dart';

void main() {
  final service = ImportExportService();

  test('validateRows detects duplicate SKUs in file', () async {
    final report = await service.validateRows(
      rows: [
        {'sku': 'A1', 'name': 'One'},
        {'sku': 'A1', 'name': 'Two'},
      ],
      validateRow: (_, __) async => null,
    );
    expect(report.duplicateSkus, contains('A1'));
    expect(report.canImport, isFalse);
  });

  test('exportExcel produces spreadsheet payload', () async {
    final payload = await service.exportExcel(
      entityType: 'product',
      rows: [
        {'name': 'Hat', 'sku': 'H1'},
      ],
    );
    expect(payload.format, ExportFormat.excel);
    expect(String.fromCharCodes(payload.bytes), contains('Workbook'));
  });

  test('exportPdfCatalog produces pdf bytes', () async {
    final payload = await service.exportPdfCatalog(
      title: 'Catalog',
      rows: [
        {'name': 'Hat', 'sku': 'H1', 'retail_price': 10, 'status': 'active'},
      ],
    );
    expect(payload.format, ExportFormat.pdf);
    expect(String.fromCharCodes(payload.bytes.take(8)), startsWith('%PDF'));
  });
}
