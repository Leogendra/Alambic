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
  /// the face opposite [askedSide], in its place and "Hide" asks the card
  /// again; neither records anything. A typed answer counts as "Correct"
  /// when it matches the expected one and as "Again" otherwise, then shows
  /// its verdict. Answering an extra reminder is a bonus review. A card
  /// deleted meanwhile only closes the notification.
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
    } else if (action == NotificationAction.reveal ||
        action == NotificationAction.hide) {
      await _showAgain(
        key,
        card,
        askedSide,
        isRevealed: action == NotificationAction.reveal,
      );
    } else if (action == NotificationAction.answer) {
      await _answerTyped(key, card, input ?? '', askedSide);
    } else {
      final outcome = action == NotificationAction.correct
          ? ReviewOutcome.correct
          : ReviewOutcome.again;
      final result = await _reviews.answer(
        key.cardId,
        outcome,
        source: ReviewSource.notification,
        forceBonus: key.isExtraReminder,
      );
      await _confirm(key, card, askedSide, outcome, result.schedule);
    }
  }

  /// The buttons of the test notification of the onboarding, tied to no
  /// card: "Reveal" and "Hide" as on a card; "Correct" and "Again" show
  /// what the answer would do to a card at its first step, with the delays
  /// of the welcome screen, and record nothing.
  Future<void> handleTest(NotificationAction action) async {
    final now = _clock();
    if (action == NotificationAction.reveal ||
        action == NotificationAction.hide) {
      await _presenter.showTestPrompt(
        isRevealed: action == NotificationAction.reveal,
        alert: false,
      );
    } else if (action == NotificationAction.correct) {
      await _presenter.showTestConfirmation(
        ReviewOutcome.correct,
        dueAt: now.add(const Duration(days: 2)),
        answeredAt: now,
      );
    } else if (action == NotificationAction.again) {
      await _presenter.showTestConfirmation(
        ReviewOutcome.again,
        dueAt: now.add(const Duration(days: 1)),
        answeredAt: now,
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

  /// The card in place, silently, its answer shown or not.
  Future<void> _showAgain(
    ReviewNotificationKey key,
    Flashcard card,
    CardSide askedSide, {
    required bool isRevealed,
  }) async {
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
        isRevealed: isRevealed,
        alert: false,
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
    final group = await _groups.find(card.groupId);
    if (group == null) {
      await _close(key);
      return;
    }
    final answer = card.answerFor(askedSide);
    await _presenter.showVerdict(
      TypedAnswerVerdict(
        key: key,
        groupName: group.name,
        answer: answer.text ?? '',
        answerImage: answer.imagePath,
        match: answered.match,
        result: answered.result,
        answeredAt: _clock(),
      ),
    );
  }

  /// What the answer did, with the answer face of the card, revealed or not.
  /// A bonus answer changed nothing worth telling, and a chained card gives
  /// way to the next one.
  Future<void> _confirm(
    ReviewNotificationKey key,
    Flashcard card,
    CardSide askedSide,
    ReviewOutcome outcome,
    CardSchedule? schedule,
  ) async {
    final group = await _groups.find(card.groupId);
    if (schedule == null || key.chain != null || group == null) {
      await _close(key);
    } else {
      final answer = card.answerFor(askedSide);
      await _presenter.showConfirmation(
        AnswerConfirmation(
          key: key,
          outcome: outcome,
          schedule: schedule,
          answeredAt: _clock(),
          groupName: group.name,
          answer: answer.text ?? '',
          answerImage: answer.imagePath,
        ),
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
