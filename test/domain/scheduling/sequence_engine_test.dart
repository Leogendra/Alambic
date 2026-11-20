import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/domain/cards/card_state.dart';
import 'package:alambic/domain/groups/remanence_interval.dart';
import 'package:alambic/domain/groups/sequence_end.dart';
import 'package:alambic/domain/presets/failure_behavior.dart';
import 'package:alambic/domain/presets/interval_unit.dart';
import 'package:alambic/domain/presets/preset.dart';
import 'package:alambic/domain/presets/preset_interval.dart';
import 'package:alambic/domain/reviews/review_outcome.dart';
import 'package:alambic/domain/scheduling/card_progress.dart';
import 'package:alambic/domain/scheduling/sequence_engine.dart';
import 'package:alambic/domain/scheduling/sequence_step.dart';

import '../test_cards.dart';
import '../test_groups.dart';
import '../test_presets.dart';

void main() {
  const sixMonths = PresetInterval(6, IntervalUnit.month);

  /// The answer of a card at [step] of the short sequence, or in remanence.
  SequenceStep answer(
    int? step,
    ReviewOutcome outcome, {
    bool remanent = false,
    FailureBehavior failureBehavior = FailureBehavior.stepBack,
    SequenceEnd? end,
    Preset? preset,
  }) {
    final sequence = preset ?? shortSequence(failureBehavior: failureBehavior);
    final sequenceEnd = end ?? remanence();
    final card = testCard(
      state: remanent ? CardState.completed : CardState.active,
      step: remanent ? null : step,
      dueAt: DateTime(2026, 11, 10, 12),
    );
    return SequenceEngine.answer(
      progress: CardProgress.of(card, sequence, sequenceEnd),
      outcome: outcome,
      preset: sequence,
      end: sequenceEnd,
    );
  }

  int? stepOf(SequenceStep result) =>
      result is StepReached ? result.step : null;

  group('success', () {
    test('a first correct answer waits the first interval', () {
      final result = answer(null, ReviewOutcome.correct);
      expect(result, isA<StepReached>());
      result as StepReached;
      expect(result.step, 0);
      expect(result.interval, shortSequence().intervals[0]);
    });

    test('a correct answer moves one step forward', () {
      expect(stepOf(answer(0, ReviewOutcome.correct)), 1);
    });
  });

  group('after the last step', () {
    test('remanence comes back at the interval of the group', () {
      final result = answer(2, ReviewOutcome.correct);
      expect((result as RemanenceReached).interval, sixMonths);
    });

    test('a success in remanence stays in remanence', () {
      final result = answer(null, ReviewOutcome.correct, remanent: true);
      expect((result as RemanenceReached).interval, sixMonths);
    });

    test('the group interval is the one chosen', () {
      final threeMonths = answer(
        2,
        ReviewOutcome.correct,
        end: remanence(RemanenceInterval.threeMonths),
      );
      final oneYear = answer(
        2,
        ReviewOutcome.correct,
        end: remanence(RemanenceInterval.oneYear),
      );
      expect(
        (threeMonths as RemanenceReached).interval,
        const PresetInterval(3, IntervalUnit.month),
      );
      expect((oneYear as RemanenceReached).interval.days, 365);
    });

    test('a last step longer than the group interval is kept', () {
      final longSequence = standardPreset.copyWith(
        intervals: const [
          PresetInterval(1, IntervalUnit.day),
          PresetInterval(9, IntervalUnit.month),
        ],
      );
      final result = answer(1, ReviewOutcome.correct, preset: longSequence);
      expect(
        (result as RemanenceReached).interval,
        const PresetInterval(9, IntervalUnit.month),
      );
    });

    test('a short preset does not shorten the remanence', () {
      final result = answer(4, ReviewOutcome.correct, preset: intensivePreset);
      expect((result as RemanenceReached).interval, sixMonths);
    });

    test('acquired stops the sequence', () {
      expect(
        answer(2, ReviewOutcome.correct, end: acquiredEnd),
        isA<AcquiredReached>(),
      );
    });
  });

  group('failure', () {
    int? stepAfterFailure(FailureBehavior behavior, int? currentStep) => stepOf(
      answer(currentStep, ReviewOutcome.again, failureBehavior: behavior),
    );

    test('step back moves one step back, never below the first', () {
      expect(stepAfterFailure(FailureBehavior.stepBack, 2), 1);
      expect(stepAfterFailure(FailureBehavior.stepBack, 0), 0);
    });

    test('restart goes back to the first step', () {
      expect(stepAfterFailure(FailureBehavior.restart, 2), 0);
    });

    test('stay keeps the step', () {
      expect(stepAfterFailure(FailureBehavior.stay, 2), 2);
    });

    test('a never answered card fails onto the first step', () {
      for (final behavior in FailureBehavior.values) {
        expect(stepAfterFailure(behavior, null), 0);
      }
    });
  });

  group('failure in remanence', () {
    SequenceStep fail(FailureBehavior behavior, {SequenceEnd? end}) => answer(
      null,
      ReviewOutcome.again,
      remanent: true,
      failureBehavior: behavior,
      end: end,
    );

    test('step back returns to the last step', () {
      expect(stepOf(fail(FailureBehavior.stepBack)), 2);
    });

    test('restart returns to the first step', () {
      expect(stepOf(fail(FailureBehavior.restart)), 0);
    });

    test('stay keeps the remanence and its interval', () {
      expect(
        (fail(FailureBehavior.stay) as RemanenceReached).interval,
        sixMonths,
      );
    });
  });

  test('a step beyond a shortened sequence is brought back to its end', () {
    expect(stepOf(answer(5, ReviewOutcome.again)), 1);
  });
}
