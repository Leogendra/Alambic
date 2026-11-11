import 'package:remanence/domain/presets/built_in_presets.dart';
import 'package:remanence/domain/presets/failure_behavior.dart';
import 'package:remanence/domain/presets/interval_unit.dart';
import 'package:remanence/domain/presets/preset.dart';
import 'package:remanence/domain/presets/preset_interval.dart';
import 'package:remanence/domain/presets/sequence_end_behavior.dart';

/// Standard preset with an id, as stored.
final Preset standardPreset = BuiltInPresets.standard.copyWith(id: 1);

final Preset intensivePreset = BuiltInPresets.intensive.copyWith(id: 2);

/// Short sequence "1 j, 2 j, 4 j" to reach the end quickly.
Preset shortSequence({
  FailureBehavior failureBehavior = FailureBehavior.stepBack,
  SequenceEndBehavior endBehavior = SequenceEndBehavior.repeatLast,
}) => standardPreset.copyWith(
  id: 3,
  intervals: const [
    PresetInterval(1, IntervalUnit.day),
    PresetInterval(2, IntervalUnit.day),
    PresetInterval(4, IntervalUnit.day),
  ],
  failureBehavior: failureBehavior,
  endBehavior: endBehavior,
);
