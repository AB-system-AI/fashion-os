import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/features/admin/domain/entities/organization.dart';
import 'package:fashion_pos_enterprise/features/admin/domain/enums/admin_enums.dart';

mixin SettingsEntity on Equatable implements SyncableEntity {
  Map<String, dynamic> settingsBasePayload() => {
        'id': id,
        'tenant_id': tenantId,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        if (deletedAt != null) 'deleted_at': deletedAt!.toIso8601String(),
      };
}

class TenantSettings extends Equatable with SettingsEntity {
  const TenantSettings({
    required this.id,
    required this.tenantId,
    required this.values,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.scope = SettingsScope.tenant,
    this.deletedAt,
  });

  static const entityTypeName = 'admin_tenant_settings';

  @override
  final String id;
  @override
  final String tenantId;
  final SettingsScope scope;
  final Map<String, dynamic> values;
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
  Map<String, dynamic> toPayload() => {...settingsBasePayload(), 'scope': scope.value, 'values': values};

  static TenantSettings fromPayload(Map<String, dynamic> json, LocalRecord record) {
    final m = AdminEntity.mergeRecord(json, record);
    return TenantSettings(
      id: m['id'] as String,
      tenantId: m['tenant_id'] as String,
      scope: SettingsScope.fromValue(m['scope'] as String?),
      values: Map<String, dynamic>.from(m['values'] as Map? ?? {}),
      version: m['version'] as int? ?? 1,
      createdAt: DateTime.parse(m['created_at'] as String),
      updatedAt: DateTime.parse(m['updated_at'] as String),
      deletedAt: m['deleted_at'] != null ? DateTime.parse(m['deleted_at'] as String) : null,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  @override
  List<Object?> get props => [id, tenantId, scope];
}

class TenantBranding extends Equatable with SettingsEntity {
  const TenantBranding({
    required this.id,
    required this.tenantId,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.logoUrl,
    this.primaryColor,
    this.accentColor,
    this.companyName,
    this.deletedAt,
  });

  static const entityTypeName = 'admin_tenant_branding';

  @override
  final String id;
  @override
  final String tenantId;
  final String? logoUrl;
  final String? primaryColor;
  final String? accentColor;
  final String? companyName;
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
        ...settingsBasePayload(),
        'logo_url': logoUrl,
        'primary_color': primaryColor,
        'accent_color': accentColor,
        'company_name': companyName,
      };

  static TenantBranding fromPayload(Map<String, dynamic> json, LocalRecord record) {
    final m = AdminEntity.mergeRecord(json, record);
    return TenantBranding(
      id: m['id'] as String,
      tenantId: m['tenant_id'] as String,
      logoUrl: m['logo_url'] as String?,
      primaryColor: m['primary_color'] as String?,
      accentColor: m['accent_color'] as String?,
      companyName: m['company_name'] as String?,
      version: m['version'] as int? ?? 1,
      createdAt: DateTime.parse(m['created_at'] as String),
      updatedAt: DateTime.parse(m['updated_at'] as String),
      deletedAt: m['deleted_at'] != null ? DateTime.parse(m['deleted_at'] as String) : null,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  @override
  List<Object?> get props => [id, tenantId, companyName];
}

class ThemeSettings extends Equatable {
  const ThemeSettings({this.mode = 'system', this.density = 'comfortable'});
  final String mode;
  final String density;
  Map<String, dynamic> toMap() => {'mode': mode, 'density': density};
  factory ThemeSettings.fromMap(Map<String, dynamic> m) =>
      ThemeSettings(mode: m['mode'] as String? ?? 'system', density: m['density'] as String? ?? 'comfortable');
}

class LocalizationSettings extends Equatable {
  const LocalizationSettings({this.locale = 'en', this.timezone = 'UTC', this.dateFormat = 'yyyy-MM-dd'});
  final String locale;
  final String timezone;
  final String dateFormat;
  Map<String, dynamic> toMap() => {'locale': locale, 'timezone': timezone, 'date_format': dateFormat};
  factory LocalizationSettings.fromMap(Map<String, dynamic> m) => LocalizationSettings(
        locale: m['locale'] as String? ?? 'en',
        timezone: m['timezone'] as String? ?? 'UTC',
        dateFormat: m['date_format'] as String? ?? 'yyyy-MM-dd',
      );
}

class CurrencySettings extends Equatable {
  const CurrencySettings({this.baseCurrency = 'USD', this.decimalPlaces = 2});
  final String baseCurrency;
  final int decimalPlaces;
  Map<String, dynamic> toMap() => {'base_currency': baseCurrency, 'decimal_places': decimalPlaces};
  factory CurrencySettings.fromMap(Map<String, dynamic> m) => CurrencySettings(
        baseCurrency: m['base_currency'] as String? ?? 'USD',
        decimalPlaces: m['decimal_places'] as int? ?? 2,
      );
}

class RegionalSettings extends Equatable {
  const RegionalSettings({this.country = 'US', this.region = ''});
  final String country;
  final String region;
  Map<String, dynamic> toMap() => {'country': country, 'region': region};
  factory RegionalSettings.fromMap(Map<String, dynamic> m) =>
      RegionalSettings(country: m['country'] as String? ?? 'US', region: m['region'] as String? ?? '');
}

class FiscalSettings extends Equatable {
  const FiscalSettings({this.fiscalYearStartMonth = 1, this.taxInclusive = false});
  final int fiscalYearStartMonth;
  final bool taxInclusive;
  Map<String, dynamic> toMap() => {'fiscal_year_start_month': fiscalYearStartMonth, 'tax_inclusive': taxInclusive};
  factory FiscalSettings.fromMap(Map<String, dynamic> m) => FiscalSettings(
        fiscalYearStartMonth: m['fiscal_year_start_month'] as int? ?? 1,
        taxInclusive: m['tax_inclusive'] as bool? ?? false,
      );
}

class NumberingSettings extends Equatable {
  const NumberingSettings({this.prefix = 'INV', this.padding = 6});
  final String prefix;
  final int padding;
  Map<String, dynamic> toMap() => {'prefix': prefix, 'padding': padding};
  factory NumberingSettings.fromMap(Map<String, dynamic> m) =>
      NumberingSettings(prefix: m['prefix'] as String? ?? 'INV', padding: m['padding'] as int? ?? 6);
}

class EmailSettings extends Equatable {
  const EmailSettings({this.fromAddress = '', this.replyTo = ''});
  final String fromAddress;
  final String replyTo;
  Map<String, dynamic> toMap() => {'from_address': fromAddress, 'reply_to': replyTo};
  factory EmailSettings.fromMap(Map<String, dynamic> m) => EmailSettings(
        fromAddress: m['from_address'] as String? ?? '',
        replyTo: m['reply_to'] as String? ?? '',
      );
}

class SmsSettings extends Equatable {
  const SmsSettings({this.provider = '', this.senderId = ''});
  final String provider;
  final String senderId;
  Map<String, dynamic> toMap() => {'provider': provider, 'sender_id': senderId};
  factory SmsSettings.fromMap(Map<String, dynamic> m) =>
      SmsSettings(provider: m['provider'] as String? ?? '', senderId: m['sender_id'] as String? ?? '');
}

class NotificationSettings extends Equatable {
  const NotificationSettings({this.emailEnabled = true, this.smsEnabled = false, this.pushEnabled = true});
  final bool emailEnabled;
  final bool smsEnabled;
  final bool pushEnabled;
  Map<String, dynamic> toMap() =>
      {'email_enabled': emailEnabled, 'sms_enabled': smsEnabled, 'push_enabled': pushEnabled};
  factory NotificationSettings.fromMap(Map<String, dynamic> m) => NotificationSettings(
        emailEnabled: m['email_enabled'] as bool? ?? true,
        smsEnabled: m['sms_enabled'] as bool? ?? false,
        pushEnabled: m['push_enabled'] as bool? ?? true,
      );
}

class SecuritySettings extends Equatable {
  const SecuritySettings({this.mfaRequired = false, this.sessionTimeoutMinutes = 60});
  final bool mfaRequired;
  final int sessionTimeoutMinutes;
  Map<String, dynamic> toMap() => {'mfa_required': mfaRequired, 'session_timeout_minutes': sessionTimeoutMinutes};
  factory SecuritySettings.fromMap(Map<String, dynamic> m) => SecuritySettings(
        mfaRequired: m['mfa_required'] as bool? ?? false,
        sessionTimeoutMinutes: m['session_timeout_minutes'] as int? ?? 60,
      );
}

class EnterpriseSettings extends Equatable with SettingsEntity {
  const EnterpriseSettings({
    required this.id,
    required this.tenantId,
    required this.config,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.deletedAt,
  });

  static const entityTypeName = 'admin_enterprise_config';

  @override
  final String id;
  @override
  final String tenantId;
  final Map<String, dynamic> config;
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
  Map<String, dynamic> toPayload() => {...settingsBasePayload(), 'config': config};

  static EnterpriseSettings fromPayload(Map<String, dynamic> json, LocalRecord record) {
    final m = AdminEntity.mergeRecord(json, record);
    return EnterpriseSettings(
      id: m['id'] as String,
      tenantId: m['tenant_id'] as String,
      config: Map<String, dynamic>.from(m['config'] as Map? ?? {}),
      version: m['version'] as int? ?? 1,
      createdAt: DateTime.parse(m['created_at'] as String),
      updatedAt: DateTime.parse(m['updated_at'] as String),
      deletedAt: m['deleted_at'] != null ? DateTime.parse(m['deleted_at'] as String) : null,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  @override
  List<Object?> get props => [id, tenantId];
}
