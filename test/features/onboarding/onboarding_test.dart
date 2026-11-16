import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/app/alambic_app.dart';
import 'package:alambic/app/shell/main_shell.dart';
import 'package:alambic/application/notifications/notification_providers.dart';
import 'package:alambic/application/preferences/interface_settings_providers.dart';
import 'package:alambic/data/database/alambic_database.dart';
import 'package:alambic/data/preferences/interface_settings.dart';
import 'package:alambic/data/repositories/card_repository.dart';
import 'package:alambic/features/onboarding/onboarding_screen.dart';

import '../../support/fake_interface_settings_store.dart';
import '../../support/fake_notifications.dart';
import '../../support/golden_harness.dart';
import '../../support/sample_data.dart';
import '../../support/test_database.dart';

void main() {
  late AlambicDatabase database;
  late FakeAlarmScheduler alarms;
  late FakePresenter presenter;
  late FakeInterfaceSettingsStore store;

  setUp(() {
    database = openTestDatabase();
    alarms = FakeAlarmScheduler()..exactAllowed = false;
    presenter = FakePresenter();
    store = FakeInterfaceSettingsStore();
  });

  tearDown(() => database.close());

  List<Override> overrides({bool onboardingDone = false}) => [
    ...screenOverrides(database, sampleNow),
    alarmSchedulerProvider.overrideWithValue(alarms),
    notificationPresenterProvider.overrideWithValue(presenter),
    interfaceSettingsStoreProvider.overrideWithValue(store),
    initialInterfaceSettingsProvider.overrideWithValue(
      InterfaceSettings(onboardingDone: onboardingDone),
    ),
  ];

  Future<void> pumpApp(
    WidgetTester tester, {
    bool onboardingDone = false,
  }) async {
    tester.view.physicalSize = phoneSize;
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.localesTestValue = const [Locale('fr')];
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides(onboardingDone: onboardingDone),
        child: const AlambicApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  testWidgets('the first launch opens on the welcome screens', (tester) async {
    await pumpApp(tester);
    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.byType(MainShell), findsNothing);
  });

  testWidgets('a launch after the onboarding opens on the tabs', (
    tester,
  ) async {
    await pumpApp(tester, onboardingDone: true);
    expect(find.byType(MainShell), findsOneWidget);
  });

  testWidgets('going through the three screens creates a started first card', (
    tester,
  ) async {
    await pumpApp(tester);
    await tapAndSettle(tester, find.text('Commencer'));

    await tapAndSettle(tester, find.text('Autoriser').first);
    expect(presenter.notificationPermissionRequests, 1);
    await tapAndSettle(tester, find.text('Autoriser'));
    expect(alarms.permissionRequests, 1);
    await tapAndSettle(tester, find.text('Continuer'));

    await tester.enterText(find.byType(TextField).at(0), 'Capitales');
    await tester.enterText(find.byType(TextField).at(1), 'Capitale du Pérou');
    await tester.enterText(find.byType(TextField).at(2), 'Lima');
    await tester.pump();
    await tapAndSettle(tester, find.text('Créer et commencer'));

    final cards = await CardRepository(database).getAll();
    expect(cards, hasLength(1));
    expect(cards.single.frontText, 'Capitale du Pérou');
    expect(cards.single.isPending, isTrue);
    expect(store.saved.onboardingDone, isTrue);
    expect(find.byType(MainShell), findsOneWidget);
  });

  testWidgets('the first card can be skipped', (tester) async {
    await pumpApp(tester);
    await tapAndSettle(tester, find.text('Commencer'));
    await tapAndSettle(tester, find.text('Continuer'));
    await tapAndSettle(tester, find.text('Passer'));

    expect(await CardRepository(database).getAll(), isEmpty);
    expect(store.saved.onboardingDone, isTrue);
    expect(find.byType(MainShell), findsOneWidget);
  });

  testWidgets('the welcome screens', (tester) async {
    await pumpGolden(tester, const OnboardingScreen(), overrides: overrides());
    await expectLater(
      find.byType(OnboardingScreen),
      matchesGoldenFile('goldens/onboarding_welcome.png'),
    );
    await tapAndSettle(tester, find.text('Commencer'));
    await expectLater(
      find.byType(OnboardingScreen),
      matchesGoldenFile('goldens/onboarding_permissions.png'),
    );
    await tapAndSettle(tester, find.text('Continuer'));
    await expectLater(
      find.byType(OnboardingScreen),
      matchesGoldenFile('goldens/onboarding_first_card.png'),
    );
  });

  testWidgets('the reminders screen in English', (tester) async {
    await pumpGolden(
      tester,
      const OnboardingScreen(),
      locale: const Locale('en'),
      overrides: overrides(),
    );
    await tapAndSettle(tester, find.text('Get started'));
    await expectLater(
      find.byType(OnboardingScreen),
      matchesGoldenFile('goldens/onboarding_permissions_english.png'),
    );
  });

  testWidgets('the welcome screen in dark theme', (tester) async {
    await pumpGolden(
      tester,
      const OnboardingScreen(),
      brightness: Brightness.dark,
      overrides: overrides(),
    );
    await expectLater(
      find.byType(OnboardingScreen),
      matchesGoldenFile('goldens/onboarding_welcome_dark.png'),
    );
  });
}
