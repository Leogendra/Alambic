import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/application/notifications/notification_settings_service.dart';
import 'package:alambic/application/scheduling/ignored_schedule_changes.dart';
import 'package:alambic/data/database/alambic_database.dart';
import 'package:alambic/data/repositories/card_repository.dart';
import 'package:alambic/data/repositories/notification_settings_repository.dart';
import 'package:alambic/domain/notifications/grouped_reminder_action.dart';
import 'package:alambic/domain/notifications/notification_mode.dart';
import 'package:alambic/domain/notifications/reminder_settings.dart';
import 'package:alambic/domain/notifications/schedule_kind.dart';
import 'package:alambic/domain/reviews/review_outcome.dart';
import 'package:alambic/domain/reviews/review_source.dart';
import 'package:alambic/domain/scheduling/clock_time.dart';
import 'package:alambic/domain/scheduling/daily_slot_move.dart';
import 'package:alambic/domain/scheduling/scheduling_calendar.dart';

import '../support/fixed_clock.dart';
import '../support/sample_data.dart';
import '../support/test_database.dart';

void main() {
  late AlambicDatabase database;
  late FixedClock clock;
  late NotificationSettingsRepository settings;
  late NotificationSettingsService service;

  setUp(() {
    database = openTestDatabase();
    clock = FixedClock(sampleNow);
    settings = NotificationSettingsRepository(database);
    service = NotificationSettingsService(
      settings: settings,
      cards: CardRepository(database),
      slotMove: const DailySlotMove(SchedulingCalendar()),
      clock: clock.call,
      scheduleChangeListener: const IgnoredScheduleChanges(),
    );
  });

  tearDown(() => database.close());

  test('a fresh database notifies one card at a time at 12:00', () async {
    final reminders = await settings.loadReminderSettings();
    expect(reminders, ReminderSettings.defaults);
    expect(reminders.scheduleKind, ScheduleKind.fixedTime);
    expect(reminders.fixedTime, const ClockTime(12, 0));
    expect(reminders.notificationMode, NotificationMode.perCard);
    expect(reminders.groupedAction, GroupedReminderAction.openApp);
  });

  test('the onboarding time becomes the fixed time of the app', () async {
    await service.saveReminderSettings(
      ReminderSettings.defaults.copyWith(scheduleKind: ScheduleKind.timeRange),
    );
    await service.setFixedTime(const ClockTime(8, 30));
    final reminders = await settings.loadReminderSettings();
    expect(reminders.scheduleKind, ScheduleKind.fixedTime);
    expect(reminders.fixedTime, const ClockTime(8, 30));
  });

  test('every group takes the schedule of the app', () async {
    final samples = SampleServices(database, clock);
    await service.setFixedTime(const ClockTime(18, 0));
    final capitals = await samples.groups.create('Capitales');
    final cardId = await samples.card('Pérou', 'Lima', groupId: capitals);
    await samples.introduceAll(capitals);
    expect(
      (await CardRepository(database).getCard(cardId)).dueAt,
      DateTime(2026, 11, 10, 18),
    );
    await samples.reviews.answer(
      cardId,
      ReviewOutcome.correct,
      source: ReviewSource.session,
    );
    expect(
      (await CardRepository(database).getCard(cardId)).dueAt,
      DateTime(2026, 11, 11, 18),
    );
  });

  test('a new slot moves the due dates set at the old one', () async {
    final samples = SampleServices(database, clock);
    final capitals = await samples.groups.create('Capitales');
    final cardId = await samples.card('Pérou', 'Lima', groupId: capitals);
    await samples.introduceAll(capitals);
    await service.saveReminderSettings(
      ReminderSettings.defaults.copyWith(
        scheduleKind: ScheduleKind.timeRange,
        rangeStart: const ClockTime(10, 0),
        rangeEnd: const ClockTime(20, 0),
      ),
    );
    expect(
      (await CardRepository(database).getCard(cardId)).dueAt,
      DateTime(2026, 11, 10, 10),
    );
  });

  test('a range whose end precedes its start is refused', () async {
    final before = await settings.loadReminderSettings();
    await expectLater(
      service.saveReminderSettings(
        before.copyWith(
          scheduleKind: ScheduleKind.timeRange,
          rangeStart: const ClockTime(18, 0),
          rangeEnd: const ClockTime(9, 0),
        ),
      ),
      throwsArgumentError,
    );
    expect(await settings.loadReminderSettings(), before);
  });
}
