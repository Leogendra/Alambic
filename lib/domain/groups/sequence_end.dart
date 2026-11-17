import '../presets/preset.dart';
import '../presets/preset_interval.dart';
import 'after_last_step.dart';
import 'remanence_interval.dart';

/// How a group ends the sequence of its preset. It belongs to the group, not
/// to the preset, so that two groups can share a rhythm and end it
/// differently.
class SequenceEnd {
  const SequenceEnd({
    required this.afterLastStep,
    required this.remanenceInterval,
  });

  /// Remanence every 6 months: the end of a new group.
  static const SequenceEnd standard = SequenceEnd(
    afterLastStep: AfterLastStep.remanence,
    remanenceInterval: RemanenceInterval.sixMonths,
  );

  final AfterLastStep afterLastStep;
  final RemanenceInterval remanenceInterval;

  /// Interval waited in remanence after the sequence of [preset]: the
  /// interval of the group, or the last step when it is longer, so that a
  /// short preset does not come back more often in remanence than in its
  /// sequence.
  PresetInterval remanenceAfter(Preset preset) {
    final groupInterval = remanenceInterval.interval;
    final lastStep = preset.intervals.last;
    return lastStep.length > groupInterval.length ? lastStep : groupInterval;
  }

  @override
  bool operator ==(Object other) =>
      other is SequenceEnd &&
      other.afterLastStep == afterLastStep &&
      other.remanenceInterval == remanenceInterval;

  @override
  int get hashCode => Object.hash(afterLastStep, remanenceInterval);
}
