import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/features/pos/domain/entities/sale_line.dart';
import 'package:fashion_pos_enterprise/features/pos/domain/enums/pos_enums.dart';

class Sale extends Equatable implements SyncableEntity {
  const Sale({
    required this.id,
    required this.tenantId,
    required this.storeId,
    required this.orderNumber,
    required this.employeeId,
    required this.lines,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.status = SaleStatus.draft,
    this.customerId,
    this.cashSessionId,
    this.registerId,
    this.deviceId,
    this.subtotal = 0,
    this.discountTotal = 0,
    this.taxTotal = 0,
    this.grandTotal = 0,
    this.amountPaid = 0,
    this.amountDue = 0,
    this.currency = 'USD',
    this.couponId,
    this.notes,
    this.completedAt,
    this.voidedAt,
    this.voidedBy,
    this.voidReason,
    this.deletedAt,
  });

  static const entityTypeName = 'sale_order';

  @override
  final String id;
  @override
  final String tenantId;
  final String storeId;
  final String orderNumber;
  final SaleStatus status;
  final String? customerId;
  final String employeeId;
  final String? cashSessionId;
  final String? registerId;
  final String? deviceId;
  final List<SaleLine> lines;
  final double subtotal;
  final double discountTotal;
  final double taxTotal;
  final double grandTotal;
  final double amountPaid;
  final double amountDue;
  final String currency;
  final String? couponId;
  final String? notes;
  final DateTime? completedAt;
  final DateTime? voidedAt;
  final String? voidedBy;
  final String? voidReason;
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

  bool get isDraft => status == SaleStatus.draft;
  bool get isCompleted => status == SaleStatus.completed;
  bool get isSuspended => status == SaleStatus.suspended;

  @override
  String get entityType => entityTypeName;

  @override
  Map<String, dynamic> toPayload() => {
        'id': id,
        'tenant_id': tenantId,
        'store_id': storeId,
        'order_number': orderNumber,
        'status': status.value,
        'customer_id': customerId,
        'employee_id': employeeId,
        'cash_session_id': cashSessionId,
        'register_id': registerId,
        'device_id': deviceId,
        'lines': lines.map((l) => l.toJson()).toList(),
        'subtotal': subtotal,
        'discount_total': discountTotal,
        'tax_total': taxTotal,
        'grand_total': grandTotal,
        'amount_paid': amountPaid,
        'amount_due': amountDue,
        'currency': currency,
        'coupon_id': couponId,
        'notes': notes,
        'completed_at': completedAt?.toIso8601String(),
        'voided_at': voidedAt?.toIso8601String(),
        'voided_by': voidedBy,
        'void_reason': voidReason,
        'version': version,
        'sync_version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static Sale fromPayload(Map<String, dynamic> json, LocalRecord record) {
    final linesJson = json['lines'] as List? ?? [];
    return Sale(
      id: json['id'] as String? ?? record.id,
      tenantId: json['tenant_id'] as String? ?? record.tenantId,
      storeId: json['store_id'] as String? ?? '',
      orderNumber: json['order_number'] as String? ?? '',
      status: SaleStatus.fromValue(json['status'] as String?),
      customerId: json['customer_id'] as String?,
      employeeId: json['employee_id'] as String? ?? '',
      cashSessionId: json['cash_session_id'] as String?,
      registerId: json['register_id'] as String?,
      deviceId: json['device_id'] as String?,
      lines: linesJson.map((e) => SaleLine.fromJson(Map<String, dynamic>.from(e as Map))).toList(),
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0,
      discountTotal: (json['discount_total'] as num?)?.toDouble() ?? 0,
      taxTotal: (json['tax_total'] as num?)?.toDouble() ?? 0,
      grandTotal: (json['grand_total'] as num?)?.toDouble() ?? 0,
      amountPaid: (json['amount_paid'] as num?)?.toDouble() ?? 0,
      amountDue: (json['amount_due'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? 'USD',
      couponId: json['coupon_id'] as String?,
      notes: json['notes'] as String?,
      completedAt: json['completed_at'] != null ? DateTime.tryParse(json['completed_at'] as String) : null,
      voidedAt: json['voided_at'] != null ? DateTime.tryParse(json['voided_at'] as String) : null,
      voidedBy: json['voided_by'] as String?,
      voidReason: json['void_reason'] as String?,
      version: record.version,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
      deletedAt: record.deletedAt,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  Sale copyWith({
    SaleStatus? status,
    List<SaleLine>? lines,
    double? subtotal,
    double? discountTotal,
    double? taxTotal,
    double? grandTotal,
    double? amountPaid,
    double? amountDue,
    String? customerId,
    String? couponId,
    String? notes,
    DateTime? completedAt,
    int? version,
    DateTime? updatedAt,
    LocalSyncStatus? syncStatus,
    bool? isDirty,
  }) {
    return Sale(
      id: id,
      tenantId: tenantId,
      storeId: storeId,
      orderNumber: orderNumber,
      status: status ?? this.status,
      customerId: customerId ?? this.customerId,
      employeeId: employeeId,
      cashSessionId: cashSessionId,
      registerId: registerId,
      deviceId: deviceId,
      lines: lines ?? this.lines,
      subtotal: subtotal ?? this.subtotal,
      discountTotal: discountTotal ?? this.discountTotal,
      taxTotal: taxTotal ?? this.taxTotal,
      grandTotal: grandTotal ?? this.grandTotal,
      amountPaid: amountPaid ?? this.amountPaid,
      amountDue: amountDue ?? this.amountDue,
      currency: currency,
      couponId: couponId ?? this.couponId,
      notes: notes ?? this.notes,
      completedAt: completedAt ?? this.completedAt,
      voidedAt: voidedAt,
      voidedBy: voidedBy,
      voidReason: voidReason,
      version: version ?? this.version,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      isDirty: isDirty ?? this.isDirty,
    );
  }

  @override
  List<Object?> get props => [id, orderNumber, status, grandTotal];
}
