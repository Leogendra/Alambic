import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/application/reviews/review_service.dart';
import 'package:alambic/data/database/alambic_database.dart';
import 'package:alambic/data/repositories/card_repository.dart';
import 'package:alambic/data/repositories/preset_repository.dart';
import 'package:alambic/data/repositories/review_repository.dart';
import 'package:alambic/domain/cards/flashcard.dart';
import 'package:alambic/domain/presets/built_in_preset_key.dart';
import 'package:alambic/domain/reviews/review_outcome.dart';
import 'package:alambic/domain/reviews/review_source.dart';
import 'package:alambic/domain/scheduling/due_policy.dart';
import 'package:alambic/domain/scheduling/review_scheduler.dart';
import 'package:alambic/domain/scheduling/scheduling_calendar.dart';

import '../support/fixed_clock.dart';
import '../support/recording_schedule_listener.dart';
import '../support/sample_data.dart';
import '../support/test_database.dart';

void main() {
  late AlambicDatabase database;
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

  Future<Flashcard> front(int cardId) => cards.getCard(cardId);

  Future<int> pendingCard() async => samples.card(
    'Mongolie',
    'Oulan-Bator',
    groupId: await samples.groups.create('Capitales'),
  );

  Future<int> dueCard() async {
    final cardId = await pendingCard();
    await samples.introduceAll((await front(cardId)).groupId);
    return cardId;
  }

  test('a correct answer on a due card moves it to the next step', () async {
    final cardId = await dueCard();
    clock.now = DateTime(2026, 11, 10, 12, 5);
    final result = await reviews.answer(
      cardId,
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

  test('an adaptive card is spaced by FSRS', () async {
    final presets = PresetRepository(database);
    final adaptive = (await presets.watchAll().first).firstWhere(
      (preset) => preset.builtInKey == BuiltInPresetKey.adaptive,
    );
    await presets.setGlobalPresetId(adaptive.id);
    final cardId = await dueCard();
    clock.now = DateTime(2026, 11, 10, 12, 5);
    await reviews.answer(
      cardId,
      ReviewOutcome.correct,
      source: ReviewSource.notification,
    );
    var direction = await front(cardId);
    expect(direction.step, isNull);
    expect(direction.memory?.stability, 3.173);
    expect(direction.dueAt, DateTime(2026, 11, 13, 12));
    clock.now = DateTime(2026, 11, 13, 12, 1);
    await reviews.answer(
      direction.id,
      ReviewOutcome.correct,
      source: ReviewSource.notification,
    );
    direction = await front(cardId);
    expect(direction.memory!.stability, closeTo(10.739, 0.01));
    expect(direction.dueAt, DateTime(2026, 11, 24, 12));
    final history = await ReviewRepository(database)
        .watchHistory(direction.id)
        .first;
    expect(history.map((record) => record.dueAtAfter), [
      DateTime(2026, 11, 24, 12),
      DateTime(2026, 11, 13, 12),
    ]);
  });

  test('a change of engine starts the progression over, keeping the due date '
      'and the history', () async {
    final presets = PresetRepository(database);
    final catalog = await presets.loadCatalog();
    final adaptive = catalog.presetsById.values.firstWhere(
      (preset) => preset.builtInKey == BuiltInPresetKey.adaptive,
    );
    final cardId = await dueCard();
    Future<void> answerAt(DateTime at) async {
      clock.now = at;
      await reviews.answer(
        cardId,
        ReviewOutcome.correct,
        source: ReviewSource.session,
      );
    }

    await answerAt(DateTime(2026, 11, 10, 12, 5));
    await answerAt(DateTime(2026, 11, 11, 12, 5));
    expect((await front(cardId)).step, 1);
    expect((await front(cardId)).dueAt, DateTime(2026, 11, 13, 12));

    await presets.setGlobalPresetId(adaptive.id);
    expect((await front(cardId)).dueAt, DateTime(2026, 11, 13, 12));
    await answerAt(DateTime(2026, 11, 13, 12, 5));
    var direction = await front(cardId);
    expect(direction.step, isNull);
    expect(direction.memory?.stability, 3.173, reason: 'a first FSRS answer');
    expect(direction.dueAt, DateTime(2026, 11, 16, 12));

    await presets.setGlobalPresetId(catalog.globalPresetId);
    await answerAt(DateTime(2026, 11, 16, 12, 5));
    direction = await front(cardId);
    expect(direction.step, 0, reason: 'back to the first step');
    expect(direction.memory, isNull);
    expect(direction.dueAt, DateTime(2026, 11, 17, 12));
    final history = await ReviewRepository(database)
        .watchHistory(direction.id)
        .first;
    expect(history, hasLength(4));
  });

  test('a card due later today can be answered before its slot', () async {
    final cardId = await dueCard();
    final result = await reviews.answer(
      cardId,
      ReviewOutcome.again,
      source: ReviewSource.session,
    );
    expect(result.isBonus, isFalse);
    expect((await front(cardId)).dueAt, DateTime(2026, 11, 11, 12));
  });

  test('answering a card that is not due is a bonus review', () async {
    final cardId = await dueCard();
    final directionId = cardId;
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
    final directionId = cardId;
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

  test('answering a pending card is a bonus that leaves it pending', () async {
    final cardId = await pendingCard();
    final result = await reviews.answer(
      cardId,
      ReviewOutcome.correct,
      source: ReviewSource.session,
    );
    expect(result.isBonus, isTrue);
    expect((await front(cardId)).isPending, isTrue);
    final history = await ReviewRepository(database).watchHistory(cardId).first;
    expect(history.single.isBonus, isTrue);
  });
}
