import '../../domain/presets/preset.dart';

/// One line of today's timeline: the reminders of a group at a moment, the
/// new cards a distillation introduces at that moment, or the "Review soon"
/// reminders falling at that moment.
class TimelineEntry {
  const TimelineEntry({
    required this.at,
    required this.groupId,
    required this.preset,
    required this.count,
    required this.isExtraReminder,
    this.distillingGroupId,
  });

  final DateTime at;

  /// `null` for extra reminders.
  final int? groupId;

  /// Preset of the group, deciding how its reminders are notified; `null` for
  /// extra reminders.
  final Preset? preset;

  /// Cards still waiting at this moment.
  final int count;
  final bool isExtraReminder;

  /// Set for the new cards of a distillation ("New knowledge"): the group
  /// that distills them.
  final int? distillingGroupId;
}
