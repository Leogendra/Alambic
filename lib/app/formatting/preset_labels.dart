import '../../domain/presets/built_in_preset_key.dart';
import '../../domain/presets/built_in_presets.dart';
import '../../domain/presets/failure_behavior.dart';
import '../../domain/presets/preset.dart';
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
  };

  /// The steps of the sequence: "1 d · 2 d · 1 wk".
  String presetStepsSummary(Preset preset) =>
      preset.intervals.map(intervalLabel).join(' · ');

  /// The failure behaviour in a few words, for a preset tile: "one step
  /// back".
  String failureSummary(FailureBehavior behavior) => switch (behavior) {
    FailureBehavior.stepBack => presetFailureStepBackShort,
    FailureBehavior.restart => presetFailureRestartShort,
    FailureBehavior.stay => presetFailureStayShort,
  };

  /// The name of a failure behaviour: "One step back".
  String failureLabel(FailureBehavior behavior) => switch (behavior) {
    FailureBehavior.stepBack => presetFailureStepBack,
    FailureBehavior.restart => presetFailureRestart,
    FailureBehavior.stay => presetFailureStay,
  };

  /// What a missed card does: "A missed card goes back to the previous step."
  String failureEffect(FailureBehavior behavior) => switch (behavior) {
    FailureBehavior.stepBack => presetFailureStepBackEffect,
    FailureBehavior.restart => presetFailureRestartEffect,
    FailureBehavior.stay => presetFailureStayEffect,
  };
}
