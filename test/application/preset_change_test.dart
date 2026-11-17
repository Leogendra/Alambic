import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/application/presets/preset_service.dart';
import 'package:alambic/data/database/alambic_database.dart';
import 'package:alambic/data/repositories/card_repository.dart';
import 'package:alambic/data/repositories/group_repository.dart';
import 'package:alambic/data/repositories/preset_repository.dart';
import 'package:alambic/domain/cards/card_state.dart';
import 'package:alambic/domain/cards/flashcard.dart';
import 'package:alambic/domain/presets/built_in_preset_key.dart';
import 'package:alambic/domain/presets/interval_unit.dart';
import 'package:alambic/domain/presets/preset.dart';
import 'package:alambic/domain/presets/preset_interval.dart';
import 'package:alambic/domain/reviews/review_outcome.dart';
import 'package:alambic/domain/reviews/review_source.dart';
import 'package:alambic/domain/scheduling/card_progress.dart';
import 'package:alambic/domain/scheduling/card_schedule.dart';

import '../support/fixed_clock.dart';
import '../support/sample_data.dart';
import '../support/test_database.dart';

/// A change of preset, of the global preset or of the steps of a preset keeps
/// the step and the due date of every card; a step beyond a shorter sequence
/// counts as its last step.
void main() {
  late AlambicDatabase database;
  late FixedClock clock;
  late SampleServices samples;
  late CardRepository cards;
  late PresetRepository presets;
  late PresetService presetService;
  late int groupId;
  final dueAt = DateTime(2026, 11, 20, 12);

  setUp(() async {
    database = openTestDatabase();
    clock = FixedClock(sampleNow);
    samples = SampleServices(database, clock);
    cards = CardRepository(database);
    presets = PresetRepository(database);
    presetService = PresetService(presets, GroupRepository(database));
    groupId = await samples.groups.create('Capitales');
  });

  tearDown(() => database.close());

  Future<Preset> shipped(BuiltInPresetKey key) async =>
      (await presets.loadCatalog()).presetsById.values.firstWhere(
        (preset) => preset.builtInKey == key,
      );

  /// A card of the group at [step] of Standard (3 mo for step 4), due on
  /// [dueAt].
  Future<int> cardAtStep(int step) async {
    final cardId = await samples.card('Pérou', 'Lima', groupId: groupId);
    await cards.applySchedule(
      cardId,
      CardSchedule(state: CardState.active, step: step, dueAt: dueAt),
    );
    return cardId;
  }

  Future<CardProgress> progressOf(Flashcard card) async {
    final catalog = await presets.loadCatalog();
    return CardProgress.of(
      card,
      catalog.presetForGroup(card.groupId),
      catalog.sequenceEndForGroup(card.groupId),
    );
  }

  Future<void> expectKept(int cardId, {required int step}) async {
    final card = await cards.getCard(cardId);
    expect(card.step, step);
    expect(card.dueAt, dueAt);
    expect(card.state, CardState.active);
  }

  test('changing the preset of a group keeps the step and the due date, '
      'the step now waits the interval of the new preset', () async {
    final cardId = await cardAtStep(4);
    final intensive = await shipped(BuiltInPresetKey.intensive);
    await samples.groups.setPreset(groupId, intensive.id);
    await expectKept(cardId, step: 4);
    final progress = await progressOf(await cards.getCard(cardId));
    expect((progress as SequenceProgress).step, 4);
    expect(progress.interval, intensive.intervals[4]);
  });

  test('changing the global preset keeps the step and the due date', () async {
    final cardId = await cardAtStep(2);
    final intensive = await shipped(BuiltInPresetKey.intensive);
    await presetService.setGlobalPreset(intensive.id);
    await expectKept(cardId, step: 2);
    final progress = await progressOf(await cards.getCard(cardId));
    expect((progress as SequenceProgress).interval, intensive.intervals[2]);
  });

  group('a preset edited to fewer steps', () {
    const shorter = [
      PresetInterval(1, IntervalUnit.day),
      PresetInterval(3, IntervalUnit.day),
      PresetInterval(1, IntervalUnit.week),
    ];

    setUp(() async {
      final standard = await shipped(BuiltInPresetKey.standard);
      await presetService.save(standard.copyWith(intervals: shorter));
    });

    test('keeps the due date and brings the step back to the last', () async {
      final cardId = await cardAtStep(4);
      await expectKept(cardId, step: 4);
      final progress = await progressOf(await cards.getCard(cardId));
      expect((progress as SequenceProgress).step, 2);
      expect(progress.interval, shorter[2]);
    });

    test('answers from the last step', () async {
      final cardId = await cardAtStep(4);
      clock.now = DateTime(2026, 11, 20, 12, 5);
      await samples.reviews.answer(
        cardId,
        ReviewOutcome.correct,
        source: ReviewSource.session,
      );
      var card = await cards.getCard(cardId);
      expect(card.state, CardState.remanent, reason: 'past the last step');
      expect(card.dueAt, DateTime(2027, 5, 19, 12));

      clock.now = DateTime(2027, 5, 19, 12, 5);
      await samples.reviews.answer(
        cardId,
        ReviewOutcome.again,
        source: ReviewSource.session,
      );
      card = await cards.getCard(cardId);
      expect(card.state, CardState.active);
      expect(card.step, 2, reason: 'one step back from the remanence');
      expect(card.dueAt, DateTime(2027, 5, 26, 12));
    });
  });

  test('a card in remanence stays in remanence, with its due date, on a '
      'shorter or a longer sequence', () async {
    final cardId = await samples.card('Pérou', 'Lima', groupId: groupId);
    final remanenceDue = DateTime(2027, 5, 9, 12);
    await cards.applySchedule(
      cardId,
      CardSchedule(state: CardState.remanent, step: null, dueAt: remanenceDue),
    );
    final standard = await shipped(BuiltInPresetKey.standard);
    for (final intervals in [
      const [PresetInterval(1, IntervalUnit.day)],
      [...standard.intervals, const PresetInterval(1, IntervalUnit.year)],
    ]) {
      await presetService.save(standard.copyWith(intervals: intervals));
      final card = await cards.getCard(cardId);
      expect(card.state, CardState.remanent);
      expect(card.dueAt, remanenceDue);
      expect(await progressOf(card), isA<RemanenceProgress>());
    }
  });

  test('an acquired card stays acquired', () async {
    final cardId = await samples.card('Pérou', 'Lima', groupId: groupId);
    await cards.applySchedule(
      cardId,
      const CardSchedule(state: CardState.acquired, step: null, dueAt: null),
    );
    await samples.groups.setPreset(
      groupId,
      (await shipped(BuiltInPresetKey.intensive)).id,
    );
    final card = await cards.getCard(cardId);
    expect(card.state, CardState.acquired);
    expect(card.dueAt, isNull);
  });
}
