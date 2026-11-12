import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/application/home/today_planner.dart';
import 'package:alambic/data/database/alambic_database.dart';
import 'package:alambic/data/repositories/card_repository.dart';
import 'package:alambic/data/repositories/distillation_repository.dart';
import 'package:alambic/data/repositories/preset_repository.dart';
import 'package:alambic/data/repositories/reminder_repository.dart';
import 'package:alambic/data/repositories/review_repository.dart';
import 'package:alambic/domain/cards/direction_sense.dart';
import 'package:alambic/domain/distillation/distillation_settings.dart';
import 'package:alambic/domain/reviews/review_outcome.dart';
import 'package:alambic/domain/reviews/review_source.dart';
import 'package:alambic/domain/scheduling/clock_time.dart';
import 'package:alambic/domain/scheduling/scheduling_calendar.dart';

import '../support/fixed_clock.dart';
import '../support/sample_data.dart';
import '../support/test_database.dart';

void main() {
  late AlambicDatabase database;
  late SampleServices samples;
  late int capitals;
  const planner = TodayPlanner(SchedulingCalendar());

  setUp(() async {
    database = openTestDatabase();
    samples = SampleServices(database, FixedClock(sampleNow));
    capitals = await seedSampleData(samples);
  });

  tearDown(() => database.close());

  Future<int> firstFrontOf(int groupId) async {
    final cards = await CardRepository(database).getCardsOfGroup(groupId);
    return cards.first.direction(DirectionSense.frontToBack)!.id;
  }

  Future<dynamic> overviewAt(DateTime now) async => planner.build(
    cards: await CardRepository(database).getAll(),
    reminders: await ReminderRepository(database).getAllUpcoming(),
    reviewsToday: await ReviewRepository(database)
        .watchSince(DateTime(2026, 11, 10, 4))
        .first,
    catalog: await PresetRepository(database).loadCatalog(),
    distillationIds: {
      for (final distillation in await DistillationRepository(
        database,
      ).getAll())
        distillation.id,
    },
    dueCount: 0,
    now: now,
  );

  test('groups the reminders of the day by group and moment', () async {
    await samples.reminders.add(
      await firstFrontOf(capitals),
      DateTime(2026, 11, 10),
      const ClockTime(18, 0),
    );
    final overview = await overviewAt(sampleNow);
    final timeline = overview.timeline;
    expect(timeline.map((entry) => entry.at), [
      DateTime(2026, 11, 10, 12),
      DateTime(2026, 11, 10, 12),
      DateTime(2026, 11, 10, 12),
      DateTime(2026, 11, 10, 18),
    ]);
    expect(
      timeline.where((entry) => entry.groupId == capitals).single.count,
      4,
    );
    expect(timeline.last.isExtraReminder, isTrue);
    expect(overview.nextIndex(sampleNow), 0);
    expect(overview.nextIndex(DateTime(2026, 11, 10, 19)), isNull);
  });

  test('counts the directions answered today, bonus excluded', () async {
    final direction = await firstFrontOf(capitals);
    samples.clock.now = DateTime(2026, 11, 10, 12, 5);
    await samples.reviews.answer(
      direction,
      ReviewOutcome.correct,
      source: ReviewSource.session,
    );
    await samples.reviews.answer(
      direction,
      ReviewOutcome.correct,
      source: ReviewSource.session,
    );
    final overview = await overviewAt(samples.clock.now);
    expect(overview.doneCount, 1);
    expect(
      overview.timeline
          .where((entry) => entry.groupId == capitals)
          .single
          .count,
      3,
    );
  });

  test('the new cards of a distillation get a line of their own', () async {
    final kanji = await samples.groups.create('Kanji');
    for (final word in ['山', '川', '木']) {
      await samples.card(word, 'sens', groupId: kanji);
    }
    final distillationId = await samples.distillations.launchForGroup(
      kanji,
      DirectionSense.frontToBack,
      const DistillationSettings(cardsPerBatch: 2, avoidCollisions: false),
    );
    final overview = await overviewAt(sampleNow);
    final distilled = overview.timeline
        .where((entry) => entry.distillationId != null)
        .single;
    expect(distilled.distillationId, distillationId);
    expect(distilled.groupId, kanji);
    expect(distilled.count, 2);
    expect(distilled.at, DateTime(2026, 11, 10, 12));
  });
}
