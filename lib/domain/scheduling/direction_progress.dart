import '../cards/card_direction.dart';
import '../presets/preset.dart';
import '../presets/scheduling_engine_kind.dart';
import 'fsrs/fsrs_engine.dart';
import 'fsrs/fsrs_memory.dart';
import 'sequence_engine.dart';

/// Where a direction stands in the engine of its preset.
///
/// Each engine reads only its own progression: a step for the sequence, a
/// memory for FSRS. A progression left by the other engine does not count, so
/// a direction whose preset changed engine starts over.
sealed class DirectionProgress {
  const DirectionProgress();

  factory DirectionProgress.of(CardDirection direction, Preset preset) {
    switch (preset.engine) {
      case SchedulingEngineKind.sequence:
        final step = SequenceEngine.clampToSequence(direction.step, preset);
        return step == null
            ? const NewProgress()
            : SequenceProgress(
                step: step,
                sequenceLength: preset.sequenceLength,
                interval: preset.intervals[step].length,
              );
      case SchedulingEngineKind.adaptive:
        final memory = direction.memory;
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

  /// Interval the direction currently waits, used to rank directions; zero
  /// for a direction never answered.
  Duration get waitedInterval;
}

/// Never answered with the engine of the preset.
final class NewProgress extends DirectionProgress {
  const NewProgress();

  @override
  Duration get waitedInterval => Duration.zero;
}

/// At [step] of a sequence of [sequenceLength] steps.
final class SequenceProgress extends DirectionProgress {
  const SequenceProgress({
    required this.step,
    required this.sequenceLength,
    required this.interval,
  });

  final int step;
  final int sequenceLength;
  final Duration interval;

  @override
  Duration get waitedInterval => interval;
}

/// Followed by FSRS, which spaces its reviews by [intervalDays].
final class AdaptiveProgress extends DirectionProgress {
  const AdaptiveProgress({required this.memory, required this.intervalDays});

  final FsrsMemory memory;

  /// Interval given by the memory and the target retention of the preset.
  final int intervalDays;

  @override
  Duration get waitedInterval => Duration(days: intervalDays);
}
