import 'timeline_entry.dart';

/// What the home screen shows about today.
class TodayOverview {
  const TodayOverview({
    required this.dueCount,
    required this.doneCount,
    required this.timeline,
  });

  /// Cards to review now.
  final int dueCount;

  /// Cards answered today, bonus reviews excluded.
  final int doneCount;

  /// Today's reminders, in time order, past ones included.
  final List<TimelineEntry> timeline;

  /// Index of the first entry still ahead, or `null` when the day is over.
  int? nextIndex(DateTime now) {
    final index = timeline.indexWhere((entry) => entry.at.isAfter(now));
    return index < 0 ? null : index;
  }
}
