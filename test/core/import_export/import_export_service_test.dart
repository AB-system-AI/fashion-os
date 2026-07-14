import 'package:fashion_pos_enterprise/core/import_export/import_export_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ImportExportService service;

  setUp(() {
    service = ImportExportService();
  });

  test('exportCsv produces valid CSV bytes', () async {
    final payload = await service.exportCsv(
      entityType: 'products',
      rows: [
        {'sku': 'SKU-1', 'name': 'Shirt'},
        {'sku': 'SKU-2', 'name': 'Pants'},
      ],
    );

    expect(payload.format, ExportFormat.csv);
    final text = String.fromCharCodes(payload.bytes);
    expect(text, contains('sku,name'));
    expect(text, contains('SKU-1,Shirt'));
  });

  test('parseCsv round-trips headers', () async {
    const csv = 'sku,name\nSKU-1,Shirt\n';
    final rows = await service.parseCsv(csv);
    expect(rows.length, 1);
    expect(rows.first['sku'], 'SKU-1');
    expect(rows.first['name'], 'Shirt');
  });

  test('exportBackup encodes JSON', () async {
    final payload = await service.exportBackup({'version': 1, 'tables': []});
    expect(payload.format, ExportFormat.jsonBackup);
    final text = String.fromCharCodes(payload.bytes);
    expect(text, contains('"version":1'));
  });
}
