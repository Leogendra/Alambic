import '../../data/repositories/card_repository.dart';
import '../../domain/cards/card_side.dart';
import '../../domain/reviews/review_outcome.dart';
import '../../domain/reviews/review_source.dart';
import '../../domain/reviews/typed_answer_match.dart';
import '../clock.dart';
import '../reviews/review_service.dart';
import 'answer_reveal.dart';
import 'group_reminder_key.dart';
import 'grouped_reminders.dart';
import 'notification_action.dart';
import 'notification_presenter.dart';
import 'review_notification_key.dart';

/// Handles a button pressed on a review notification, without opening the
/// app. The answer goes through the same service as an in-app session.
class NotificationActionHandler {
  const NotificationActionHandler({
    required this._cards,
    required this._reviews,
    required this._groupedReminders,
    required this._presenter,
    required this._clock,
  });

  final CardRepository _cards;
  final ReviewService _reviews;
  final GroupedReminders _groupedReminders;
  final NotificationPresenter _presenter;
  final Clock _clock;

  /// "Correct" closes the notification; "Again" replaces it with the
  /// expected answer, the face opposite [askedSide], and an "OK" button. A typed answer counts as "Correct"
  /// when it matches the expected one and as "Again" otherwise, and is always
  /// followed by the expected answer. Answering an extra reminder is a bonus
  /// review. A card deleted meanwhile only closes the notification.
  ///
  /// In a grouped reminder whose cards are chained, the next card replaces
  /// the one answered, or the expected answer once acknowledged.
  Future<void> handle(
    ReviewNotificationKey key,
    NotificationAction action, {
    String? input,
    CardSide askedSide = CardSide.front,
  }) async {
    final card = await _cards.findCard(key.cardId);
    if (action == NotificationAction.acknowledge || card == null) {
      await _close(key);
      return;
    }
    final answer = card.answerFor(askedSide).text ?? '';
    final typed = action == NotificationAction.answer ? input ?? '' : null;
    final match = typed == null
        ? null
        : TypedAnswerMatch.compare(typed, answer);
    final outcome = switch (action) {
      NotificationAction.correct => ReviewOutcome.correct,
      NotificationAction.answer when match!.isAccepted => ReviewOutcome.correct,
      _ => ReviewOutcome.again,
    };
    final result = await _reviews.answer(
      key.cardId,
      outcome,
      source: ReviewSource.notification,
      forceBonus: key.isExtraReminder,
    );
    if (action == NotificationAction.correct) {
      await _close(key);
    } else {
      await _presenter.showReveal(
        AnswerReveal(
          key: key,
          askedSide: askedSide,
          prompt: card.promptFor(askedSide).text ?? '',
          answer: answer,
          answerImage: card.answerFor(askedSide).imagePath,
          result: result,
          answeredAt: _clock(),
          typed: typed,
          match: match,
        ),
      );
    }
  }

  /// "Start here" on a grouped reminder asks its first card.
  Future<void> handleGroup(
    GroupReminderKey key,
    NotificationAction action,
  ) async {
    if (action == NotificationAction.start) {
      await _groupedReminders.showNext(key);
    }
  }

  Future<void> _close(ReviewNotificationKey key) async {
    final chain = key.chain;
    if (chain == null) {
      await _presenter.dismiss(key);
    } else {
      await _groupedReminders.showNext(chain);
    }
  }
}
