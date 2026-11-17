import '../../domain/cards/card_side.dart';

/// What a touched notification opens a session on: a card first, then the
/// due cards of a group first, then every due card.
class NotificationTarget {
  /// A card notification: this card, asking [askedSide] like the
  /// notification; a card chained in a grouped reminder also gives its
  /// [groupId].
  const NotificationTarget.card(
    int this.cardId,
    CardSide this.askedSide, {
    this.groupId,
  });

  /// A grouped reminder.
  const NotificationTarget.group(int this.groupId)
    : cardId = null,
      askedSide = null;

  /// The digest of a moment, or a notification whose card was answered.
  const NotificationTarget.allDue()
    : cardId = null,
      askedSide = null,
      groupId = null;

  final int? cardId;
  final CardSide? askedSide;
  final int? groupId;
}
