import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/data/database/alambic_database.dart';
import 'package:alambic/data/repositories/card_repository.dart';
import 'package:alambic/domain/cards/card_state.dart';
import 'package:alambic/domain/distillation/distillation_settings.dart';
import 'package:alambic/domain/reviews/review_outcome.dart';
import 'package:alambic/domain/reviews/review_source.dart';
import 'package:alambic/domain/scheduling/card_schedule.dart';

import '../support/fixed_clock.dart';
import '../support/sample_data.dart';
import '../support/test_database.dart';

/// "Prioritize reviews": on a batch day, each card of the group due at the
/// pass takes the place of a new card; reminders are never moved.
void main() {
  late AlambicDatabase database;
  late FixedClock clock;
  late SampleServices services;
  late CardRepository cards;
  late int groupId;
  late List<int> cardIds;

  setUp(() async {
    database = openTestDatabase();
    clock = FixedClock(DateTime(2026, 11, 10, 9));
    services = SampleServices(database, clock);
    cards = CardRepository(database);
    groupId = await services.groups.create('Capitals');
    cardIds = [
      for (var index = 0; index < 8; index++)
        await services.card('Pays $index', 'Capitale $index', groupId: groupId),
    ];
  });

  tearDown(() => database.close());

  Future<List<int>> introduced() async => [
    for (final (index, cardId) in cardIds.indexed)
      if (!(await cards.getCard(cardId)).isPending) index,
  ];

  Future<void> answer(int index, ReviewOutcome outcome) => services.reviews
      .answer(cardIds[index], outcome, source: ReviewSource.session);

  /// Puts card [index] in review, due at noon on [dueDay], as if it had been
  /// answered on [reviewedDay].
  Future<void> schedule(int index, DateTime dueDay, DateTime reviewedDay) =>
      cards.applySchedule(
        cardIds[index],
        CardSchedule(
          state: CardState.active,
          step: 1,
          dueAt: dueDay.add(const Duration(hours: 12)),
        ),
        reviewedAt: reviewedDay.add(const Duration(hours: 12)),
      );

  Future<DateTime?> dueAt(int index) async =>
      (await cards.getCard(cardIds[index])).dueAt;

  group('3 cards a day', () {
    Future<void> firstDay({required bool prioritizeReviews}) async {
      await services.distillations.activate(
        groupId,
        DistillationSettings(
          cardsPerBatch: 3,
          prioritizeReviews: prioritizeReviews,
        ),
      );
      // One card missed, due tomorrow; two answered, due in three days.
      await answer(0, ReviewOutcome.again);
      for (final index in [1, 2]) {
        await answer(index, ReviewOutcome.correct);
        await schedule(index, DateTime(2026, 11, 13), DateTime(2026, 11, 10));
      }
      clock.now = DateTime(2026, 11, 11, 9);
    }

    test('day 1: three new cards', () async {
      await firstDay(prioritizeReviews: true);
      expect(await introduced(), [0, 1, 2]);
    });

    test('day 2: the missed card and two new ones', () async {
      await firstDay(prioritizeReviews: true);
      await services.distillations.advance();
      expect(await introduced(), [0, 1, 2, 3, 4]);
      expect(await dueAt(0), DateTime(2026, 11, 11, 12));
    });

    test('without the option, three new cards whatever is due', () async {
      await firstDay(prioritizeReviews: false);
      await services.distillations.advance();
      expect(await introduced(), [0, 1, 2, 3, 4, 5]);
    });
  });

  test('1 card a day: a card planned a week ago and a card missed '
      'yesterday both arrive, without new card', () async {
    await schedule(0, DateTime(2026, 11, 10), DateTime(2026, 11, 3));
    await schedule(1, DateTime(2026, 11, 10), DateTime(2026, 11, 9));
    await services.distillations.activate(
      groupId,
      const DistillationSettings(),
    );
    expect(await introduced(), [0, 1]);
    expect(await dueAt(0), DateTime(2026, 11, 10, 12));
    expect(await dueAt(1), DateTime(2026, 11, 10, 12));
  });

  test('overdue cards and cards introduced but not answered count', () async {
    await services.distillations.activate(
      groupId,
      const DistillationSettings(cardsPerBatch: 2),
    );
    clock.now = DateTime(2026, 11, 11, 9);
    await services.distillations.advance();
    expect(await introduced(), [0, 1]);
    expect(await dueAt(0), DateTime(2026, 11, 10, 12));
  });

  test('the cards held back stay at the head of the queue, '
      'and the next batch comes X days later', () async {
    await schedule(0, DateTime(2026, 11, 10), DateTime(2026, 11, 3));
    await services.distillations.activate(
      groupId,
      const DistillationSettings(cardsPerBatch: 2, everyDays: 2),
    );
    expect(await introduced(), [0, 1]);
    await answer(0, ReviewOutcome.correct);
    await answer(1, ReviewOutcome.correct);
    await schedule(0, DateTime(2026, 11, 20), DateTime(2026, 11, 10));
    await schedule(1, DateTime(2026, 11, 20), DateTime(2026, 11, 10));
    clock.now = DateTime(2026, 11, 11, 9);
    await services.distillations.advance();
    expect(await introduced(), [0, 1]);
    clock.now = DateTime(2026, 11, 12, 9);
    await services.distillations.advance();
    expect(await introduced(), [0, 1, 2, 3]);
  });
}
