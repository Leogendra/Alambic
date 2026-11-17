import '../../data/repositories/card_repository.dart';
import '../../domain/scheduling/due_policy.dart';
import '../clock.dart';
import '../reviews/due_queue.dart';
import '../reviews/session_item.dart';
import '../reviews/session_item_factory.dart';
import 'notification_target.dart';

/// The session opened by touching a notification: whoever touches it can
/// review at once everything waiting for them.
class NotificationSession {
  const NotificationSession({
    required this._cards,
    required this._duePolicy,
    required this._sessionItems,
    required this._clock,
  });

  final CardRepository _cards;
  final DuePolicy _duePolicy;
  final SessionItemFactory _sessionItems;
  final Clock _clock;

  /// The card of [target] first, asking the face of its notification, then
  /// the due cards of its group, then every other due card, earliest due
  /// first. Empty when nothing is left to review.
  Future<List<SessionItem>> itemsFor(NotificationTarget target) async {
    final cardId = target.cardId;
    final touched = cardId == null ? null : await _cards.findCard(cardId);
    final cards = await _cards.getAll();
    final due = [
      for (final item in DueQueue(_duePolicy).build(cards, _clock()))
        if (item.card.id != cardId) item,
    ];
    return [
      if (touched != null)
        SessionItem(cardId: touched.id, askedSide: target.askedSide!),
      ...await _sessionItems.itemsFor([
        for (final item in due)
          if (item.groupId == target.groupId) item.card.id,
        for (final item in due)
          if (item.groupId != target.groupId) item.card.id,
      ]),
    ];
  }
}
