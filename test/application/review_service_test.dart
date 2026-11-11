import 'package:flutter_test/flutter_test.dart';
import 'package:remanence/application/reviews/review_service.dart';
import 'package:remanence/data/database/remanence_database.dart';
import 'package:remanence/data/repositories/card_repository.dart';
import 'package:remanence/data/repositories/preset_repository.dart';
import 'package:remanence/data/repositories/review_repository.dart';
import 'package:remanence/domain/cards/card_direction.dart';
import 'package:remanence/domain/cards/direction_sense.dart';
import 'package:remanence/domain/reviews/review_outcome.dart';
import 'package:remanence/domain/reviews/review_source.dart';
import 'package:remanence/domain/scheduling/due_policy.dart';
import 'package:remanence/domain/scheduling/review_scheduler.dart';
import 'package:remanence/domain/scheduling/scheduling_calendar.dart';

import '../support/fixed_clock.dart';
import '../support/recording_schedule_listener.dart';
import '../support/sample_data.dart';
import '../support/test_database.dart';

void main() {
  late RemanenceDatabase database;
  late FixedClock clock;
  late SampleServices samples;
  late ReviewService reviews;
  late RecordingScheduleListener listener;
  late CardRepository cards;

  setUp(() {
    database = openTestDatabase();
    clock = FixedClock(sampleNow);
    samples = SampleServices(database, clock);
    listener = RecordingScheduleListener();
    cards = CardRepository(database);
    reviews = ReviewService(
      cards: cards,
      presets: PresetRepository(database),
      reviews: ReviewRepository(database),
      scheduler: const ReviewScheduler(SchedulingCalendar()),
      duePolicy: const DuePolicy(SchedulingCalendar()),
      clock: clock.call,
      scheduleChangeListener: listener,
    );
  });

  tearDown(() => database.close());

  Future<CardDirection> front(int cardId) async => (await cards.getDirections(
    cardId,
  )).firstWhere((direction) => direction.sense == DirectionSense.frontToBack);

  Future<int> dueCard() async {
    final cardId = await samples.card('Mongolie', 'Oulan-Bator');
    await samples.cards.startGroup(null);
    return cardId;
  }

  test('a correct answer on a due card moves it to the next step', () async {
    final cardId = await dueCard();
    clock.now = DateTime(2026, 11, 10, 12, 5);
    final result = await reviews.answer(
      (await front(cardId)).id,
      ReviewOutcome.correct,
      source: ReviewSource.session,
    );
    final direction = await front(cardId);
    expect(result.isBonus, isFalse);
    expect(direction.step, 0);
    expect(direction.dueAt, DateTime(2026, 11, 11, 12));
    expect(direction.lastReviewedAt, DateTime(2026, 11, 10, 12, 5));
    expect(listener.changeCount, 1);
    final history = await ReviewRepository(database)
        .watchHistory(direction.id)
        .first;
    expect(history.single.isBonus, isFalse);
    expect(history.single.stepBefore, isNull);
    expect(history.single.stepAfter, 0);
  });

  test('a card due later today can be answered before its slot', () async {
    final cardId = await dueCard();
    final result = await reviews.answer(
      (await front(cardId)).id,
      ReviewOutcome.again,
      source: ReviewSource.session,
    );
    expect(result.isBonus, isFalse);
    expect((await front(cardId)).dueAt, DateTime(2026, 11, 11, 12));
  });

  test('answering a card that is not due is a bonus review', () async {
    final cardId = await dueCard();
    final directionId = (await front(cardId)).id;
    await reviews.answer(
      directionId,
      ReviewOutcome.correct,
      source: ReviewSource.session,
    );
    final before = await front(cardId);
    final result = await reviews.answer(
      directionId,
      ReviewOutcome.again,
      source: ReviewSource.session,
    );
    final after = await front(cardId);
    expect(result.isBonus, isTrue);
    expect(after.step, before.step);
    expect(after.dueAt, before.dueAt);
    final history = await ReviewRepository(database)
        .watchHistory(directionId)
        .first;
    expect(history.first.isBonus, isTrue);
    expect(listener.changeCount, 1);
  });

  test('a forced bonus answer leaves a due card due', () async {
    final cardId = await dueCard();
    final before = await front(cardId);
    final result = await reviews.answer(
      before.id,
      ReviewOutcome.again,
      source: ReviewSource.session,
      forceBonus: true,
    );
    expect(result.isBonus, isTrue);
    expect((await front(cardId)).dueAt, before.dueAt);
  });

  test('the preview matches what the answer then records', () async {
    final cardId = await dueCard();
    final directionId = (await front(cardId)).id;
    final preview = await reviews.preview(directionId);
    expect(preview.correct!.dueAt, DateTime(2026, 11, 11, 12));
    expect(preview.again!.dueAt, DateTime(2026, 11, 11, 12));
    await reviews.answer(
      directionId,
      ReviewOutcome.correct,
      source: ReviewSource.session,
    );
    expect((await reviews.preview(directionId)).isBonus, isTrue);
  });
}
