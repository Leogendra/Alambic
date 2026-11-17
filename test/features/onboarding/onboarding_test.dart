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
import 'package:alambic/data/repositories/group_repository.dart';
import 'package:alambic/features/groups/group_detail_screen.dart';
import 'package:alambic/features/onboarding/onboarding_screen.dart';

import '../../support/fake_interface_settings_store.dart';
import '../../support/fake_notifications.dart';
import '../../support/fixed_clock.dart';
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
    Locale locale = const Locale('fr'),
  }) async {
    tester.view.physicalSize = phoneSize;
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.localesTestValue = [locale];
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

  Future<void> reachSampleGroup(WidgetTester tester) async {
    await tapAndSettle(tester, find.text('Commencer'));
    await tapAndSettle(tester, find.text('Continuer'));
    // The sample cards are read from the assets.
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pumpAndSettle();
  }

  /// Ends the onboarding with [button], once the group is stored.
  Future<void> finishWith(WidgetTester tester, String button) async {
    await tester.tap(find.text(button));
    for (var wait = 0; wait < 100 && !store.saved.onboardingDone; wait++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 10)),
      );
      await tester.pump();
    }
    await tester.pumpAndSettle();
  }

  Future<List<String>> groupNames(WidgetTester tester) async {
    final groups = await tester.runAsync(
      () => GroupRepository(database).watchAll().first,
    );
    return [for (final group in groups!) group.name];
  }

  testWidgets('going through the three screens asks the permissions, creates '
      'the sample group, then opens it', (tester) async {
    await pumpApp(tester);
    await tapAndSettle(tester, find.text('Commencer'));

    await tapAndSettle(tester, find.text('Autoriser').first);
    expect(presenter.notificationPermissionRequests, 1);
    await tapAndSettle(tester, find.text('Autoriser'));
    expect(alarms.permissionRequests, 1);
    await tapAndSettle(tester, find.text('Continuer'));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Alphabet OTAN'), findsOneWidget);
    expect(find.text('26 cartes'), findsOneWidget);
    await finishWith(tester, 'Commencer');

    expect(await groupNames(tester), ['Alphabet OTAN']);
    final cards = await tester.runAsync(
      () => CardRepository(database).getAll(),
    );
    expect(cards, hasLength(26));
    expect(cards!.every((card) => card.isPending), isTrue);
    expect(store.saved.onboardingDone, isTrue);
    expect(find.byType(GroupDetailScreen), findsOneWidget);
    expect(
      find.text('Ses cartes attendent. Distille le groupe pour les recevoir.'),
      findsOneWidget,
    );
  });

  testWidgets('"Skip" opens the tabs, the sample group created all the same', (
    tester,
  ) async {
    await pumpApp(tester);
    await reachSampleGroup(tester);
    await finishWith(tester, 'Passer');

    expect(await groupNames(tester), ['Alphabet OTAN']);
    expect(store.saved.onboardingDone, isTrue);
    expect(find.byType(MainShell), findsOneWidget);
    expect(find.byType(GroupDetailScreen), findsNothing);
  });

  testWidgets('in English, the sample group is the NATO alphabet', (
    tester,
  ) async {
    await pumpApp(tester, locale: const Locale('en'));
    await tapAndSettle(tester, find.text('Get started'));
    await tapAndSettle(tester, find.text('Continue'));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pumpAndSettle();
    await finishWith(tester, 'Skip');

    expect(await groupNames(tester), ['NATO alphabet']);
  });

  testWidgets('the sample group is created once: a later launch, even after '
      'its deletion, does not create it again', (tester) async {
    await pumpApp(tester);
    await reachSampleGroup(tester);
    await finishWith(tester, 'Passer');
    final groupId = (await tester.runAsync(
      () => GroupRepository(database).watchAll().first,
    ))!.single.id;
    await tester.runAsync(
      () => SampleServices(
        database,
        FixedClock(sampleNow),
      ).groups.delete(groupId),
    );

    await pumpApp(tester, onboardingDone: store.saved.onboardingDone);
    expect(find.byType(MainShell), findsOneWidget);
    expect(await groupNames(tester), isEmpty);
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
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(OnboardingScreen),
      matchesGoldenFile('goldens/onboarding_sample_group.png'),
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
