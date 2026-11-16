import 'timeline_day.dart';

/// What Home shows: today, always first, then the following days that have
/// something coming.
class HomeTimeline {
  const HomeTimeline(this.days);

  final List<TimelineDay> days;

  TimelineDay get today => days.first;
}
