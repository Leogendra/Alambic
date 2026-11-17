import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/data/database/alambic_database.dart';
import 'package:alambic/data/repositories/card_repository.dart';
import 'package:alambic/data/repositories/preset_repository.dart';
import 'package:alambic/domain/cards/card_state.dart';
import 'package:alambic/domain/cards/flashcard.dart';
import 'package:alambic/domain/presets/failure_behavior.dart';
import 'package:alambic/domain/reviews/review_outcome.dart';
import 'package:alambic/domain/reviews/review_source.dart';
import 'package:alambic/domain/scheduling/card_schedule.dart';

import '../support/fixed_clock.dart';
import '../support/sample_data.dart';
import '../support/test_database.dart';

/// "Again" on a due card, through the review service on a stored card, with
/// the Standard sequence (1 d, 2 d, 1 wk, 1 mo, 3 mo, 6 mo) as global preset.
void main() {
  late AlambicDatabase database;
  late FixedClock clock;
  late SampleServices samples;
  late CardRepository cards;
  late PresetRepository presets;

  setUp(() {
    database = openTestDatabase();
    clock = FixedClock(sampleNow);
    samples = SampleServices(database, clock);
    cards = CardRepository(database);
    presets = PresetRepository(database);
  });

  tearDown(() => database.close());

  Future<void> setFailureBehavior(FailureBehavior behavior) async {
    final global = (await presets.loadCatalog()).globalPreset;
    await presets.update(global.copyWith(failureBehavior: behavior));
  }

  /// A card at [step], due today at 12:00.
  Future<int> cardDueAtStep(int step) async {
    final groupId = await samples.groups.create('Capitales');
    final cardId = await samples.card('Pérou', 'Lima', groupId: groupId);
    await samples.introduceAll(groupId);
    await cards.applySchedule(
      cardId,
      CardSchedule(
        state: CardState.active,
        step: step,
        dueAt: DateTime(2026, 11, 10, 12),
      ),
    );
    return cardId;
  }

  Future<Flashcard> failAt(int cardId, DateTime at) async {
    clock.now = at;
    await samples.reviews.answer(
      cardId,
      ReviewOutcome.again,
      source: ReviewSource.session,
    );
    return cards.getCard(cardId);
  }

  final answeredAt = DateTime(2026, 11, 10, 12, 5);

  group('step back', () {
    test('goes back one step and waits its interval', () async {
      await setFailureBehavior(FailureBehavior.stepBack);
      final card = await failAt(await cardDueAtStep(3), answeredAt);
      expect(card.step, 2);
      expect(card.dueAt, DateTime(2026, 11, 17, 12), reason: '1 week');
    });

    test('stays at the first step', () async {
      await setFailureBehavior(FailureBehavior.stepBack);
      final card = await failAt(await cardDueAtStep(0), answeredAt);
      expect(card.step, 0);
      expect(card.dueAt, DateTime(2026, 11, 11, 12), reason: '1 day');
    });
  });

  test('restart goes back to the first step, and the card stays introduced '
      'instead of going back to the queue', () async {
    await setFailureBehavior(FailureBehavior.restart);
    final card = await failAt(await cardDueAtStep(4), answeredAt);
    expect(card.step, 0);
    expect(card.state, CardState.active);
    expect(card.queuePosition, isNull);
    expect(card.dueAt, DateTime(2026, 11, 11, 12));
  });

  test('stay keeps the step and waits its interval again', () async {
    await setFailureBehavior(FailureBehavior.stay);
    final card = await failAt(await cardDueAtStep(3), answeredAt);
    expect(card.step, 3);
    expect(card.dueAt, DateTime(2026, 12, 10, 12), reason: '1 month');
  });

  test('the behaviour is read at the answer: editing the preset moves no '
      'due date, the next failure follows the new behaviour', () async {
    await setFailureBehavior(FailureBehavior.stepBack);
    final cardId = await cardDueAtStep(3);
    var card = await failAt(cardId, answeredAt);
    expect(card.step, 2);
    await setFailureBehavior(FailureBehavior.restart);
    card = await cards.getCard(cardId);
    expect(card.step, 2);
    expect(card.dueAt, DateTime(2026, 11, 17, 12));
    card = await failAt(cardId, DateTime(2026, 11, 17, 12, 5));
    expect(card.step, 0);
    expect(card.dueAt, DateTime(2026, 11, 18, 12));
  });

  test('a bonus review never applies the failure', () async {
    await setFailureBehavior(FailureBehavior.restart);
    final cardId = await cardDueAtStep(3);
    await cards.applySchedule(
      cardId,
      CardSchedule(
        state: CardState.active,
        step: 3,
        dueAt: DateTime(2026, 11, 20, 12),
      ),
    );
    final card = await failAt(cardId, answeredAt);
    expect(card.step, 3);
    expect(card.dueAt, DateTime(2026, 11, 20, 12));
  });
}
