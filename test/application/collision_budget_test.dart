import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/data/database/alambic_database.dart';
import 'package:alambic/data/repositories/card_repository.dart';
import 'package:alambic/domain/cards/card_direction.dart';
import 'package:alambic/domain/cards/direction_sense.dart';
import 'package:alambic/domain/cards/direction_state.dart';
import 'package:alambic/domain/distillation/distillation_settings.dart';
import 'package:alambic/domain/reviews/review_outcome.dart';
import 'package:alambic/domain/reviews/review_source.dart';

import '../support/fixed_clock.dart';
import '../support/sample_data.dart';
import '../support/test_database.dart';

/// The example of the specification: 3 cards a day, Standard preset (1 day,
/// 2 days, 1 week...), every card answered correctly when it comes.
void main() {
  late AlambicDatabase database;
  late FixedClock clock;
  late SampleServices services;
  late CardRepository cards;
  late List<int> cardIds;

  setUp(() async {
    database = openTestDatabase();
    clock = FixedClock(DateTime(2026, 11, 10, 9));
    services = SampleServices(database, clock);
    cards = CardRepository(database);
    final groupId = await services.groups.create('Capitales');
    cardIds = [
      for (var index = 0; index < 12; index++)
        await services.card('Pays $index', 'Capitale $index', groupId: groupId),
    ];
    await services.distillations.launchForGroup(
      groupId,
      DirectionSense.frontToBack,
      const DistillationSettings(cardsPerBatch: 3),
    );
  });

  tearDown(() => database.close());

  Future<List<CardDirection>> fronts() async => [
    for (final cardId in cardIds)
      (await cards.getDirections(cardId)).firstWhere(
        (direction) => direction.sense == DirectionSense.frontToBack,
      ),
  ];

  /// Moves to [day] at 1pm, runs the daily pass and answers everything due
  /// today. Returns the indexes of the new cards and of the reminders
  /// answered that day.
  Future<({List<int> news, List<int> reminders})> live(int day) async {
    clock.now = DateTime(2026, 11, day, 13);
    await services.distillations.advance();
    final news = <int>[];
    final reminders = <int>[];
    for (final (index, direction) in (await fronts()).indexed) {
      final dueAt = direction.dueAt;
      if (direction.state == DirectionState.active &&
          dueAt != null &&
          dueAt.day == day) {
        (direction.step == null ? news : reminders).add(index);
        await services.reviews.answer(
          direction.id,
          ReviewOutcome.correct,
          source: ReviewSource.session,
        );
      }
    }
    return (news: news, reminders: reminders);
  }

  test('day 1: three new cards', () async {
    final today = await live(10);
    expect(today.news, [0, 1, 2]);
    expect(today.reminders, isEmpty);
  });

  test('day 2: the three D+1 reminders take the whole budget', () async {
    await live(10);
    final today = await live(11);
    expect(today.news, isEmpty);
    expect(today.reminders, [0, 1, 2]);
  });

  test('day 3: three new cards again', () async {
    await live(10);
    await live(11);
    final today = await live(12);
    expect(today.news, [3, 4, 5]);
  });

  test('day 4: the D+1 reminders pass, the D+2 ones move to day 5, '
      'without penalty', () async {
    await live(10);
    await live(11);
    await live(12);
    clock.now = DateTime(2026, 11, 13, 13);
    await services.distillations.advance();
    final directions = await fronts();
    for (final index in [3, 4, 5]) {
      expect(directions[index].dueAt, DateTime(2026, 11, 13, 12));
    }
    for (final index in [0, 1, 2]) {
      expect(directions[index].dueAt, DateTime(2026, 11, 14, 12));
      expect(directions[index].step, 1);
    }
    expect(directions[6].state, DirectionState.pending);
  });

  test(
    'a card introduced and not answered keeps its place in the budget',
    () async {
      clock.now = DateTime(2026, 11, 10, 13);
      await services.distillations.advance();
      clock.now = DateTime(2026, 11, 11, 13);
      await services.distillations.advance();
      final directions = await fronts();
      expect(directions[3].state, DirectionState.pending);
    },
  );
}
