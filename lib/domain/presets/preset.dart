import 'dart:math';

import 'built_in_preset_key.dart';
import 'failure_behavior.dart';
import 'preset_interval.dart';

/// The rhythm of the reviews: a fixed sequence of intervals walked step by
/// step. A group picks a whole preset or inherits the global one: there is no
/// field-by-field override. What happens after the last step is set by the
/// group, not by the preset.
class Preset {
  const Preset({
    required this.id,
    required this.name,
    required this.builtInKey,
    required this.intervals,
    required this.failureBehavior,
  });

  final int id;
  final String name;
  final BuiltInPresetKey? builtInKey;
  final List<PresetInterval> intervals;
  final FailureBehavior failureBehavior;

  /// Number of steps of the sequence; the last valid step index is `length - 1`.
  int get sequenceLength => intervals.length;

  int get lastStep => sequenceLength - 1;

  /// A step kept from a longer sequence is brought back to the last step.
  int? clampStep(int? step) => step == null ? null : min(step, lastStep);

  Preset copyWith({
    int? id,
    String? name,
    BuiltInPresetKey? Function()? builtInKey,
    List<PresetInterval>? intervals,
    FailureBehavior? failureBehavior,
  }) => Preset(
    id: id ?? this.id,
    name: name ?? this.name,
    builtInKey: builtInKey != null ? builtInKey() : this.builtInKey,
    intervals: intervals ?? this.intervals,
    failureBehavior: failureBehavior ?? this.failureBehavior,
  );
}
