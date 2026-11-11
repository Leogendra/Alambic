/// Identifies a review notification: the reminder of a due direction, or a
/// "Review soon" reminder of it when [extraReminderId] is set.
class ReviewNotificationKey {
  const ReviewNotificationKey({
    required this.directionId,
    this.extraReminderId,
  });

  final int directionId;
  final int? extraReminderId;

  /// Answering an extra reminder is always a bonus review.
  bool get isExtraReminder => extraReminderId != null;

  @override
  bool operator ==(Object other) =>
      other is ReviewNotificationKey &&
      other.directionId == directionId &&
      other.extraReminderId == extraReminderId;

  @override
  int get hashCode => Object.hash(directionId, extraReminderId);
}
