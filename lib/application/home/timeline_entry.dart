import '../../domain/presets/preset.dart';

/// One line of today's timeline: the reminders of a group at a moment, or the
/// "Review soon" reminders falling at that moment.
class TimelineEntry {
  const TimelineEntry({
    required this.at,
    required this.groupId,
    required this.preset,
    required this.count,
    required this.isExtraReminder,
  });

  final DateTime at;

  /// `null` for "No group", and for extra reminders.
  final int? groupId;

  /// Preset of the group, deciding how its reminders are notified; `null` for
  /// extra reminders.
  final Preset? preset;

  /// Directions still waiting at this moment.
  final int count;
  final bool isExtraReminder;
}
