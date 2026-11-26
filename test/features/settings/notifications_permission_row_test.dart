import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:alambic/application/notifications/notification_providers.dart';
import 'package:alambic/data/database/alambic_database.dart';
import 'package:alambic/features/settings/notification_settings_screen.dart';

import '../../support/fake_notifications.dart';
import '../../support/screen_harness.dart';
import '../../support/sample_data.dart';
import '../../support/test_database.dart';
import '../../support/test_screen.dart';

void main() {
  late AlambicDatabase database;
  late FakePresenter presenter;

  setUp(() {
    database = openTestDatabase();
    presenter = FakePresenter();
  });

  tearDown(() => closeTestDatabase(database));

  Future<void> pumpSettings(WidgetTester tester) => pumpScreen(
    tester,
    const NotificationSettingsScreen(),
    overrides: [
      ...screenOverrides(database, sampleNow),
      alarmSchedulerProvider.overrideWithValue(FakeAlarmScheduler()),
      notificationPresenterProvider.overrideWithValue(presenter),
    ],
  );

  testScreen('offers to allow notifications in the system settings when '
      'they are refused', (tester) async {
    presenter.notificationsAllowed = false;
    await pumpSettings(tester);
    await captureShot(
      tester,
      find.byType(NotificationSettingsScreen),
      'settings_notifications_off',
    );
    await expectNoOverflow(tester);
    expect(find.text(l10n.settingsNotificationsPermissionOff), findsOneWidget);
    await tester.tap(find.text(l10n.settingsPermissionAllow));
    expect(presenter.systemSettingsOpenings, 1);
  });

  testScreen('only says so once notifications are allowed', (tester) async {
    await pumpSettings(tester);
    expect(find.text(l10n.settingsNotificationsPermissionOn), findsOneWidget);
    // Exact alarms are allowed too: one check mark each, no button.
    expect(find.byIcon(Icons.check_circle), findsNWidgets(2));
    expect(find.text(l10n.settingsPermissionAllow), findsNothing);
  });
}
