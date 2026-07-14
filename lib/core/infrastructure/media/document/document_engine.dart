import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';

import 'package:fashion_pos_enterprise/core/errors/failure.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/domain/media_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/domain/media_models.dart';
import 'package:fashion_pos_enterprise/core/result/result.dart';

/// Handles PDF, Excel, CSV, text, and backup archive documents.
class DocumentEngine {
  Result<ProcessedDocument> process({
    required Uint8List bytes,
    required String filename,
    DocumentType? type,
  }) {
    final detected = type ?? _detectType(bytes, filename);
    final mime = _mimeFor(detected);
    final checksum = sha256.convert(bytes).toString();

    if (bytes.isEmpty) {
      return const Error(ValidationFailure(message: 'Document cannot be empty', code: 'invalid_document'));
    }

    return Success(
      ProcessedDocument(
        bytes: bytes,
        mimeType: mime,
        documentType: detected,
        sizeBytes: bytes.length,
        checksum: checksum,
      ),
    );
  }

  Result<Uint8List> createBackupArchive(Map<String, Uint8List> files) {
    if (files.isEmpty) {
      return const Error(ValidationFailure(message: 'Backup requires at least one file', code: 'invalid_backup'));
    }
    final archive = Archive();
    for (final entry in files.entries) {
      archive.addFile(ArchiveFile(entry.key, entry.value.length, entry.value));
    }
    final encoded = ZipEncoder().encode(archive);
    if (encoded == null) {
      return const Error(CacheFailure(message: 'Failed to encode backup archive', code: 'backup_failed'));
    }
    return Success(Uint8List.fromList(encoded));
  }

  Result<String> extractTextPreview(Uint8List bytes, DocumentType type) {
    return switch (type) {
      DocumentType.csv || DocumentType.text => Success(String.fromCharCodes(bytes.take(4096))),
      DocumentType.pdf => const Success('[PDF document]'),
      DocumentType.excel => const Success('[Excel document]'),
      DocumentType.backupArchive => const Success('[Backup archive]'),
      DocumentType.docx => const Success('[DOCX document — future support]'),
    };
  }

  DocumentType _detectType(Uint8List bytes, String filename) {
    final lower = filename.toLowerCase();
    if (lower.endsWith('.pdf') || (bytes.length >= 4 && bytes[0] == 0x25 && bytes[1] == 0x50)) {
      return DocumentType.pdf;
    }
    if (lower.endsWith('.xlsx') || lower.endsWith('.xls')) return DocumentType.excel;
    if (lower.endsWith('.csv')) return DocumentType.csv;
    if (lower.endsWith('.zip') || lower.endsWith('.bak')) return DocumentType.backupArchive;
    if (lower.endsWith('.docx')) return DocumentType.docx;
    return DocumentType.text;
  }

  String _mimeFor(DocumentType type) {
    return switch (type) {
      DocumentType.pdf => 'application/pdf',
      DocumentType.excel => 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      DocumentType.csv => 'text/csv',
      DocumentType.text => 'text/plain',
      DocumentType.backupArchive => 'application/zip',
      DocumentType.docx => 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    };
  }
}
