import '../scheduling/clock_time.dart';
import 'built_in_preset_key.dart';
import 'failure_behavior.dart';
import 'grouped_reminder_action.dart';
import 'interval_unit.dart';
import 'notification_mode.dart';
import 'preset.dart';
import 'preset_interval.dart';
import 'schedule_kind.dart';
import 'scheduling_engine_kind.dart';
import 'sequence_end_behavior.dart';

/// Presets created on first launch. Their [Preset.id] is 0 until stored.
abstract final class BuiltInPresets {
  static const ClockTime defaultTime = ClockTime(12, 0);

  static const Preset standard = Preset(
    id: 0,
    name: 'Standard',
    builtInKey: BuiltInPresetKey.standard,
    engine: SchedulingEngineKind.sequence,
    intervals: [
      PresetInterval(1, IntervalUnit.day),
      PresetInterval(2, IntervalUnit.day),
      PresetInterval(1, IntervalUnit.week),
      PresetInterval(1, IntervalUnit.month),
      PresetInterval(3, IntervalUnit.month),
      PresetInterval(6, IntervalUnit.month),
    ],
    failureBehavior: FailureBehavior.stepBack,
    endBehavior: SequenceEndBehavior.repeatLast,
    typedAnswer: false,
    scheduleKind: ScheduleKind.fixedTime,
    fixedTime: defaultTime,
    rangeStart: ClockTime(9, 0),
    rangeEnd: ClockTime(18, 0),
    notificationMode: NotificationMode.perCard,
    groupedAction: GroupedReminderAction.openApp,
    targetRetention: 0.9,
  );

  static const Preset intensive = Preset(
    id: 0,
    name: 'Intensif',
    builtInKey: BuiltInPresetKey.intensive,
    engine: SchedulingEngineKind.sequence,
    intervals: [
      PresetInterval(10, IntervalUnit.minute),
      PresetInterval(1, IntervalUnit.hour),
      PresetInterval(1, IntervalUnit.day),
      PresetInterval(3, IntervalUnit.day),
      PresetInterval(1, IntervalUnit.week),
    ],
    failureBehavior: FailureBehavior.stepBack,
    endBehavior: SequenceEndBehavior.repeatLast,
    typedAnswer: false,
    scheduleKind: ScheduleKind.fixedTime,
    fixedTime: defaultTime,
    rangeStart: ClockTime(9, 0),
    rangeEnd: ClockTime(18, 0),
    notificationMode: NotificationMode.perCard,
    groupedAction: GroupedReminderAction.openApp,
    targetRetention: 0.9,
  );

  /// FSRS, one grouped reminder per group. Its sequence, unused by the
  /// adaptive engine, is the Standard one, ready if the engine is switched.
  static const Preset adaptive = Preset(
    id: 0,
    name: 'Adaptatif',
    builtInKey: BuiltInPresetKey.adaptive,
    engine: SchedulingEngineKind.adaptive,
    intervals: [
      PresetInterval(1, IntervalUnit.day),
      PresetInterval(2, IntervalUnit.day),
      PresetInterval(1, IntervalUnit.week),
      PresetInterval(1, IntervalUnit.month),
      PresetInterval(3, IntervalUnit.month),
      PresetInterval(6, IntervalUnit.month),
    ],
    failureBehavior: FailureBehavior.stepBack,
    endBehavior: SequenceEndBehavior.repeatLast,
    typedAnswer: false,
    scheduleKind: ScheduleKind.fixedTime,
    fixedTime: defaultTime,
    rangeStart: ClockTime(9, 0),
    rangeEnd: ClockTime(18, 0),
    notificationMode: NotificationMode.grouped,
    groupedAction: GroupedReminderAction.openApp,
    targetRetention: defaultRetention,
  );

  /// Target retention of a new adaptive preset.
  static const double defaultRetention = 0.9;

  static const List<Preset> all = [standard, intensive, adaptive];

  static Preset of(BuiltInPresetKey key) => switch (key) {
    BuiltInPresetKey.standard => standard,
    BuiltInPresetKey.intensive => intensive,
    BuiltInPresetKey.adaptive => adaptive,
  };
}
