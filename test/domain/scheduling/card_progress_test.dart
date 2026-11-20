import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/domain/cards/card_state.dart';
import 'package:alambic/domain/cards/flashcard.dart';
import 'package:alambic/domain/scheduling/card_progress.dart';

import '../test_cards.dart';
import '../test_groups.dart';
import '../test_presets.dart';

void main() {
  Flashcard answered({int? step}) => testCard(
    state: CardState.active,
    step: step,
    dueAt: DateTime(2026, 11, 20, 12),
    lastReviewedAt: DateTime(2026, 11, 10, 12),
  );

  test('reads the step and the interval it waits', () {
    final progress = CardProgress.of(
      answered(step: 3),
      standardPreset,
      remanence(),
    );
    expect(progress, isA<SequenceProgress>());
    progress as SequenceProgress;
    expect(progress.step, 3);
    expect(progress.sequenceLength, 6);
    expect(progress.waitedInterval, const Duration(days: 30));
  });

  test('a step beyond a shorter sequence counts as its last step', () {
    final clamped = CardProgress.of(
      answered(step: 3),
      shortSequence(),
      remanence(),
    );
    expect((clamped as SequenceProgress).step, 2);
  });

  test('a card never answered is new and waits nothing', () {
    final progress = CardProgress.of(answered(), standardPreset, remanence());
    expect(progress, isA<NewProgress>());
    expect(progress.waitedInterval, Duration.zero);
  });

  test('a card in remanence stays in remanence whatever the sequence', () {
    final card = testCard(
      state: CardState.completed,
      dueAt: DateTime(2027, 5, 9, 12),
    );
    for (final preset in [shortSequence(), standardPreset, intensivePreset]) {
      final progress = CardProgress.of(card, preset, remanence());
      expect(progress, isA<RemanenceProgress>());
      expect(progress.waitedInterval, const Duration(days: 180));
    }
  });
}
