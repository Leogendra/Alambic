import '../scheduling/clock_time.dart';

/// Limits set on the notifications of every group, in Settings.
class NotificationGuards {
  const NotificationGuards({
    required this.dailyCap,
    required this.quietHoursEnabled,
    required this.quietStart,
    required this.quietEnd,
    required this.autoGroupEnabled,
    required this.autoGroupThreshold,
  });

  static const NotificationGuards defaults = NotificationGuards(
    dailyCap: 20,
    quietHoursEnabled: true,
    quietStart: ClockTime(22, 0),
    quietEnd: ClockTime(8, 0),
    autoGroupEnabled: true,
    autoGroupThreshold: 5,
  );

  /// Cards notified per day at most.
  final int dailyCap;

  /// "Do not disturb": notifications falling between [quietStart] and
  /// [quietEnd] are moved to [quietEnd].
  final bool quietHoursEnabled;
  final ClockTime quietStart;
  final ClockTime quietEnd;

  /// More than [autoGroupThreshold] notifications at the same moment are
  /// replaced by a single one.
  final bool autoGroupEnabled;
  final int autoGroupThreshold;

  /// Whether [time] falls in the quiet hours, which may span midnight.
  bool isQuiet(ClockTime time) {
    if (!quietHoursEnabled || quietStart == quietEnd) {
      return false;
    } else if (quietStart.compareTo(quietEnd) < 0) {
      return time.compareTo(quietStart) >= 0 && time.compareTo(quietEnd) < 0;
    } else {
      return time.compareTo(quietStart) >= 0 || time.compareTo(quietEnd) < 0;
    }
  }

  /// Whether [count] notifications at the same moment are replaced by one.
  bool groupsAutomatically(int count) =>
      autoGroupEnabled && count > autoGroupThreshold;

  NotificationGuards copyWith({
    int? dailyCap,
    bool? quietHoursEnabled,
    ClockTime? quietStart,
    ClockTime? quietEnd,
    bool? autoGroupEnabled,
    int? autoGroupThreshold,
  }) => NotificationGuards(
    dailyCap: dailyCap ?? this.dailyCap,
    quietHoursEnabled: quietHoursEnabled ?? this.quietHoursEnabled,
    quietStart: quietStart ?? this.quietStart,
    quietEnd: quietEnd ?? this.quietEnd,
    autoGroupEnabled: autoGroupEnabled ?? this.autoGroupEnabled,
    autoGroupThreshold: autoGroupThreshold ?? this.autoGroupThreshold,
  );
}
