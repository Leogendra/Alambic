import 'timeline_day.dart';

/// What Home shows: today, always first, then the following days that have
/// something coming, and the cards expected further on.
class HomeTimeline {
  const HomeTimeline({
    required this.days,
    required this.comingMonth,
    required this.comingYear,
  });

  final List<TimelineDay> days;

  /// Reminders and new cards expected from the 8th to the 30th day.
  final int comingMonth;

  /// Reminders and new cards expected from the 31st to the 365th day.
  final int comingYear;

  TimelineDay get today => days.first;
}
