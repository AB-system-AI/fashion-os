import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fashion_pos_enterprise/app/localization/locale_provider.dart';
import 'package:fashion_pos_enterprise/app/pages/foundation_page.dart';
import 'package:fashion_pos_enterprise/app/theme/theme_mode_provider.dart';
import 'package:fashion_pos_enterprise/core/config/app_config.dart';
import 'package:fashion_pos_enterprise/core/config/flavor.dart';
import 'package:fashion_pos_enterprise/core/di/providers.dart';
import 'package:fashion_pos_enterprise/core/logging/log_level.dart';
import 'package:fashion_pos_enterprise/l10n/generated/app_localizations.dart';

void main() {
  testWidgets('Foundation page exposes all module entry points', (tester) async {
    const config = AppConfig(
      flavor: AppFlavor.development,
      appName: 'FashionOS',
      supabaseUrl: 'https://example.supabase.co',
      supabaseAnonKey: 'anon',
      logLevel: LogLevel.debug,
      enableAnalytics: false,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(config),
          localeProvider.overrideWith(_TestLocaleNotifier.new),
          themeModeProvider.overrideWith(_TestThemeModeNotifier.new),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const FoundationPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Foundation Ready'), findsOneWidget);
    expect(find.text('Open Product Catalog'), findsOneWidget);
    expect(find.text('Open Inventory'), findsOneWidget);
    expect(find.text('Open Purchasing'), findsOneWidget);
    expect(find.text('Open CRM'), findsOneWidget);
    expect(find.text('Open POS'), findsOneWidget);
    expect(find.text('Open Accounting'), findsOneWidget);
    expect(find.text('Open HR'), findsOneWidget);
    expect(find.text('Open Manufacturing'), findsOneWidget);
    expect(find.text('Open Analytics'), findsOneWidget);
    expect(find.text('Open Sales OMS'), findsOneWidget);
    expect(find.text('Open Treasury'), findsOneWidget);
    expect(find.text('Open System Admin'), findsOneWidget);
    expect(find.text('Open Automation'), findsOneWidget);
    expect(find.text('Open Integrations'), findsOneWidget);
    expect(find.text('Open Assets'), findsOneWidget);
    expect(find.text('Open Workflows'), findsOneWidget);
    expect(find.text('Open Admin'), findsOneWidget);
  });
}

class _TestLocaleNotifier extends LocaleNotifier {
  @override
  Locale build() => SupportedLocales.english;
}

class _TestThemeModeNotifier extends ThemeModeNotifier {
  @override
  ThemeMode build() => ThemeMode.light;
}
