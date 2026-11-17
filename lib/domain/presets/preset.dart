import 'built_in_preset_key.dart';
import 'failure_behavior.dart';
import 'preset_interval.dart';
import 'sequence_end_behavior.dart';

/// The rhythm of the reviews: a fixed sequence of intervals walked step by
/// step. A group or a card picks a whole preset: there is no field-by-field
/// override.
class Preset {
  const Preset({
    required this.id,
    required this.name,
    required this.builtInKey,
    required this.intervals,
    required this.failureBehavior,
    required this.endBehavior,
    required this.typedAnswer,
  });

  final int id;
  final String name;
  final BuiltInPresetKey? builtInKey;
  final List<PresetInterval> intervals;
  final FailureBehavior failureBehavior;
  final SequenceEndBehavior endBehavior;
  final bool typedAnswer;

  /// Number of steps of the sequence; the last valid step index is `length - 1`.
  int get sequenceLength => intervals.length;

  Preset copyWith({
    int? id,
    String? name,
    BuiltInPresetKey? Function()? builtInKey,
    List<PresetInterval>? intervals,
    FailureBehavior? failureBehavior,
    SequenceEndBehavior? endBehavior,
    bool? typedAnswer,
  }) => Preset(
    id: id ?? this.id,
    name: name ?? this.name,
    builtInKey: builtInKey != null ? builtInKey() : this.builtInKey,
    intervals: intervals ?? this.intervals,
    failureBehavior: failureBehavior ?? this.failureBehavior,
    endBehavior: endBehavior ?? this.endBehavior,
    typedAnswer: typedAnswer ?? this.typedAnswer,
  );
}
