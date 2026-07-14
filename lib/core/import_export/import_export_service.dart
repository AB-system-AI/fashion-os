import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:fashion_pos_enterprise/core/logging/app_logger.dart';

enum ExportFormat { csv, excel, pdf, jsonBackup }

enum ImportFormat { csv, excel, jsonBackup }

/// Tabular export payload.
class ExportPayload {
  const ExportPayload({
    required this.fileName,
    required this.format,
    required this.bytes,
    this.mimeType,
  });

  final String fileName;
  final ExportFormat format;
  final List<int> bytes;
  final String? mimeType;
}

/// Import result with row-level error reporting.
class ImportResult {
  const ImportResult({
    required this.totalRows,
    required this.importedRows,
    required this.failedRows,
    this.errors = const [],
  });

  final int totalRows;
  final int importedRows;
  final int failedRows;
  final List<String> errors;

  bool get success => failedRows == 0;
}

/// Contract for data import/export operations.
abstract class DataPortAdapter {
  String get entityType;

  Future<ImportResult> importRows(List<Map<String, dynamic>> rows);

  Future<List<Map<String, dynamic>>> exportRows({Map<String, String> filters = const {}});
}

/// CSV/Excel/backup import-export coordinator.
class ImportExportService {
  Future<ExportPayload> exportCsv({
    required String entityType,
    required List<Map<String, dynamic>> rows,
    List<String>? columns,
  }) async {
    if (rows.isEmpty) {
      throw ArgumentError('No rows to export');
    }
    final headers = columns ?? rows.first.keys.toList();
    final data = [
      headers,
      for (final row in rows) headers.map((h) => row[h]?.toString() ?? '').toList(),
    ];
    final csv = const ListToCsvConverter().convert(data);
    return ExportPayload(
      fileName: '${entityType}_${DateTime.now().millisecondsSinceEpoch}.csv',
      format: ExportFormat.csv,
      bytes: utf8.encode(csv),
      mimeType: 'text/csv',
    );
  }

  Future<List<Map<String, dynamic>>> parseCsv(String content, {bool hasHeader = true}) async {
    final rows = const CsvToListConverter().convert(content);
    if (rows.isEmpty) return [];
    if (!hasHeader) {
      return [
        for (final row in rows)
          {for (var i = 0; i < row.length; i++) 'col_$i': row[i]},
      ];
    }
    final headers = rows.first.map((e) => e.toString()).toList();
    return [
      for (final row in rows.skip(1))
        {
          for (var i = 0; i < headers.length; i++)
            headers[i]: i < row.length ? row[i] : null,
        },
    ];
  }

  Future<ExportPayload> exportBackup(Map<String, dynamic> backup) async {
    final json = jsonEncode(backup);
    return ExportPayload(
      fileName: 'fashion_pos_backup_${DateTime.now().millisecondsSinceEpoch}.json',
      format: ExportFormat.jsonBackup,
      bytes: utf8.encode(json),
      mimeType: 'application/json',
    );
  }

  Future<Map<String, dynamic>> parseBackup(File file) async {
    final content = await file.readAsString();
    return jsonDecode(content) as Map<String, dynamic>;
  }

  Future<ImportResult> importViaAdapter({
    required DataPortAdapter adapter,
    required List<Map<String, dynamic>> rows,
  }) async {
    AppLogger.info('Importing ${rows.length} rows into ${adapter.entityType}');
    return adapter.importRows(rows);
  }

  /// Validates rows without persisting — used for import preview.
  Future<ImportValidationReport> validateRows({
    required List<Map<String, dynamic>> rows,
    required Future<String?> Function(Map<String, dynamic> row, int index) validateRow,
  }) async {
    final issues = <ImportRowIssue>[];
    final duplicates = <String>[];
    final seenSkus = <String>{};

    for (var i = 0; i < rows.length; i++) {
      final row = rows[i];
      final sku = row['sku']?.toString();
      if (sku != null && sku.isNotEmpty) {
        if (seenSkus.contains(sku)) {
          duplicates.add(sku);
          issues.add(ImportRowIssue(rowIndex: i + 1, field: 'sku', message: 'Duplicate SKU in file: $sku'));
        }
        seenSkus.add(sku);
      }
      final error = await validateRow(row, i);
      if (error != null) {
        issues.add(ImportRowIssue(rowIndex: i + 1, message: error));
      }
    }

    return ImportValidationReport(
      totalRows: rows.length,
      validRows: rows.length - issues.map((e) => e.rowIndex).toSet().length,
      issues: issues,
      duplicateSkus: duplicates.toSet().toList(),
    );
  }

