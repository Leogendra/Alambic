import '../../domain/presets/built_in_preset_key.dart';
import '../../domain/presets/built_in_presets.dart';
import '../../domain/presets/grouped_reminder_action.dart';
import '../../domain/presets/notification_mode.dart';
import '../../domain/presets/preset.dart';
import '../../domain/presets/schedule_kind.dart';
import '../../domain/presets/scheduling_engine_kind.dart';
import '../../l10n/generated/app_localizations.dart';

/// One-line descriptions of a preset, as in "Sequence · 12:00 · one notification per card".
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

  String presetSummary(Preset preset) => presetSummaryFormat(
    presetEngineName(preset.engine),
    presetScheduleLabel(preset),
    presetModeLabel(preset),
  );

  String presetEngineName(SchedulingEngineKind engine) => switch (engine) {
    SchedulingEngineKind.sequence => presetEngineSequence,
    SchedulingEngineKind.adaptive => presetEngineAdaptive,
  };

  String presetScheduleLabel(Preset preset) => switch (preset.scheduleKind) {
    ScheduleKind.fixedTime => preset.fixedTime.toString(),
    ScheduleKind.timeRange => presetRange(
      preset.rangeStart.toString(),
      preset.rangeEnd.toString(),
    ),
  };

  String presetModeLabel(Preset preset) => switch (preset.notificationMode) {
    NotificationMode.perCard => presetModePerCard,
    NotificationMode.grouped => switch (preset.groupedAction) {
      GroupedReminderAction.openApp => presetModeGrouped,
      GroupedReminderAction.chainInNotification => presetModeGroupedChained,
    },
  };
}
