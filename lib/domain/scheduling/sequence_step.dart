import '../presets/preset_interval.dart';

/// Position reached in a sequence after an answer.
class SequenceStep {
  const SequenceStep.scheduled(int this.step, PresetInterval this.interval)
    : acquired = false;

  const SequenceStep.acquired() : step = null, interval = null, acquired = true;

  /// Index of the interval now waited; `null` once acquired.
  final int? step;

  /// Interval to wait before the next review; `null` once acquired.
  final PresetInterval? interval;
  final bool acquired;
}
