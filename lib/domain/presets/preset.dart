import 'built_in_preset_key.dart';
import 'failure_behavior.dart';
import 'preset_interval.dart';
import 'scheduling_engine_kind.dart';
import 'sequence_end_behavior.dart';

/// A complete set of repetition rules. A group or a card picks a whole preset:
/// there is no field-by-field override.
class Preset {
  const Preset({
    required this.id,
    required this.name,
    required this.builtInKey,
    required this.engine,
    required this.intervals,
    required this.failureBehavior,
    required this.endBehavior,
    required this.typedAnswer,
    required this.targetRetention,
  });

  final int id;
  final String name;
  final BuiltInPresetKey? builtInKey;
  final SchedulingEngineKind engine;
  final List<PresetInterval> intervals;
  final FailureBehavior failureBehavior;
  final SequenceEndBehavior endBehavior;
  final bool typedAnswer;

  /// Probability of recalling a card on its due date aimed at by the adaptive
  /// engine, between [minRetention] and [maxRetention].
  final double targetRetention;

  static const double minRetention = 0.7;
  static const double maxRetention = 0.97;

  /// Number of steps of the sequence; the last valid step index is `length - 1`.
  int get sequenceLength => intervals.length;

  Preset copyWith({
    int? id,
    String? name,
    BuiltInPresetKey? Function()? builtInKey,
    SchedulingEngineKind? engine,
    List<PresetInterval>? intervals,
    FailureBehavior? failureBehavior,
    SequenceEndBehavior? endBehavior,
    bool? typedAnswer,
    double? targetRetention,
  }) => Preset(
    id: id ?? this.id,
    name: name ?? this.name,
    builtInKey: builtInKey != null ? builtInKey() : this.builtInKey,
    engine: engine ?? this.engine,
    intervals: intervals ?? this.intervals,
    failureBehavior: failureBehavior ?? this.failureBehavior,
    endBehavior: endBehavior ?? this.endBehavior,
    typedAnswer: typedAnswer ?? this.typedAnswer,
    targetRetention: targetRetention ?? this.targetRetention,
  );
}
