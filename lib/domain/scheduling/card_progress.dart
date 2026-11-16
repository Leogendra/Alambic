import '../cards/flashcard.dart';
import '../presets/preset.dart';
import '../presets/preset_interval.dart';
import '../presets/scheduling_engine_kind.dart';
import 'fsrs/fsrs_engine.dart';
import 'fsrs/fsrs_memory.dart';
import 'sequence_engine.dart';

/// Where a card stands in the engine of its preset.
///
/// Each engine reads only its own progression: a step for the sequence, a
/// memory for FSRS. A progression left by the other engine does not count, so
/// a card whose preset changed engine starts over.
sealed class CardProgress {
  const CardProgress();

  factory CardProgress.of(Flashcard card, Preset preset) {
    switch (preset.engine) {
      case SchedulingEngineKind.sequence:
        final step = SequenceEngine.clampToSequence(card.step, preset);
        return step == null
            ? const NewProgress()
            : SequenceProgress(
                step: step,
                sequenceLength: preset.sequenceLength,
                interval: preset.intervals[step],
              );
      case SchedulingEngineKind.adaptive:
        final memory = card.memory;
        return memory == null
            ? const NewProgress()
            : AdaptiveProgress(
                memory: memory,
                intervalDays: FsrsEngine.intervalDays(
                  memory.stability,
                  preset.targetRetention,
                ),
              );
    }
  }

  /// Interval the card currently waits, used to rank cards; zero for a card
  /// never answered.
  Duration get waitedInterval;
}

/// Never answered with the engine of the preset.
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

/// Followed by FSRS, which spaces its reviews by [intervalDays].
final class AdaptiveProgress extends CardProgress {
  const AdaptiveProgress({required this.memory, required this.intervalDays});

  final FsrsMemory memory;

  /// Interval given by the memory and the target retention of the preset.
  final int intervalDays;

  @override
  Duration get waitedInterval => Duration(days: intervalDays);
}
