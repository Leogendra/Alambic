import '../../domain/presets/built_in_preset_key.dart';
import '../../domain/presets/built_in_presets.dart';
import '../../domain/presets/preset.dart';
import '../../domain/presets/scheduling_engine_kind.dart';
import '../../l10n/generated/app_localizations.dart';
import 'interval_labels.dart';

/// Names and one-line descriptions of a preset.
extension PresetLabels on AppLocalizations {
  /// The name shown for [preset]. A shipped preset never renamed reads in the
  /// language of the interface; any other preset keeps the name it was given.
  String presetName(Preset preset) {
    final key = preset.builtInKey;
    if (key != null && preset.name == BuiltInPresets.of(key).name) {
      return builtInPresetName(key);
    } else {
      return preset.name;
    }
  }

  String builtInPresetName(BuiltInPresetKey key) => switch (key) {
    BuiltInPresetKey.standard => presetNameStandard,
    BuiltInPresetKey.intensive => presetNameIntensive,
    BuiltInPresetKey.adaptive => presetNameAdaptive,
  };

  /// The steps of a sequence ("1 j · 2 j · 1 sem"), or the computed
  /// intervals of the adaptive engine.
  String presetStepsSummary(Preset preset) => switch (preset.engine) {
    SchedulingEngineKind.sequence =>
      preset.intervals.map(intervalLabel).join(' · '),
    SchedulingEngineKind.adaptive => presetComputedIntervals,
  };
}
