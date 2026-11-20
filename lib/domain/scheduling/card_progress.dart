import '../cards/card_state.dart';
import '../cards/flashcard.dart';
import '../groups/sequence_end.dart';
import '../presets/preset.dart';
import '../presets/preset_interval.dart';

/// Where a card stands in the sequence of its preset.
sealed class CardProgress {
  const CardProgress();

  /// The step is read against the current sequence: a step kept from a longer
  /// one counts as the last step. A completed card stays past the sequence
  /// whatever its length, and waits the remanence interval its group gives
  /// after [preset].
  factory CardProgress.of(Flashcard card, Preset preset, SequenceEnd end) {
    if (card.state == CardState.completed) {
      return RemanenceProgress(
        sequenceLength: preset.sequenceLength,
        interval: end.remanenceAfter(preset),
      );
    }
    final step = preset.clampStep(card.step);
    return step == null
        ? const NewProgress()
        : SequenceProgress(
            step: step,
            sequenceLength: preset.sequenceLength,
            interval: preset.intervals[step],
          );
  }

  /// Interval the card currently waits, used to rank cards; zero for a card
  /// never answered.
  Duration get waitedInterval;
}

/// Never answered.
final class NewProgress extends CardProgress {
  const NewProgress();

  @override
  Duration get waitedInterval => Duration.zero;
}

/// At [step] of a sequence of [sequenceLength] steps, waiting [interval].
final class SequenceProgress extends CardProgress {
  const SequenceProgress({
    required this.step,
    required this.sequenceLength,
    required this.interval,
  });

  final int step;
  final int sequenceLength;
  final PresetInterval interval;

  @override
  Duration get waitedInterval => interval.length;
}

/// Past the [sequenceLength] steps of the sequence, coming back every
/// [interval].
final class RemanenceProgress extends CardProgress {
  const RemanenceProgress({
    required this.sequenceLength,
    required this.interval,
  });

  final int sequenceLength;
  final PresetInterval interval;

  @override
  Duration get waitedInterval => interval.length;
}
