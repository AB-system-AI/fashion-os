import 'dart:convert';

import 'package:fashion_pos_enterprise/core/infrastructure/database/database_initializer.dart';
import 'package:flutter/material.dart';

/// Runtime white-label branding loaded from local config — no source changes required.
class WhiteLabelConfig {
  const WhiteLabelConfig({
    required this.appName,
    this.logoUrl,
    this.splashImageUrl,
    this.primaryColor = const Color(0xFF1A1A2E),
    this.secondaryColor = const Color(0xFFE94560),
    this.receiptHeader,
    this.receiptFooter,
    this.supportEmail,
    this.supportPhone,
  });

  final String appName;
  final String? logoUrl;
  final String? splashImageUrl;
  final Color primaryColor;
  final Color secondaryColor;
  final String? receiptHeader;
  final String? receiptFooter;
  final String? supportEmail;
  final String? supportPhone;

  static const WhiteLabelConfig defaults = WhiteLabelConfig(appName: 'Fashion POS');

  Map<String, dynamic> toJson() => {
        'app_name': appName,
        'logo_url': logoUrl,
        'splash_image_url': splashImageUrl,
        'primary_color': primaryColor.toARGB32(),
        'secondary_color': secondaryColor.toARGB32(),
        'receipt_header': receiptHeader,
        'receipt_footer': receiptFooter,
        'support_email': supportEmail,
        'support_phone': supportPhone,
      };

  factory WhiteLabelConfig.fromJson(Map<String, dynamic> json) {
    return WhiteLabelConfig(
      appName: json['app_name'] as String? ?? defaults.appName,
      logoUrl: json['logo_url'] as String?,
      splashImageUrl: json['splash_image_url'] as String?,
      primaryColor: Color(json['primary_color'] as int? ?? defaults.primaryColor.toARGB32()),
      secondaryColor:
          Color(json['secondary_color'] as int? ?? defaults.secondaryColor.toARGB32()),
      receiptHeader: json['receipt_header'] as String?,
      receiptFooter: json['receipt_footer'] as String?,
      supportEmail: json['support_email'] as String?,
      supportPhone: json['support_phone'] as String?,
    );
  }
}

/// Loads and persists tenant-specific branding configuration.
class WhiteLabelService {
  static const String _settingsKey = 'white_label_config';

  WhiteLabelConfig _config = WhiteLabelConfig.defaults;

  WhiteLabelConfig get config => _config;

  Future<WhiteLabelConfig> load({required String tenantId}) async {
    final db = DatabaseInitializer.database;
    final value = await db.settingsDao.getValue(key: _settingsKey, tenantId: tenantId);
    if (value == null) {
      _config = WhiteLabelConfig.defaults;
      return _config;
    }
    final json = jsonDecode(value) as Map<String, dynamic>;
    _config = WhiteLabelConfig.fromJson(json);
    return _config;
  }

  Future<void> save({required String tenantId, required WhiteLabelConfig config}) async {
    final db = DatabaseInitializer.database;
    await db.settingsDao.setValue(
      key: _settingsKey,
      tenantId: tenantId,
      value: jsonEncode(config.toJson()),
    );
    _config = config;
  }

  ThemeData applyToTheme(ThemeData base) {
    return base.copyWith(
      colorScheme: base.colorScheme.copyWith(
        primary: _config.primaryColor,
        secondary: _config.secondaryColor,
      ),
    );
  }
}