  /// Excel-compatible XML Spreadsheet export (opens in Excel/LibreOffice).
  Future<ExportPayload> exportExcel({
    required String entityType,
    required List<Map<String, dynamic>> rows,
    List<String>? columns,
  }) async {
    if (rows.isEmpty) throw ArgumentError('No rows to export');
    final headers = columns ?? rows.first.keys.toList();
    final buffer = StringBuffer()
      ..writeln('<?xml version="1.0"?>')
      ..writeln('<?mso-application progid="Excel.Sheet"?>')
      ..writeln('<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet">')
      ..writeln('<Worksheet ss:Name="Export" xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet">')
      ..writeln('<Table>');
    buffer.writeln('<Row>${headers.map((h) => '<Cell><Data ss:Type="String">${_xmlEscape(h)}</Data></Cell>').join()}</Row>');
    for (final row in rows) {
      buffer.writeln(
        '<Row>${headers.map((h) => '<Cell><Data ss:Type="String">${_xmlEscape(row[h]?.toString() ?? '')}</Data></Cell>').join()}</Row>',
      );
    }
    buffer.writeln('</Table></Worksheet></Workbook>');
    return ExportPayload(
      fileName: '${entityType}_${DateTime.now().millisecondsSinceEpoch}.xls',
      format: ExportFormat.excel,
      bytes: utf8.encode(buffer.toString()),
      mimeType: 'application/vnd.ms-excel',
    );
  }

  Future<List<Map<String, dynamic>>> parseExcel(String content) async {
    // XML Spreadsheet and tab-separated fallback.
    if (content.trimLeft().startsWith('<?xml') || content.contains('<Workbook')) {
      final rows = <Map<String, dynamic>>[];
      final rowPattern = RegExp(r'<Row>(.*?)</Row>', dotAll: true);
      final cellPattern = RegExp(r'<Data[^>]*>(.*?)</Data>', dotAll: true);
      final matches = rowPattern.allMatches(content);
      List<String>? headers;
      for (final match in matches) {
        final cells = cellPattern.allMatches(match.group(1)!).map((m) => _xmlUnescape(m.group(1)!)).toList();
        if (headers == null) {
          headers = cells;
          continue;
        }
        rows.add({for (var i = 0; i < headers.length; i++) headers[i]: i < cells.length ? cells[i] : null});
      }
      return rows;
    }
    return parseCsv(content.replaceAll('\t', ','));
  }

  /// Simple text PDF catalog export.
  Future<ExportPayload> exportPdfCatalog({
    required String title,
    required List<Map<String, dynamic>> rows,
    List<String> columns = const ['name', 'sku', 'retail_price', 'status'],
  }) async {
    final lines = <String>[title, 'Generated ${DateTime.now().toIso8601String()}', ''];
    for (final row in rows) {
      lines.add(columns.map((c) => '${c.toUpperCase()}: ${row[c]}').join(' | '));
    }
    final pdf = _buildSimplePdf(lines);
    return ExportPayload(
      fileName: 'catalog_${DateTime.now().millisecondsSinceEpoch}.pdf',
      format: ExportFormat.pdf,
      bytes: pdf,
      mimeType: 'application/pdf',
    );
  }

  String _xmlEscape(String value) =>
      value.replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;');

  String _xmlUnescape(String value) =>
      value.replaceAll('&lt;', '<').replaceAll('&gt;', '>').replaceAll('&amp;', '&');

  List<int> _buildSimplePdf(List<String> lines) {
    final content = lines.join('\n');
    final objects = <String>[
      '1 0 obj<</Type/Catalog/Pages 2 0 R>>endobj',
      '2 0 obj<</Type/Pages/Kids[3 0 R]/Count 1>>endobj',
      '3 0 obj<</Type/Page/Parent 2 0 R/MediaBox[0 0 612 792]/Contents 4 0 R/Resources<</Font<</F1 5 0 R>>>>>>endobj',
      '4 0 obj<</Length ${content.length + 50}>>stream\nBT /F1 10 Tf 40 750 Td (${_pdfEscape(content)}) Tj ET\nendstream endobj',
      '5 0 obj<</Type/Font/Subtype/Type1/BaseFont/Helvetica>>endobj',
    ];
    final buffer = StringBuffer('%PDF-1.4\n');
    final offsets = <int>[];
    for (final obj in objects) {
      offsets.add(buffer.length);
      buffer.writeln(obj);
    }
    final xrefOffset = buffer.length;
    buffer.writeln('xref');
    buffer.writeln('0 ${objects.length + 1}');
    buffer.writeln('0000000000 65535 f ');
    for (final offset in offsets) {
      buffer.writeln('${offset.toString().padLeft(10, '0')} 00000 n ');
    }
    buffer.writeln('trailer<</Size ${objects.length + 1}/Root 1 0 R>>');
    buffer.writeln('startxref');
    buffer.writeln(xrefOffset);
    buffer.writeln('%%EOF');
    return utf8.encode(buffer.toString());
  }

  String _pdfEscape(String text) => text.replaceAll('(', '\\(').replaceAll(')', '\\)');
}

/// Row-level validation issue for import preview.
class ImportRowIssue {
  const ImportRowIssue({required this.rowIndex, required this.message, this.field});

  final int rowIndex;
  final String? field;
  final String message;
}

/// Import validation report before commit.
class ImportValidationReport {
  const ImportValidationReport({
    required this.totalRows,
    required this.validRows,
    required this.issues,
    this.duplicateSkus = const [],
  });

  final int totalRows;
  final int validRows;
  final List<ImportRowIssue> issues;
  final List<String> duplicateSkus;

  bool get canImport => issues.isEmpty;
}
