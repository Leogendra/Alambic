import '../cards/flashcard.dart';
import '../presets/preset.dart';
import '../presets/preset_interval.dart';
import 'sequence_engine.dart';

/// Where a card stands in the sequence of its preset.
sealed class CardProgress {
  const CardProgress();

  /// The step is read against the current sequence: a step kept from a longer
  /// one counts as the last step.
  factory CardProgress.of(Flashcard card, Preset preset) {
    final step = SequenceEngine.clampToSequence(card.step, preset);
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
