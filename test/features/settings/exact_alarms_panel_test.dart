import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/application/notifications/notification_providers.dart';
import 'package:alambic/data/database/alambic_database.dart';
import 'package:alambic/features/settings/exact_alarms_panel.dart';
import 'package:alambic/features/settings/notification_settings_screen.dart';

import '../../support/fake_notifications.dart';
import '../../support/screen_harness.dart';
import '../../support/sample_data.dart';
import '../../support/test_database.dart';
import '../../support/test_screen.dart';

void main() {
  late AlambicDatabase database;
  late FakeAlarmScheduler alarms;

  setUp(() {
    database = openTestDatabase();
    alarms = FakeAlarmScheduler();
  });

  tearDown(() => closeTestDatabase(database));

  Future<void> pumpSettings(WidgetTester tester) => pumpScreen(
    tester,
    const NotificationSettingsScreen(),
    overrides: [
      ...screenOverrides(database, sampleNow),
      alarmSchedulerProvider.overrideWithValue(alarms),
    ],
  );

  testScreen('offers to allow exact alarms when they are refused', (
    tester,
  ) async {
    alarms.exactAllowed = false;
    await pumpSettings(tester);
    await captureShot(
      tester,
      find.byType(NotificationSettingsScreen),
      'settings_exact_alarms_off',
    );
    await expectNoOverflow(tester);
    await tester.tap(find.text(l10n.settingsExactAlarmsAllow));
    expect(alarms.permissionRequests, 1);
  });

  testScreen('says reminders are on time when exact alarms are allowed', (
    tester,
  ) async {
    await pumpSettings(tester);
    expect(find.byType(ExactAlarmsPanel), findsOneWidget);
    expect(find.text('On'), findsOneWidget);
    expect(find.text('Allow'), findsNothing);
  });
}
