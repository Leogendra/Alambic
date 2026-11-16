import '../../domain/cards/flashcard.dart';

/// A card reminder on Home's timeline.
class TimelineCard {
  const TimelineCard({
    required this.card,
    required this.at,
    this.isLate = false,
    this.isExtraReminder = false,
  });

  final Flashcard card;

  /// Moment of the reminder: the due moment of the card, or the moment of
  /// its "Review soon" reminder.
  final DateTime at;

  /// Due on an earlier day and still not answered.
  final bool isLate;

  /// A "Review soon" reminder rather than a due review.
  final bool isExtraReminder;
}
