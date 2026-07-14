import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/features/pos/domain/enums/pos_enums.dart';

class Receipt extends Equatable implements SyncableEntity {
  const Receipt({
    required this.id,
    required this.tenantId,
    required this.saleOrderId,
    required this.receiptNumber,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.storeId,
    this.format = ReceiptFormat.thermal,
    this.content,
    this.qrCode,
    this.barcode,
    this.printedAt,
    this.reprintCount = 0,
    this.deletedAt,
  });

  static const entityTypeName = 'receipt';

  @override
  final String id;
  @override
  final String tenantId;
  final String? storeId;
  final String saleOrderId;
  final String receiptNumber;
  final ReceiptFormat format;
  final String? content;
  final String? qrCode;
  final String? barcode;
  final DateTime? printedAt;
  final int reprintCount;
  @override
  final int version;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? deletedAt;
  @override
  final LocalSyncStatus syncStatus;
  @override
  final bool isDirty;

  @override
  String get entityType => entityTypeName;

  @override
  Map<String, dynamic> toPayload() => {
        'id': id,
        'tenant_id': tenantId,
        'store_id': storeId,
        'sale_order_id': saleOrderId,
        'receipt_number': receiptNumber,
        'format': format.value,
        'content': content,
        'qr_code': qrCode,
        'barcode': barcode,
        'printed_at': printedAt?.toIso8601String(),
        'reprint_count': reprintCount,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static Receipt fromPayload(Map<String, dynamic> json, LocalRecord record) {
    return Receipt(
      id: json['id'] as String? ?? record.id,
      tenantId: json['tenant_id'] as String? ?? record.tenantId,
      storeId: json['store_id'] as String?,
      saleOrderId: json['sale_order_id'] as String? ?? '',
      receiptNumber: json['receipt_number'] as String? ?? '',
      format: ReceiptFormat.fromValue(json['format'] as String?),
      content: json['content'] as String?,
      qrCode: json['qr_code'] as String?,
      barcode: json['barcode'] as String?,
      printedAt: json['printed_at'] != null ? DateTime.tryParse(json['printed_at'] as String) : null,
      reprintCount: (json['reprint_count'] as num?)?.toInt() ?? 0,
      version: record.version,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
      deletedAt: record.deletedAt,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  Receipt copyWith({
    int? reprintCount,
    DateTime? printedAt,
    int? version,
    DateTime? updatedAt,
    LocalSyncStatus? syncStatus,
    bool? isDirty,
  }) {
    return Receipt(
      id: id,
      tenantId: tenantId,
      storeId: storeId,
      saleOrderId: saleOrderId,
      receiptNumber: receiptNumber,
      format: format,
      content: content,
      qrCode: qrCode,
      barcode: barcode,
      printedAt: printedAt ?? this.printedAt,
      reprintCount: reprintCount ?? this.reprintCount,
      version: version ?? this.version,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      isDirty: isDirty ?? this.isDirty,
    );
  }

  @override
  List<Object?> get props => [id, receiptNumber, saleOrderId];
}
