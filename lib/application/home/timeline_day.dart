import 'timeline_arrival.dart';
import 'timeline_card.dart';

/// One day of Home's timeline: its card reminders, late ones first, and the
/// new cards of each group.
class TimelineDay {
  const TimelineDay({
    required this.day,
    required this.isToday,
    required this.cards,
    required this.arrivals,
  });

  /// The scheduling day.
  final DateTime day;
  final bool isToday;
  final List<TimelineCard> cards;
  final List<TimelineArrival> arrivals;

  bool get isEmpty => cards.isEmpty && arrivals.isEmpty;
}
