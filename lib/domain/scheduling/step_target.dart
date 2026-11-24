import '../cards/card_state.dart';
import '../cards/flashcard.dart';
import '../groups/after_last_step.dart';
import '../groups/sequence_end.dart';
import '../presets/preset.dart';
import 'sequence_step.dart';

/// Where the user puts a card by hand: back in the queue of its group, at a
/// step of the sequence of its preset, or at the end its group gives to the
/// sequence, remanence or acquired.
sealed class StepTarget {
  const StepTarget();

  /// The targets offered for a card of a group following [preset], in the
  /// order of the sequence: the queue first, the end of the sequence last.
  static List<StepTarget> allOf(Preset preset) => [
    const PendingTarget(),
    for (var step = 0; step < preset.sequenceLength; step++)
      StepIndexTarget(step),
    const SequenceEndTarget(),
  ];

  /// The target [card] stands at, read against [preset]; `null` for a card
  /// introduced and never answered, which waits no step yet.
  static StepTarget? of(Flashcard card, Preset preset) =>
      switch ((card.state, preset.clampStep(card.step))) {
        (CardState.pending, _) => const PendingTarget(),
        (CardState.completed, _) => const SequenceEndTarget(),
        (CardState.active, final step?) => StepIndexTarget(step),
        (CardState.active, null) => null,
      };
}

/// Back in the queue of the group, as a new card.
final class PendingTarget extends StepTarget {
  const PendingTarget();

  @override
  bool operator ==(Object other) => other is PendingTarget;

  @override
  int get hashCode => (PendingTarget).hashCode;
}

/// At [step] of the sequence of the preset.
final class StepIndexTarget extends StepTarget {
  const StepIndexTarget(this.step);

  final int step;

  /// The position reached, as if an answer had brought the card there.
  StepReached reached(Preset preset) =>
      StepReached(step, preset.intervals[step]);

  @override
  bool operator ==(Object other) =>
      other is StepIndexTarget && other.step == step;

  @override
  int get hashCode => step.hashCode;
}

/// Past the last step: in remanence, or acquired, as the group ends its
/// sequence.
final class SequenceEndTarget extends StepTarget {
  const SequenceEndTarget();

  /// The position reached, as if an answer past the last step had brought
  /// the card there.
  SequenceStep reached(Preset preset, SequenceEnd end) =>
      switch (end.afterLastStep) {
        AfterLastStep.remanence => RemanenceReached(end.remanenceAfter(preset)),
        AfterLastStep.acquired => const AcquiredReached(),
      };

  @override
  bool operator ==(Object other) => other is SequenceEndTarget;

  @override
  int get hashCode => (SequenceEndTarget).hashCode;
}
