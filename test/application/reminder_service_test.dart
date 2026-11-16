import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/application/reminders/reminder_service.dart';
import 'package:alambic/data/database/alambic_database.dart';
import 'package:alambic/data/repositories/reminder_repository.dart';
import 'package:alambic/domain/scheduling/clock_time.dart';
import 'package:alambic/domain/scheduling/scheduling_calendar.dart';

import '../support/fixed_clock.dart';
import '../support/recording_schedule_listener.dart';
import '../support/sample_data.dart';
import '../support/test_database.dart';

void main() {
  late AlambicDatabase database;
  late SampleServices samples;
  late ReminderRepository repository;
  late ReminderService service;
  late RecordingScheduleListener listener;
  late int cardId;

  setUp(() async {
    database = openTestDatabase();
    final clock = FixedClock(sampleNow);
    samples = SampleServices(database, clock);
    repository = ReminderRepository(database);
    listener = RecordingScheduleListener();
    service = ReminderService(
      reminders: repository,
      calendar: const SchedulingCalendar(),
      clock: clock.call,
      scheduleChangeListener: listener,
    );
    cardId = await samples.card(
      'Mongolie',
      'Oulan-Bator',
      groupId: await samples.groups.create('Capitales'),
    );
  });

  tearDown(() => database.close());

  test('adds a reminder on a day at a time', () async {
    await service.add(cardId, DateTime(2026, 11, 12), const ClockTime(18, 30));
    final upcoming = await repository.watchUpcoming(cardId).first;
    expect(upcoming.single.remindAt, DateTime(2026, 11, 12, 18, 30));
    expect(listener.changeCount, 1);
  });

  test('refuses a moment already past', () {
    expect(
      () => service.add(cardId, DateTime(2026, 11, 10), const ClockTime(8, 0)),
      throwsArgumentError,
    );
  });

  test('removes a reminder', () async {
    final id = await service.add(
      cardId,
      DateTime(2026, 11, 12),
      const ClockTime(12, 0),
    );
    await service.remove(id);
    expect(await repository.watchUpcoming(cardId).first, isEmpty);
    expect(listener.changeCount, 2);
  });
}
