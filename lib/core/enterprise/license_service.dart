import 'dart:convert';

import 'package:fashion_pos_enterprise/core/enterprise/license_validator.dart';
import 'package:fashion_pos_enterprise/core/enterprise/remote_config_service.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/database/app_database.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/database/database_initializer.dart';
import 'package:fashion_pos_enterprise/core/logging/app_logger.dart';
import 'package:fashion_pos_enterprise/core/network/network_info.dart';

/// Offline-capable license management with grace period support.
class LicenseService {
  LicenseService({
    required LicenseValidator validator,
    required RemoteConfigService remoteConfig,
    required NetworkInfo networkInfo,
    this.defaultGracePeriod = const Duration(days: 7),
    this.validationInterval = const Duration(hours: 24),
  })  : _validator = validator,
        _remoteConfig = remoteConfig,
        _networkInfo = networkInfo;

  final LicenseValidator _validator;
  final RemoteConfigService _remoteConfig;
  final NetworkInfo _networkInfo;
  final Duration defaultGracePeriod;
  final Duration validationInterval;

  Future<LicenseEvaluation> evaluate({
    required String? tenantId,
    required String? subscriptionStatus,
    String? subscriptionPlan,
    DateTime? validUntil,
  }) async {
    final cached = tenantId != null ? await _readCache(tenantId) : null;
    final online = await _networkInfo.isConnected;

    if (online && tenantId != null) {
      try {
        final status = await _validator.validate(
          tenantId: tenantId,
          subscriptionStatus: subscriptionStatus,
        );
        final evaluation = _fromRemoteStatus(
          status: status,
          tenantId: tenantId,
          plan: subscriptionPlan,
          validUntil: validUntil,
        );
        await _writeCache(evaluation);
        return evaluation;
      } catch (e, st) {
        AppLogger.warning('Online license validation failed, using cache', e, st);
      }
    }

    if (cached != null) {
      return _evaluateCached(cached);
    }

    return LicenseEvaluation(
      tenantId: tenantId,
      status: LicenseStatus.unknown,
      licenseType: LicenseType.unknown,
      canOperatePos: tenantId != null,
      message: 'Operating offline without license cache',
      source: LicenseSource.offlineFallback,
    );
  }

  LicenseEvaluation _evaluateCached(LicenseCacheRecord cached) {
    final now = DateTime.now().toUtc();
    if (cached.status == LicenseStatus.valid || cached.status == LicenseStatus.gracePeriod) {
      if (cached.validUntil != null && now.isAfter(cached.validUntil!)) {
        if (cached.gracePeriodEndsAt != null && now.isBefore(cached.gracePeriodEndsAt!)) {
          return LicenseEvaluation(
            tenantId: cached.tenantId,
            status: LicenseStatus.gracePeriod,
            licenseType: cached.licenseType,
            canOperatePos: true,
            validUntil: cached.validUntil,
            gracePeriodEndsAt: cached.gracePeriodEndsAt,
            message: 'License expired — grace period active',
            source: LicenseSource.cache,
          );
        }
        return LicenseEvaluation(
          tenantId: cached.tenantId,
          status: LicenseStatus.expired,
          licenseType: cached.licenseType,
          canOperatePos: true,
          validUntil: cached.validUntil,
          gracePeriodEndsAt: cached.gracePeriodEndsAt,
          message: 'License expired — POS continues during grace',
          source: LicenseSource.cache,
        );
      }
      return LicenseEvaluation(
        tenantId: cached.tenantId,
        status: cached.status,
        licenseType: cached.licenseType,
        canOperatePos: true,
        validUntil: cached.validUntil,
        gracePeriodEndsAt: cached.gracePeriodEndsAt,
        message: 'License valid (cached)',
        source: LicenseSource.cache,
      );
    }

    return LicenseEvaluation(
      tenantId: cached.tenantId,
      status: cached.status,
      licenseType: cached.licenseType,
      canOperatePos: true,
      message: 'POS operational — offline license cache',
      source: LicenseSource.cache,
    );
  }

  LicenseEvaluation _fromRemoteStatus({
    required LicenseStatus status,
    required String tenantId,
    String? plan,
    DateTime? validUntil,
  }) {
    final licenseType = _mapPlan(plan);
    final graceEnds = status == LicenseStatus.gracePeriod || status == LicenseStatus.expired
        ? DateTime.now().toUtc().add(defaultGracePeriod)
        : null;

    return LicenseEvaluation(
      tenantId: tenantId,
      status: status,
      licenseType: licenseType,
      canOperatePos: status != LicenseStatus.maintenance,
      validUntil: validUntil,
      gracePeriodEndsAt: graceEnds,
      message: _remoteConfig.isMaintenanceMode
          ? _remoteConfig.maintenanceMessage
          : null,
      source: LicenseSource.remote,
    );
  }

  LicenseType _mapPlan(String? plan) {
    return switch (plan) {
      'trial' => LicenseType.trial,
      'monthly' => LicenseType.monthly,
      'yearly' => LicenseType.yearly,
      'lifetime' => LicenseType.lifetime,
      _ => LicenseType.unknown,
    };
  }

  Future<void> _writeCache(LicenseEvaluation evaluation) async {
    if (evaluation.tenantId == null) return;
    final db = DatabaseInitializer.database;
    await db.licenseCacheDao.upsert(
      LicenseCacheEntriesCompanion.insert(
        tenantId: evaluation.tenantId!,
        licenseType: evaluation.licenseType.name,
        status: evaluation.status.name,
        validUntil: Value(evaluation.validUntil),
        lastValidatedAt: DateTime.now().toUtc(),
        gracePeriodEndsAt: Value(evaluation.gracePeriodEndsAt),
        payload: Value(jsonEncode({'message': evaluation.message})),
      ),
    );
  }

  Future<LicenseCacheRecord?> _readCache(String tenantId) async {
    final db = DatabaseInitializer.database;
    final row = await db.licenseCacheDao.getByTenant(tenantId);
    if (row == null) return null;
    return LicenseCacheRecord(
      tenantId: tenantId,
      licenseType: LicenseType.values.byName(row.licenseType),
      status: LicenseStatus.values.byName(row.status),
      validUntil: row.validUntil,
      lastValidatedAt: row.lastValidatedAt,
      gracePeriodEndsAt: row.gracePeriodEndsAt,
    );
  }
}

enum LicenseType { trial, monthly, yearly, lifetime, unknown }

enum LicenseSource { remote, cache, offlineFallback }

class LicenseEvaluation {
  const LicenseEvaluation({
    required this.status,
    required this.licenseType,
    required this.canOperatePos,
    required this.source,
    this.tenantId,
    this.validUntil,
    this.gracePeriodEndsAt,
    this.message,
  });

  final String? tenantId;
  final LicenseStatus status;
  final LicenseType licenseType;
  final bool canOperatePos;
  final DateTime? validUntil;
  final DateTime? gracePeriodEndsAt;
  final String? message;
  final LicenseSource source;
}

class LicenseCacheRecord {
  const LicenseCacheRecord({
    required this.tenantId,
    required this.licenseType,
    required this.status,
    required this.lastValidatedAt,
    this.validUntil,
    this.gracePeriodEndsAt,
  });

  final String tenantId;
  final LicenseType licenseType;
  final LicenseStatus status;
  final DateTime? validUntil;
  final DateTime lastValidatedAt;
  final DateTime? gracePeriodEndsAt;
}
