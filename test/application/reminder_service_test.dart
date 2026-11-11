import 'package:flutter_test/flutter_test.dart';
import 'package:remanence/application/reminders/reminder_service.dart';
import 'package:remanence/data/database/remanence_database.dart';
import 'package:remanence/data/repositories/card_repository.dart';
import 'package:remanence/data/repositories/reminder_repository.dart';
import 'package:remanence/domain/scheduling/clock_time.dart';
import 'package:remanence/domain/scheduling/scheduling_calendar.dart';

import '../support/fixed_clock.dart';
import '../support/recording_schedule_listener.dart';
import '../support/sample_data.dart';
import '../support/test_database.dart';

void main() {
  late RemanenceDatabase database;
  late SampleServices samples;
  late ReminderRepository repository;
  late ReminderService service;
  late RecordingScheduleListener listener;
  late int directionId;

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
    final cardId = await samples.card('Mongolie', 'Oulan-Bator');
    directionId = (await CardRepository(database).getDirections(cardId))
        .first
        .id;
  });

  tearDown(() => database.close());

  test('adds a reminder on a day at a time', () async {
    await service.add(
      directionId,
      DateTime(2026, 11, 12),
      const ClockTime(18, 30),
    );
    final upcoming = await repository.watchUpcoming(directionId).first;
    expect(upcoming.single.remindAt, DateTime(2026, 11, 12, 18, 30));
    expect(listener.changeCount, 1);
  });

  test('refuses a moment already past', () {
    expect(
      () => service.add(
        directionId,
        DateTime(2026, 11, 10),
        const ClockTime(8, 0),
      ),
      throwsArgumentError,
    );
  });

  test('removes a reminder', () async {
    final id = await service.add(
      directionId,
      DateTime(2026, 11, 12),
      const ClockTime(12, 0),
    );
    await service.remove(id);
    expect(await repository.watchUpcoming(directionId).first, isEmpty);
    expect(listener.changeCount, 2);
  });
}
