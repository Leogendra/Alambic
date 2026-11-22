import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:alambic/app/alambic_app.dart';
import 'package:alambic/application/notifications/notification_providers.dart';
import 'package:alambic/application/preferences/interface_settings_providers.dart';
import 'package:alambic/data/database/alambic_database.dart';
import 'package:alambic/data/preferences/interface_settings.dart';
import 'package:alambic/data/preferences/language_choice.dart';
import 'package:alambic/data/preferences/theme_choice.dart';
import 'package:alambic/features/settings/display_panel.dart';
import 'package:alambic/l10n/generated/app_localizations.dart';

import '../../support/fake_interface_settings_store.dart';
import '../../support/fake_notifications.dart';
import '../../support/screen_harness.dart';
import '../../support/sample_data.dart';
import '../../support/test_database.dart';
import '../../support/test_screen.dart';

void main() {
  late AlambicDatabase database;
  late FakeInterfaceSettingsStore store;

  setUp(() {
    database = openTestDatabase();
    store = FakeInterfaceSettingsStore();
  });

  tearDown(() => closeTestDatabase(database));

  /// The whole app, on a phone in [phone], opened on the Settings tab.
  Future<void> pumpSettings(
    WidgetTester tester, {
    Locale phone = const Locale('en'),
  }) async {
    tester.view.physicalSize = phoneSize;
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.localesTestValue = [phone];
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...screenOverrides(database, sampleNow),
          alarmSchedulerProvider.overrideWithValue(FakeAlarmScheduler()),
          interfaceSettingsStoreProvider.overrideWithValue(store),
          initialInterfaceSettingsProvider.overrideWithValue(
            const InterfaceSettings(onboardingDone: true),
          ),
        ],
        child: const AlambicApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(lookupAppLocalizations(phone).tabSettings).last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byType(DisplayPanel));
    await tester.pumpAndSettle();
  }

  Future<void> choose(WidgetTester tester, String row, String option) async {
    await tester.tap(find.text(row));
    await tester.pumpAndSettle();
    await tester.tap(find.text(option));
    await tester.pumpAndSettle();
  }

  testScreen('follows the phone until a language is chosen', (tester) async {
    await pumpSettings(tester, phone: const Locale('fr'));
    expect(find.text('Langue du téléphone'), findsOneWidget);

    await choose(tester, 'Langue', 'English');

    expect(find.text('Settings'), findsWidgets);
    expect(find.text('Language'), findsOneWidget);
    expect(store.saved.language, LanguageChoice.english);
  });

  testScreen('goes back to the phone language once it is chosen again', (
    tester,
  ) async {
    await pumpSettings(tester);
    await choose(tester, l10n.settingsLanguage, 'Français');

    await choose(tester, 'Langue', 'Langue du téléphone');

    expect(find.text(l10n.settingsTitle), findsWidgets);
    expect(store.saved.language, LanguageChoice.system);
  });

  testScreen('switches to the dark theme at once', (tester) async {
    await pumpSettings(tester);
    expect(
      Theme.of(tester.element(find.byType(DisplayPanel))).brightness,
      Brightness.light,
    );

    await choose(tester, l10n.settingsTheme, l10n.themeDark);

    expect(
      Theme.of(tester.element(find.byType(DisplayPanel))).brightness,
      Brightness.dark,
    );
    expect(store.saved.theme, ThemeChoice.dark);
  });
}
