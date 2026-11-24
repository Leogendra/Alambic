import 'dart:math';

import '../groups/sequence_end.dart';
import '../presets/failure_behavior.dart';
import '../presets/preset.dart';
import '../reviews/review_outcome.dart';
import 'card_progress.dart';
import 'sequence_step.dart';
import 'step_target.dart';

/// Walks the fixed interval sequence of a preset, then the end its group
/// chose.
///
/// The step is the index of the interval currently waited. A never answered
/// card has no step: a first "Correct" waits the first interval. Remanence
/// is one more step after the last one: a failure in remanence follows the
/// failure behaviour of the preset like any other step.
abstract final class SequenceEngine {
  /// The step reached from [progress], read against [preset] by
  /// [CardProgress.of].
  static SequenceStep answer({
    required CardProgress progress,
    required ReviewOutcome outcome,
    required Preset preset,
    required SequenceEnd end,
  }) {
    assert(preset.intervals.isNotEmpty, 'A sequence needs one interval.');
    return switch (outcome) {
      ReviewOutcome.correct => _afterSuccess(progress, preset, end),
      ReviewOutcome.again => _afterFailure(progress, preset, end),
    };
  }

  static SequenceStep _afterSuccess(
    CardProgress progress,
    Preset preset,
    SequenceEnd end,
  ) => switch (progress) {
    NewProgress() => _step(0, preset),
    SequenceProgress(:final step) when step < preset.lastStep => _step(
      step + 1,
      preset,
    ),
    // Read at the answer, from the group in force at that moment.
    SequenceProgress() ||
    RemanenceProgress() => const SequenceEndTarget().reached(preset, end),
  };

  static SequenceStep _afterFailure(
    CardProgress progress,
    Preset preset,
    SequenceEnd end,
  ) => switch ((preset.failureBehavior, progress)) {
    (FailureBehavior.restart, _) || (_, NewProgress()) => _step(0, preset),
    (FailureBehavior.stepBack, SequenceProgress(:final step)) => _step(
      max(step - 1, 0),
      preset,
    ),
    (FailureBehavior.stepBack, RemanenceProgress()) => _step(
      preset.lastStep,
      preset,
    ),
    (FailureBehavior.stay, SequenceProgress(:final step)) => _step(
      step,
      preset,
    ),
    (FailureBehavior.stay, RemanenceProgress()) => RemanenceReached(
      end.remanenceAfter(preset),
    ),
  };

  static SequenceStep _step(int step, Preset preset) =>
      StepIndexTarget(step).reached(preset);
}
