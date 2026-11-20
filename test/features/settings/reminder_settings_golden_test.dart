import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/data/database/alambic_database.dart';
import 'package:alambic/data/repositories/notification_settings_repository.dart';
import 'package:alambic/domain/notifications/grouped_reminder_action.dart';
import 'package:alambic/domain/notifications/notification_mode.dart';
import 'package:alambic/domain/notifications/reminder_settings.dart';
import 'package:alambic/domain/notifications/schedule_kind.dart';
import 'package:alambic/domain/scheduling/clock_time.dart';
import 'package:alambic/features/settings/notification_mode_screen.dart';
import 'package:alambic/features/settings/reminder_schedule_screen.dart';

import '../../support/golden_harness.dart';
import '../../support/sample_data.dart';
import '../../support/test_database.dart';

void main() {
  late AlambicDatabase database;

  setUp(() => database = openTestDatabase());
  tearDown(() => database.close());

  Future<ReminderSettings?> stored(WidgetTester tester) => tester.runAsync(
    () => NotificationSettingsRepository(database).loadReminderSettings(),
  );

  testWidgets('the schedule switches to a time range, dark theme', (
    tester,
  ) async {
    await pumpGolden(
      tester,
      const ReminderScheduleScreen(),
      brightness: Brightness.dark,
      overrides: screenOverrides(database, sampleNow),
      locale: const Locale('fr'),
    );
    await expectLater(
      find.byType(ReminderScheduleScreen),
      matchesGoldenFile('goldens/schedule_fixed_dark.png'),
    );
    await tester.runAsync(() async {
      await tester.tap(find.text('Plage'));
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();
    expect((await stored(tester))!.scheduleKind, ScheduleKind.timeRange);
    await expectLater(
      find.byType(ReminderScheduleScreen),
      matchesGoldenFile('goldens/schedule_range_dark.png'),
    );
  });

  testWidgets('an end before the start of the range is refused', (
    tester,
  ) async {
    await tester.runAsync(
      () => NotificationSettingsRepository(database).saveReminderSettings(
        ReminderSettings.defaults.copyWith(
          scheduleKind: ScheduleKind.timeRange,
          rangeStart: const ClockTime(9, 0),
          rangeEnd: const ClockTime(10, 0),
        ),
      ),
    );
    await pumpGolden(
      tester,
      const ReminderScheduleScreen(),
      overrides: screenOverrides(database, sampleNow),
      locale: const Locale('fr'),
    );
    Future<void> pickEnd(String hour) async {
      await tester.tap(find.text('Fin'));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.keyboard_outlined));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, hour);
      await tester.enterText(find.byType(TextField).last, '00');
      await tester.tap(find.text('OK'));
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pumpAndSettle();
    }

    // The picked hours read the same with a 12-hour or a 24-hour picker:
    // the range sits in the morning.
    await pickEnd('8');
    expect(
      find.text('La fin de la plage ne peut pas précéder son début.'),
      findsOneWidget,
    );
    expect((await stored(tester))!.rangeEnd, const ClockTime(10, 0));

    await pickEnd('11');
    expect((await stored(tester))!.rangeEnd, const ClockTime(11, 0));
  });

  testWidgets('the grouped reminder offers to open the app or chain', (
    tester,
  ) async {
    await pumpGolden(
      tester,
      const NotificationModeScreen(),
      brightness: Brightness.dark,
      overrides: screenOverrides(database, sampleNow),
      locale: const Locale('fr'),
    );
    expect(find.text('Au tap sur le rappel'.toUpperCase()), findsNothing);
    await tester.runAsync(() async {
      await tester.tap(find.text('Rappel groupé'));
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      await tester.tap(find.text('Enchaîner'));
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();
    final reminders = (await stored(tester))!;
    expect(reminders.notificationMode, NotificationMode.grouped);
    expect(reminders.groupedAction, GroupedReminderAction.chainInNotification);
    await expectLater(
      find.byType(NotificationModeScreen),
      matchesGoldenFile('goldens/notification_mode_dark.png'),
    );
  });
}
