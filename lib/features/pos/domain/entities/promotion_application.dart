import 'package:equatable/equatable.dart';

class PromotionApplication extends Equatable {
  const PromotionApplication({
    required this.id,
    required this.saleOrderId,
    required this.promotionId,
    required this.discountAmount,
    this.lineId,
    this.promotionName,
    this.appliedAt,
  });

  final String id;
  final String saleOrderId;
  final String promotionId;
  final String? lineId;
  final String? promotionName;
  final double discountAmount;
  final DateTime? appliedAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'sale_order_id': saleOrderId,
        'promotion_id': promotionId,
        'line_id': lineId,
        'promotion_name': promotionName,
        'discount_amount': discountAmount,
        'applied_at': appliedAt?.toIso8601String(),
      };

  factory PromotionApplication.fromJson(Map<String, dynamic> json) {
    return PromotionApplication(
      id: json['id'] as String? ?? '',
      saleOrderId: json['sale_order_id'] as String? ?? '',
      promotionId: json['promotion_id'] as String? ?? '',
      lineId: json['line_id'] as String?,
      promotionName: json['promotion_name'] as String?,
      discountAmount: (json['discount_amount'] as num?)?.toDouble() ?? 0,
      appliedAt: json['applied_at'] != null ? DateTime.tryParse(json['applied_at'] as String) : null,
    );
  }

  @override
  List<Object?> get props => [id, saleOrderId, promotionId];
}
