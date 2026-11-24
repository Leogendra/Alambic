import 'group_reminder_key.dart';

/// Identifies a review notification: the reminder of a due card, or the card
/// currently asked in the grouped reminder [chain].
class ReviewNotificationKey {
  const ReviewNotificationKey({required this.cardId, this.chain});

  final int cardId;

  /// Grouped reminder whose cards are chained in the notification; answering
  /// shows its next card.
  final GroupReminderKey? chain;

  @override
  bool operator ==(Object other) =>
      other is ReviewNotificationKey &&
      other.cardId == cardId &&
      other.chain == chain;

  @override
  int get hashCode => Object.hash(cardId, chain);
}
