import '../../data/repositories/card_repository.dart';
import '../../data/repositories/group_repository.dart';
import '../../domain/cards/card_side.dart';
import '../../domain/cards/flashcard.dart';
import '../../domain/reviews/review_outcome.dart';
import '../../domain/reviews/review_source.dart';
import '../../domain/scheduling/card_schedule.dart';
import '../clock.dart';
import '../reviews/review_service.dart';
import 'answer_confirmation.dart';
import 'group_reminder_key.dart';
import 'grouped_reminders.dart';
import 'notification_action.dart';
import 'notification_presenter.dart';
import 'review_notification_key.dart';
import 'review_prompt.dart';
import 'typed_answer_verdict.dart';

/// Handles a button pressed on a review notification, without opening the
/// app. The answer goes through the same service as an in-app session.
class NotificationActionHandler {
  const NotificationActionHandler({
    required this._cards,
    required this._groups,
    required this._reviews,
    required this._groupedReminders,
    required this._presenter,
    required this._clock,
  });

  final CardRepository _cards;
  final GroupRepository _groups;
  final ReviewService _reviews;
  final GroupedReminders _groupedReminders;
  final NotificationPresenter _presenter;
  final Clock _clock;

  /// "Correct" and "Again" record the answer, revealed or not, and replace
  /// the notification with what the answer did. "Reveal" shows the answer,
  /// the face opposite
  /// [askedSide], in its place and records nothing. A typed answer counts
  /// as "Correct" when it matches the expected one and as "Again"
  /// otherwise, then shows its verdict with an "OK" button. Answering an
  /// extra reminder is a bonus review. A card deleted meanwhile only closes
  /// the notification.
  ///
  /// In a grouped reminder whose cards are chained, the next card replaces
  /// the one answered, or the verdict once acknowledged.
  Future<void> handle(
    ReviewNotificationKey key,
    NotificationAction action, {
    String? input,
    CardSide askedSide = CardSide.front,
  }) async {
    final card = await _cards.findCard(key.cardId);
    if (action == NotificationAction.acknowledge || card == null) {
      await _close(key);
    } else if (action == NotificationAction.reveal) {
      await _reveal(key, card, askedSide);
    } else if (action == NotificationAction.answer) {
      await _answerTyped(key, card, input ?? '', askedSide);
    } else {
      final result = await _reviews.answer(
        key.cardId,
        action == NotificationAction.correct
            ? ReviewOutcome.correct
            : ReviewOutcome.again,
        source: ReviewSource.notification,
        forceBonus: key.isExtraReminder,
      );
      await _confirm(key, result.schedule);
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

  Future<void> _reveal(
    ReviewNotificationKey key,
    Flashcard card,
    CardSide askedSide,
  ) async {
    final group = await _groups.find(card.groupId);
    if (group == null) {
      await _close(key);
      return;
    }
    final chain = key.chain;
    await _presenter.showPrompt(
      ReviewPrompt.of(
        key: key,
        card: card,
        askedSide: askedSide,
        group: group,
        chainRemaining: chain == null
            ? null
            : await _groupedReminders.remaining(chain),
        isRevealed: true,
      ),
    );
  }

  Future<void> _answerTyped(
    ReviewNotificationKey key,
    Flashcard card,
    String typed,
    CardSide askedSide,
  ) async {
    final answered = await _reviews.answerTyped(
      key.cardId,
      typed,
      askedSide: askedSide,
      source: ReviewSource.notification,
      forceBonus: key.isExtraReminder,
    );
    await _presenter.showVerdict(
      TypedAnswerVerdict(
        key: key,
        askedSide: askedSide,
        groupName: (await _groups.find(card.groupId))?.name ?? '',
        prompt: card.promptFor(askedSide).text ?? '',
        answer: card.answerFor(askedSide).text ?? '',
        answerImage: card.answerFor(askedSide).imagePath,
        typed: typed,
        match: answered.match,
        result: answered.result,
        answeredAt: _clock(),
      ),
    );
  }

  /// A bonus answer changed nothing worth telling, and a chained card gives
  /// way to the next one.
  Future<void> _confirm(
    ReviewNotificationKey key,
    CardSchedule? schedule,
  ) async {
    if (schedule == null || key.chain != null) {
      await _close(key);
    } else {
      await _presenter.showConfirmation(
        AnswerConfirmation(key: key, schedule: schedule, answeredAt: _clock()),
      );
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
