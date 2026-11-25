import 'package:flutter_test/flutter_test.dart';
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

  Future<void> sendTest(WidgetTester tester) async {
    await pumpScreen(
      tester,
      const NotificationSettingsScreen(),
      overrides: [
        ...screenOverrides(database, sampleNow),
        alarmSchedulerProvider.overrideWithValue(FakeAlarmScheduler()),
        notificationPresenterProvider.overrideWithValue(presenter),
      ],
    );
    expect(find.text(l10n.settingsTestNotificationHint), findsOneWidget);
    await tester.tap(find.text(l10n.testNotification));
    await tester.pumpAndSettle();
  }

  testScreen('"Test notification" shows a card notification at once, after '
      'asking for notifications', (tester) async {
    await sendTest(tester);
    expect(presenter.notificationPermissionRequests, 1);
    expect(presenter.testPrompt, (isRevealed: false, alert: true));
    expect(presenter.prompts, isEmpty);
  });

  testScreen('notifications refused, "Test notification" shows nothing', (
    tester,
  ) async {
    presenter.notificationsAllowed = false;
    await sendTest(tester);
    expect(presenter.testPrompt, isNull);
  });
}
