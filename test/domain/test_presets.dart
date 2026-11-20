import 'package:alambic/domain/presets/built_in_presets.dart';
import 'package:alambic/domain/presets/failure_behavior.dart';
import 'package:alambic/domain/presets/interval_unit.dart';
import 'package:alambic/domain/presets/preset.dart';
import 'package:alambic/domain/presets/preset_interval.dart';

/// Standard preset with an id, as stored.
final Preset standardPreset = BuiltInPresets.standard.copyWith(id: 1);

final Preset intensivePreset = BuiltInPresets.intensive.copyWith(id: 2);

/// Short sequence "1 d, 2 d, 4 d" to reach the end quickly.
Preset shortSequence({
  FailureBehavior failureBehavior = FailureBehavior.stepBack,
}) => standardPreset.copyWith(
  id: 3,
  intervals: const [
    PresetInterval(1, IntervalUnit.day),
    PresetInterval(2, IntervalUnit.day),
    PresetInterval(4, IntervalUnit.day),
  ],
  failureBehavior: failureBehavior,
);
