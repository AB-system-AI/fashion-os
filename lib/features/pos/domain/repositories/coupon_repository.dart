import 'package:fashion_pos_enterprise/core/infrastructure/repository/base_local_repository.dart';
import 'package:fashion_pos_enterprise/features/pos/domain/entities/coupon.dart';

abstract class CouponRepository implements BaseLocalRepository<Coupon> {
  Future<Coupon?> findByCode(String tenantId, String code);
}
