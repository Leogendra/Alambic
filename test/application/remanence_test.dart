import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/data/database/alambic_database.dart';
import 'package:alambic/data/repositories/card_repository.dart';
import 'package:alambic/data/repositories/group_repository.dart';
import 'package:alambic/data/repositories/preset_repository.dart';
import 'package:alambic/data/repositories/review_repository.dart';
import 'package:alambic/domain/cards/card_state.dart';
import 'package:alambic/domain/cards/flashcard.dart';
import 'package:alambic/domain/groups/after_last_step.dart';
import 'package:alambic/domain/groups/remanence_interval.dart';
import 'package:alambic/domain/presets/failure_behavior.dart';
import 'package:alambic/domain/reviews/review_outcome.dart';
import 'package:alambic/domain/reviews/review_source.dart';
import 'package:alambic/domain/scheduling/card_schedule.dart';

import '../support/fixed_clock.dart';
import '../support/sample_data.dart';
import '../support/test_database.dart';

/// The end of sequence of a group, through the services on stored cards,
/// with the Standard sequence (1 d … 6 mo, last step 5) as global preset.
void main() {
  late AlambicDatabase database;
  late FixedClock clock;
  late SampleServices samples;
  late CardRepository cards;
  late int groupId;

  final dueToday = DateTime(2026, 11, 10, 12);
  final answeredAt = DateTime(2026, 11, 10, 12, 5);

  setUp(() async {
    database = openTestDatabase();
    clock = FixedClock(sampleNow);
    samples = SampleServices(database, clock);
    cards = CardRepository(database);
    groupId = await samples.groups.create('Capitals');
  });

  tearDown(() => database.close());

  Future<int> cardWith(CardSchedule schedule) async {
    final cardId = await samples.card('Peru', 'Lima', groupId: groupId);
    await cards.applySchedule(cardId, schedule);
    return cardId;
  }

  Future<int> cardAtLastStep() =>
      cardWith(CardSchedule(state: CardState.active, step: 5, dueAt: dueToday));

  Future<int> remanentCard({DateTime? dueAt}) => cardWith(
    CardSchedule(
      state: CardState.completed,
      step: null,
      dueAt: dueAt ?? dueToday,
    ),
  );

  Future<Flashcard> answer(int cardId, ReviewOutcome outcome) async {
    clock.now = answeredAt;
    await samples.reviews.answer(cardId, outcome, source: ReviewSource.session);
    return cards.getCard(cardId);
  }

  Future<void> setFailureBehavior(FailureBehavior behavior) async {
    final presets = PresetRepository(database);
    final global = (await presets.loadCatalog()).globalPreset;
    await presets.update(global.copyWith(failureBehavior: behavior));
  }

  test('a new group comes back in remanence every 6 months, without typed '
      'answer', () async {
    final group = (await GroupRepository(database).find(groupId))!;
    expect(group.afterLastStep, AfterLastStep.remanence);
    expect(group.remanenceInterval, RemanenceInterval.sixMonths);
    expect(group.typedAnswer, isFalse);
  });

  group('remanence', () {
    test('a success at the last step enters the remanence, at the interval '
        'of the group, and the history records it', () async {
      await samples.groups.setRemanenceInterval(
        groupId,
        RemanenceInterval.oneYear,
      );
      final cardId = await cardAtLastStep();
      final card = await answer(cardId, ReviewOutcome.correct);
      expect(card.state, CardState.completed);
      expect(card.step, isNull);
      expect(card.dueAt, DateTime(2027, 11, 10, 12), reason: '365 days');
      final history = await ReviewRepository(database)
          .watchHistory(cardId)
          .first;
      expect(history.single.stateAfter, CardState.completed);
    });

    test('a success in remanence stays in remanence', () async {
      final card = await answer(await remanentCard(), ReviewOutcome.correct);
      expect(card.state, CardState.completed);
      expect(card.dueAt, DateTime(2027, 5, 9, 12), reason: '180 days');
    });

    test('a failure stepping back returns to the last step', () async {
      await setFailureBehavior(FailureBehavior.stepBack);
      final card = await answer(await remanentCard(), ReviewOutcome.again);
      expect(card.state, CardState.active);
      expect(card.step, 5);
      expect(card.dueAt, DateTime(2027, 5, 9, 12), reason: '6 months');
    });

    test('a failure restarting returns to the first step', () async {
      await setFailureBehavior(FailureBehavior.restart);
      final card = await answer(await remanentCard(), ReviewOutcome.again);
      expect(card.state, CardState.active);
      expect(card.step, 0);
      expect(card.dueAt, DateTime(2026, 11, 11, 12));
    });

    test('a failure staying keeps the remanence', () async {
      await setFailureBehavior(FailureBehavior.stay);
      await samples.groups.setRemanenceInterval(
        groupId,
        RemanenceInterval.threeMonths,
      );
      final card = await answer(await remanentCard(), ReviewOutcome.again);
      expect(card.state, CardState.completed);
      expect(
        card.dueAt,
        DateTime(2027, 5, 9, 12),
        reason:
            'the 6 months '
            'of the last step, longer than the 3 months of the group',
      );
    });

    test('changing the interval moves no due date', () async {
      final dueAt = DateTime(2027, 2, 1, 12);
      final cardId = await remanentCard(dueAt: dueAt);
      await samples.groups.setRemanenceInterval(
        groupId,
        RemanenceInterval.oneYear,
      );
      expect((await cards.getCard(cardId)).dueAt, dueAt);
    });
  });

  group('switched to acquired', () {
    test('a success at the last step acquires the card', () async {
      await samples.groups.setAfterLastStep(groupId, AfterLastStep.acquired);
      final card = await answer(await cardAtLastStep(), ReviewOutcome.correct);
      expect(card.state, CardState.completed);
      expect(card.isAcquired, isTrue);
      expect(card.dueAt, isNull);
    });

    test('a card in remanence loses its due date at once, the cards still in '
        'their sequence keep theirs', () async {
      final remanentId = await remanentCard();
      final activeId = await cardAtLastStep();
      await samples.groups.setAfterLastStep(groupId, AfterLastStep.acquired);
      final acquired = await cards.getCard(remanentId);
      expect(acquired.state, CardState.completed);
      expect(acquired.dueAt, isNull);
      final active = await cards.getCard(activeId);
      expect(active.step, 5);
      expect(active.dueAt, dueToday);
    });
  });

  group('switched back to remanence', () {
    Future<int> acquiredCard({required DateTime lastReviewedAt}) async {
      final cardId = await samples.card('Peru', 'Lima', groupId: groupId);
      await cards.applySchedule(
        cardId,
        CardSchedule.acquired,
        reviewedAt: lastReviewedAt,
      );
      return cardId;
    }

    setUp(
      () => samples.groups.setAfterLastStep(groupId, AfterLastStep.acquired),
    );

    test('an acquired card is due one remanence interval after its last '
        'review, the others are untouched', () async {
      final acquiredId = await acquiredCard(
        lastReviewedAt: DateTime(2026, 8, 12, 9),
      );
      final activeId = await cardWith(
        CardSchedule(state: CardState.active, step: 2, dueAt: dueToday),
      );
      final otherGroup = await samples.groups.create('Spanish');
      final elsewhereId = await samples.card(
        'drink',
        'beber',
        groupId: otherGroup,
      );
      await cards.applySchedule(elsewhereId, CardSchedule.acquired);

      await samples.groups.setAfterLastStep(groupId, AfterLastStep.remanence);

      final revived = await cards.getCard(acquiredId);
      expect(revived.state, CardState.completed);
      expect(
        revived.dueAt,
        DateTime(2027, 2, 8, 12),
        reason: '180 days after 12 August, at the daily slot',
      );
      final active = await cards.getCard(activeId);
      expect(active.state, CardState.active);
      expect(active.step, 2);
      expect(active.dueAt, dueToday);
      expect((await cards.getCard(elsewhereId)).isAcquired, isTrue);
    });

    test('a card whose last review is older than the interval is due one '
        'interval after the switch', () async {
      final cardId = await acquiredCard(
        lastReviewedAt: DateTime(2026, 3, 10, 9),
      );
      await samples.groups.setAfterLastStep(groupId, AfterLastStep.remanence);
      expect(
        (await cards.getCard(cardId)).dueAt,
        DateTime(2027, 5, 9, 12),
        reason: '180 days after 10 November, not on 6 September',
      );
    });

    test('choosing the end already in force moves no due date', () async {
      await samples.groups.setAfterLastStep(groupId, AfterLastStep.remanence);
      final dueAt = DateTime(2027, 2, 1, 12);
      final cardId = await remanentCard(dueAt: dueAt);
      await samples.groups.setAfterLastStep(groupId, AfterLastStep.remanence);
      expect((await cards.getCard(cardId)).dueAt, dueAt);
    });
  });
}
