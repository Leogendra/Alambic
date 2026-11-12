import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/domain/presets/failure_behavior.dart';
import 'package:alambic/domain/presets/sequence_end_behavior.dart';
import 'package:alambic/domain/reviews/review_outcome.dart';
import 'package:alambic/domain/scheduling/sequence_engine.dart';
import 'package:alambic/domain/scheduling/sequence_step.dart';

import '../test_presets.dart';

void main() {
  SequenceStep answer(
    int? currentStep,
    ReviewOutcome outcome, {
    FailureBehavior failureBehavior = FailureBehavior.stepBack,
    SequenceEndBehavior endBehavior = SequenceEndBehavior.repeatLast,
  }) => SequenceEngine.answer(
    currentStep: currentStep,
    outcome: outcome,
    preset: shortSequence(
      failureBehavior: failureBehavior,
      endBehavior: endBehavior,
    ),
  );

  group('success', () {
    test('a first correct answer waits the first interval', () {
      final result = answer(null, ReviewOutcome.correct);
      expect(result.step, 0);
      expect(result.interval, shortSequence().intervals[0]);
    });

    test('a correct answer moves one step forward', () {
      expect(answer(0, ReviewOutcome.correct).step, 1);
    });
  });

  group('end of sequence', () {
    test('repeat last keeps the last interval', () {
      final result = answer(
        2,
        ReviewOutcome.correct,
        endBehavior: SequenceEndBehavior.repeatLast,
      );
      expect(result.step, 2);
    });

    test('loop goes back to the first interval', () {
      final result = answer(
        2,
        ReviewOutcome.correct,
        endBehavior: SequenceEndBehavior.loop,
      );
      expect(result.step, 0);
    });

    test('mark acquired stops the sequence', () {
      final result = answer(
        2,
        ReviewOutcome.correct,
        endBehavior: SequenceEndBehavior.markAcquired,
      );
      expect(result.acquired, isTrue);
      expect(result.step, isNull);
      expect(result.interval, isNull);
    });
  });

  group('failure', () {
    int? stepAfterFailure(FailureBehavior behavior, int? currentStep) => answer(
      currentStep,
      ReviewOutcome.again,
      failureBehavior: behavior,
    ).step;

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

    test('a never answered direction fails onto the first step', () {
      for (final behavior in FailureBehavior.values) {
        expect(stepAfterFailure(behavior, null), 0);
      }
    });
  });

  test('a step beyond a shortened sequence is brought back to its end', () {
    expect(answer(5, ReviewOutcome.again).step, 1);
  });
}
