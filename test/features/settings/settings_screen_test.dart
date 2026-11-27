import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:alambic/application/notifications/notification_providers.dart';
import 'package:alambic/application/preferences/interface_settings_providers.dart';
import 'package:alambic/data/database/alambic_database.dart';
import 'package:alambic/data/preferences/interface_settings.dart';
import 'package:alambic/features/presets/presets_screen.dart';
import 'package:alambic/features/settings/backup_screen.dart';
import 'package:alambic/features/settings/display_settings_screen.dart';
import 'package:alambic/features/settings/notification_settings_screen.dart';
import 'package:alambic/features/settings/settings_screen.dart';
import 'package:alambic/l10n/generated/app_localizations.dart';

import '../../support/fake_app_about.dart';
import '../../support/fake_interface_settings_store.dart';
import '../../support/fake_notifications.dart';
import '../../support/sample_data.dart';
import '../../support/screen_harness.dart';
import '../../support/test_database.dart';
import '../../support/test_screen.dart';

void main() {
  late AlambicDatabase database;
  late FakeAppAbout about;
  late FakeInterfaceSettingsStore store;

  setUp(() {
    database = openTestDatabase();
    about = FakeAppAbout();
    store = FakeInterfaceSettingsStore()
      ..saved = const InterfaceSettings(onboardingDone: true);
  });

  tearDown(() => closeTestDatabase(database));

  Future<void> pumpTab(
    WidgetTester tester, {
    Brightness brightness = Brightness.light,
    Locale locale = const Locale('en'),
  }) => pumpScreen(
    tester,
    const Scaffold(body: SafeArea(child: SettingsScreen())),
    brightness: brightness,
    locale: locale,
    overrides: [
      ...screenOverrides(database, sampleNow, about: about),
      alarmSchedulerProvider.overrideWithValue(FakeAlarmScheduler()),
      interfaceSettingsStoreProvider.overrideWithValue(store),
      initialInterfaceSettingsProvider.overrideWithValue(store.saved),
    ],
  );

  for (final (locale, brightness, shot) in [
    (const Locale('en'), Brightness.light, 'settings'),
    (const Locale('en'), Brightness.dark, 'settings_dark'),
    (const Locale('fr'), Brightness.light, 'settings_french'),
    (const Locale('fr'), Brightness.dark, 'settings_french_dark'),
  ]) {
    testScreen('the tab, in $locale and ${brightness.name} theme', (
      tester,
    ) async {
      await pumpTab(tester, brightness: brightness, locale: locale);
      final strings = lookupAppLocalizations(locale);
      for (final title in [
        strings.settingsNotifications,
        strings.settingsPresets,
        strings.settingsDisplay,
        strings.settingsBackup,
        strings.settingsAboutSection.toUpperCase(),
        strings.settingsGithub,
        strings.settingsVersion('1.0.0'),
      ]) {
        expect(find.text(title), findsOneWidget);
      }
      await captureShot(tester, find.byType(SettingsScreen), shot);
      await expectNoOverflow(tester);
    });
  }

  group('a category opens its own screen', () {
    for (final (title, screen, shot) in [
      (
        l10n.settingsNotifications,
        NotificationSettingsScreen,
        'settings_notifications',
      ),
      (l10n.settingsPresets, PresetsScreen, null),
      (l10n.settingsDisplay, DisplaySettingsScreen, 'settings_display'),
      (l10n.settingsBackup, BackupScreen, 'settings_backup'),
    ]) {
      testScreen(title, (tester) async {
        await pumpTab(tester);
        await tester.tap(find.text(title));
        await tester.pumpAndSettle();
        expect(find.byType(screen), findsOneWidget);
        expect(find.byType(SettingsScreen), findsNothing);
        if (shot != null) {
          await captureShot(tester, find.byType(screen), shot);
        }
        await expectNoOverflow(tester);
      });
    }
  });

  testScreen('the repository link opens the browser', (tester) async {
    await pumpTab(tester);
    await tester.tap(find.text(l10n.settingsGithub));
    expect(about.repositoryOpened, 1);
  });

  testScreen('the onboarding is replayed from the development tools', (
    tester,
  ) async {
    await pumpTab(tester);
    expect(find.text(l10n.settingsDevelopmentSection.toUpperCase()), findsOne);
    await tester.tap(find.text(l10n.settingsReplayOnboarding));
    await tester.pump();
    expect(store.saved.onboardingDone, isFalse);
  });
}
