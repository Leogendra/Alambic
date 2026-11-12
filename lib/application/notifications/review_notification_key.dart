import 'group_reminder_key.dart';

/// Identifies a review notification: the reminder of a due direction, a
/// "Review soon" reminder of it when [extraReminderId] is set, or the card
/// currently asked in the grouped reminder [chain].
class ReviewNotificationKey {
  const ReviewNotificationKey({
    required this.directionId,
    this.extraReminderId,
    this.chain,
  });

  final int directionId;
  final int? extraReminderId;

  /// Grouped reminder whose cards are chained in the notification; answering
  /// shows its next card.
  final GroupReminderKey? chain;

  /// Answering an extra reminder is always a bonus review.
  bool get isExtraReminder => extraReminderId != null;

  @override
  bool operator ==(Object other) =>
      other is ReviewNotificationKey &&
      other.directionId == directionId &&
      other.extraReminderId == extraReminderId &&
      other.chain == chain;

  @override
  int get hashCode => Object.hash(directionId, extraReminderId, chain);
}
