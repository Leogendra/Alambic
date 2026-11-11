import '../../domain/presets/grouped_reminder_action.dart';
import '../../domain/presets/notification_mode.dart';
import '../../domain/presets/preset.dart';
import '../../domain/presets/schedule_kind.dart';
import '../../domain/presets/scheduling_engine_kind.dart';
import '../../l10n/generated/app_localizations.dart';

/// One-line descriptions of a preset, as in "Séquence · 12:00 · une notif par carte".
extension PresetLabels on AppLocalizations {
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
