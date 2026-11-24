import '../../domain/cards/flashcard.dart';

/// A card reminder on Home's timeline.
class TimelineCard {
  const TimelineCard({
    required this.card,
    required this.at,
    this.isLate = false,
    this.delay,
  });

  final Flashcard card;

  /// Moment of the reminder: the due moment of the card.
  final DateTime at;

  /// Due on an earlier day and still not answered.
  final bool isLate;

  /// Time left before the reminder; `null` once its moment has passed.
  final TimelineDelay? delay;
}

/// Time left before a reminder, as Home shows it: in hours today, rounded
/// up, and in days afterwards.
class TimelineDelay {
  const TimelineDelay.hours(this.count) : inDays = false;

  const TimelineDelay.days(this.count) : inDays = true;

  final int count;
  final bool inDays;

  @override
  bool operator ==(Object other) =>
      other is TimelineDelay && other.count == count && other.inDays == inDays;

  @override
  int get hashCode => Object.hash(count, inDays);

  @override
  String toString() => '$count${inDays ? 'd' : 'h'}';
}
