import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/features/sales/domain/enums/sales_enums.dart';

class Quotation extends Equatable implements SyncableEntity {
  const Quotation({
    required this.id,
    required this.tenantId,
    required this.quotationNumber,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.customerId,
    this.status = QuotationStatus.draft,
    this.validUntil,
    this.subtotal = 0,
    this.discountTotal = 0,
    this.taxTotal = 0,
    this.grandTotal = 0,
    this.notes,
    this.createdBy,
    this.deletedAt,
  });

  static const entityTypeName = 'quotation';

  @override
  final String id;
  @override
  final String tenantId;
  final String quotationNumber;
  final String? customerId;
  final QuotationStatus status;
  final DateTime? validUntil;
  final double subtotal;
  final double discountTotal;
  final double taxTotal;
  final double grandTotal;
  final String? notes;
  final String? createdBy;
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

  Quotation copyWith({
    QuotationStatus? status,
    double? subtotal,
    double? discountTotal,
    double? taxTotal,
    double? grandTotal,
    int? version,
    DateTime? updatedAt,
    LocalSyncStatus? syncStatus,
    bool? isDirty,
  }) =>
      Quotation(
        id: id,
        tenantId: tenantId,
        quotationNumber: quotationNumber,
        customerId: customerId,
        status: status ?? this.status,
        validUntil: validUntil,
        subtotal: subtotal ?? this.subtotal,
        discountTotal: discountTotal ?? this.discountTotal,
        taxTotal: taxTotal ?? this.taxTotal,
        grandTotal: grandTotal ?? this.grandTotal,
        notes: notes,
        createdBy: createdBy,
        version: version ?? this.version,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt,
        syncStatus: syncStatus ?? this.syncStatus,
        isDirty: isDirty ?? this.isDirty,
      );

  @override
  Map<String, dynamic> toPayload() => {
        'id': id,
        'tenant_id': tenantId,
        'quotation_number': quotationNumber,
        'customer_id': customerId,
        'status': status.value,
        'valid_until': validUntil?.toIso8601String(),
        'subtotal': subtotal,
        'discount_total': discountTotal,
        'tax_total': taxTotal,
        'grand_total': grandTotal,
        'notes': notes,
        'created_by': createdBy,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static Quotation fromPayload(Map<String, dynamic> json, LocalRecord record) => Quotation(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        quotationNumber: json['quotation_number'] as String? ?? record.searchName ?? '',
        customerId: json['customer_id'] as String?,
        status: QuotationStatus.fromValue(json['status'] as String?),
        validUntil: json['valid_until'] != null ? DateTime.tryParse(json['valid_until'] as String) : null,
        subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0,
        discountTotal: (json['discount_total'] as num?)?.toDouble() ?? 0,
        taxTotal: (json['tax_total'] as num?)?.toDouble() ?? 0,
        grandTotal: (json['grand_total'] as num?)?.toDouble() ?? 0,
        notes: json['notes'] as String?,
        createdBy: json['created_by'] as String?,
        version: record.version,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
        deletedAt: record.deletedAt,
        syncStatus: record.syncStatus,
        isDirty: record.isDirty,
      );

  @override
  List<Object?> get props => [id, quotationNumber, status, version];
}

class QuotationLine extends Equatable implements SyncableEntity {
  const QuotationLine({
    required this.id,
    required this.tenantId,
    required this.quotationId,
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.lineNumber = 1,
    this.variantId,
    this.discountPercent = 0,
    this.taxRate = 0,
    this.deletedAt,
  });

  static const entityTypeName = 'quotation_line';

  @override
  final String id;
  @override
  final String tenantId;
  final String quotationId;
  final int lineNumber;
  final String productId;
  final String? variantId;
  final double quantity;
  final double unitPrice;
  final double discountPercent;
  final double taxRate;
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
        'quotation_id': quotationId,
        'line_number': lineNumber,
        'product_id': productId,
        'variant_id': variantId,
        'quantity': quantity,
        'unit_price': unitPrice,
        'discount_percent': discountPercent,
        'tax_rate': taxRate,
        'version': version,
      };

  static QuotationLine fromPayload(Map<String, dynamic> json, LocalRecord record) => QuotationLine(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        quotationId: json['quotation_id'] as String? ?? '',
        lineNumber: json['line_number'] as int? ?? 1,
        productId: json['product_id'] as String? ?? '',
        variantId: json['variant_id'] as String?,
        quantity: (json['quantity'] as num?)?.toDouble() ?? 0,
        unitPrice: (json['unit_price'] as num?)?.toDouble() ?? 0,
        discountPercent: (json['discount_percent'] as num?)?.toDouble() ?? 0,
        taxRate: (json['tax_rate'] as num?)?.toDouble() ?? 0,
        version: record.version,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
        deletedAt: record.deletedAt,
        syncStatus: record.syncStatus,
        isDirty: record.isDirty,
      );

  @override
  List<Object?> get props => [id, quotationId, lineNumber, version];
}
