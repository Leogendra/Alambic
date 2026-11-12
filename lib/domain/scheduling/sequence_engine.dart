import 'dart:math';

import '../presets/failure_behavior.dart';
import '../presets/preset.dart';
import '../presets/sequence_end_behavior.dart';
import '../reviews/review_outcome.dart';
import 'sequence_step.dart';

/// Walks the fixed interval sequence of a preset.
///
/// The step is the index of the interval currently waited. A never answered
/// direction has no step: a first "Correct" waits the first interval.
abstract final class SequenceEngine {
  static SequenceStep answer({
    required int? currentStep,
    required ReviewOutcome outcome,
    required Preset preset,
  }) {
    assert(preset.intervals.isNotEmpty, 'A sequence needs one interval.');
    final step = clampToSequence(currentStep, preset);
    return switch (outcome) {
      ReviewOutcome.correct => _afterSuccess(step, preset),
      ReviewOutcome.again => _scheduled(_afterFailure(step, preset), preset),
    };
  }

  /// A step kept from a longer sequence is brought back to the last step.
  static int? clampToSequence(int? step, Preset preset) {
    if (step == null) {
      return null;
    } else {
      return min(step, preset.sequenceLength - 1);
    }
  }

  static SequenceStep _afterSuccess(int? step, Preset preset) {
    final nextStep = step == null ? 0 : step + 1;
    if (nextStep < preset.sequenceLength) {
      return _scheduled(nextStep, preset);
    } else {
      return _afterLastStep(preset);
    }
  }

  static SequenceStep _afterLastStep(Preset preset) =>
      switch (preset.endBehavior) {
        SequenceEndBehavior.repeatLast => _scheduled(
          preset.sequenceLength - 1,
          preset,
        ),
        SequenceEndBehavior.markAcquired => const SequenceStep.acquired(),
        SequenceEndBehavior.loop => _scheduled(0, preset),
      };

  static int _afterFailure(int? step, Preset preset) =>
      switch (preset.failureBehavior) {
        FailureBehavior.stepBack => step == null ? 0 : max(step - 1, 0),
        FailureBehavior.restart => 0,
        FailureBehavior.stay => step ?? 0,
      };

  static SequenceStep _scheduled(int step, Preset preset) =>
      SequenceStep.scheduled(step, preset.intervals[step]);
}
