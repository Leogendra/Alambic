import '../../data/repositories/card_repository.dart';
import '../../domain/reviews/review_outcome.dart';
import '../../domain/reviews/review_source.dart';
import '../clock.dart';
import '../reviews/review_service.dart';
import 'answer_reveal.dart';
import 'notification_action.dart';
import 'notification_presenter.dart';
import 'review_notification_key.dart';

/// Handles a button pressed on a review notification, without opening the
/// app. The answer goes through the same service as an in-app session.
class NotificationActionHandler {
  const NotificationActionHandler({
    required this._cards,
    required this._reviews,
    required this._presenter,
    required this._clock,
  });

  final CardRepository _cards;
  final ReviewService _reviews;
  final NotificationPresenter _presenter;
  final Clock _clock;

  /// "Correct" closes the notification; "Again" replaces it with the
  /// expected answer and an "OK" button. Answering an extra reminder is a
  /// bonus review. A card deleted meanwhile only closes the notification.
  Future<void> handle(
    ReviewNotificationKey key,
    NotificationAction action,
  ) async {
    final outcome = switch (action) {
      NotificationAction.correct => ReviewOutcome.correct,
      NotificationAction.again => ReviewOutcome.again,
      NotificationAction.acknowledge => null,
    };
    final direction = await _cards.findDirection(key.directionId);
    if (outcome == null || direction == null) {
      await _presenter.dismiss(key);
      return;
    }
    final result = await _reviews.answer(
      key.directionId,
      outcome,
      source: ReviewSource.notification,
      forceBonus: key.isExtraReminder,
    );
    if (outcome == ReviewOutcome.again) {
      final card = await _cards.getCard(direction.cardId);
      await _presenter.showReveal(
        AnswerReveal(
          key: key,
          prompt: card.promptFor(direction.sense).text ?? '',
          answer: card.answerFor(direction.sense).text ?? '',
          result: result,
          answeredAt: _clock(),
        ),
      );
    } else {
      await _presenter.dismiss(key);
    }
  }
}
