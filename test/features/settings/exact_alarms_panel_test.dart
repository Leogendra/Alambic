import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/application/notifications/notification_providers.dart';
import 'package:alambic/data/database/alambic_database.dart';
import 'package:alambic/features/settings/exact_alarms_panel.dart';
import 'package:alambic/features/settings/settings_screen.dart';

import '../../support/fake_notifications.dart';
import '../../support/golden_harness.dart';
import '../../support/sample_data.dart';
import '../../support/test_database.dart';

void main() {
  late AlambicDatabase database;
  late FakeAlarmScheduler alarms;

  setUp(() {
    database = openTestDatabase();
    alarms = FakeAlarmScheduler();
  });

  tearDown(() => database.close());

  Future<void> pumpSettings(WidgetTester tester) => pumpGolden(
    tester,
    const Scaffold(body: SafeArea(child: SettingsScreen())),
    overrides: [
      ...screenOverrides(database, sampleNow),
      alarmSchedulerProvider.overrideWithValue(alarms),
    ],
  );

  testWidgets('offers to allow exact alarms when they are refused', (
    tester,
  ) async {
    alarms.exactAllowed = false;
    await pumpSettings(tester);
    await expectLater(
      find.byType(SettingsScreen),
      matchesGoldenFile('goldens/settings_exact_alarms_off.png'),
    );
    await tester.tap(find.text('Autoriser'));
    expect(alarms.permissionRequests, 1);
  });

  testWidgets('settings in English, with the shipped preset translated', (
    tester,
  ) async {
    await pumpGolden(
      tester,
      const Scaffold(body: SafeArea(child: SettingsScreen())),
      locale: const Locale('en'),
      overrides: [
        ...screenOverrides(database, sampleNow),
        alarmSchedulerProvider.overrideWithValue(alarms),
      ],
    );
    expect(find.text('Standard'), findsOneWidget);
    await expectLater(
      find.byType(SettingsScreen),
      matchesGoldenFile('goldens/settings_english.png'),
    );
  });

  testWidgets('says reminders are on time when exact alarms are allowed', (
    tester,
  ) async {
    await pumpSettings(tester);
    expect(find.byType(ExactAlarmsPanel), findsOneWidget);
    expect(find.text('Activés'), findsOneWidget);
    expect(find.text('Autoriser'), findsNothing);
  });
}
