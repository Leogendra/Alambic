import '../presets/preset_interval.dart';

/// Position reached in a sequence after an answer.
sealed class SequenceStep {
  const SequenceStep();
}

/// At [step] of the sequence, waiting its [interval].
final class StepReached extends SequenceStep {
  const StepReached(this.step, this.interval);

  final int step;
  final PresetInterval interval;
}

/// Past the last step, coming back every [interval].
final class RemanenceReached extends SequenceStep {
  const RemanenceReached(this.interval);

  final PresetInterval interval;
}

/// Past the last step, with no more reminder.
final class AcquiredReached extends SequenceStep {
  const AcquiredReached();
}
