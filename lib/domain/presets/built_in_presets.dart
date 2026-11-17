import 'built_in_preset_key.dart';
import 'failure_behavior.dart';
import 'interval_unit.dart';
import 'preset.dart';
import 'preset_interval.dart';

/// Presets created on first launch. Their [Preset.id] is 0 until stored.
abstract final class BuiltInPresets {
  static const Preset standard = Preset(
    id: 0,
    name: 'Standard',
    builtInKey: BuiltInPresetKey.standard,
    intervals: [
      PresetInterval(1, IntervalUnit.day),
      PresetInterval(2, IntervalUnit.day),
      PresetInterval(1, IntervalUnit.week),
      PresetInterval(1, IntervalUnit.month),
      PresetInterval(3, IntervalUnit.month),
      PresetInterval(6, IntervalUnit.month),
    ],
    failureBehavior: FailureBehavior.stepBack,
  );

  static const Preset intensive = Preset(
    id: 0,
    name: 'Intensif',
    builtInKey: BuiltInPresetKey.intensive,
    intervals: [
      PresetInterval(10, IntervalUnit.minute),
      PresetInterval(1, IntervalUnit.hour),
      PresetInterval(1, IntervalUnit.day),
      PresetInterval(3, IntervalUnit.day),
      PresetInterval(1, IntervalUnit.week),
    ],
    failureBehavior: FailureBehavior.stepBack,
  );

  static const List<Preset> all = [standard, intensive];

  static Preset of(BuiltInPresetKey key) => switch (key) {
    BuiltInPresetKey.standard => standard,
    BuiltInPresetKey.intensive => intensive,
  };
}
