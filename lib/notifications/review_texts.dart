import '../app/formatting/due_labels.dart';
import '../app/formatting/review_duration_labels.dart';
import '../application/notifications/answer_confirmation.dart';
import '../application/notifications/group_reminder.dart';
import '../application/notifications/notification_digest.dart';
import '../application/notifications/review_prompt.dart';
import '../application/notifications/typed_answer_verdict.dart';
import '../domain/reviews/review_outcome.dart';
import '../domain/scheduling/scheduling_calendar.dart';
import '../l10n/generated/app_localizations.dart';

/// Texts of the review notifications, shared by every platform
/// implementation so that a card reads the same everywhere.
class ReviewTexts {
  const ReviewTexts(this.strings, this.calendar);

  final AppLocalizations strings;
  final SchedulingCalendar calendar;

  /// Header of a card notification, beside the name of the app: its group,
  /// and the cards left when the card is chained in a grouped reminder
  /// ("Capitals · 3 to review").
  String promptHeader(ReviewPrompt prompt) => switch (prompt.chainRemaining) {
    null => prompt.groupName,
    final remaining => strings.notificationChainRemaining(
      prompt.groupName,
      remaining,
    ),
  };

  /// "Capitals: 5 cards to review".
  String groupReminderTitle(GroupReminder reminder) =>
      strings.notificationGroupTitle(reminder.groupName, reminder.count);

  /// "About 3 min".
  String groupReminderDetail(GroupReminder reminder) =>
      strings.reviewDuration(reminder.count);

  /// "12 cards to review".
  String digestTitle(NotificationDigest digest) =>
      strings.notificationDigestTitle(digest.count);

  /// "Capitals, Spanish · About 6 min".
  String digestDetail(NotificationDigest digest) {
    final groups = digest.groupNames.join(', ');
    return '$groups · ${strings.reviewDuration(digest.count)}';
  }

  /// Whether the typed answer was accepted, with the expected answer when
  /// it was not, then what the answer did: "Correct, next in 3 d", "To
  /// review (Lima), next in 1 d"; the verdict alone for a bonus review.
  String verdict(TypedAnswerVerdict verdict) {
    final outcome = verdict.match.isAccepted
        ? strings.notificationCorrect
        : strings.notificationRefused(verdict.answer);
    final schedule = verdict.result.schedule;
    if (verdict.result.isBonus || schedule == null) {
      return outcome;
    } else {
      return _answered(outcome, schedule.dueAt, verdict.answeredAt);
    }
  }

  /// "Correct, next in 3 d", "To review, next in 10 min", or "Correct, card
  /// learned".
  String confirmation(AnswerConfirmation confirmation) => answered(
    confirmation.outcome,
    dueAt: confirmation.schedule.dueAt,
    answeredAt: confirmation.answeredAt,
  );

  /// What [outcome] did to a card due again at [dueAt], learned when
  /// `null`.
  String answered(
    ReviewOutcome outcome, {
    required DateTime? dueAt,
    required DateTime answeredAt,
  }) => _answered(
    switch (outcome) {
      ReviewOutcome.correct => strings.notificationCorrect,
      ReviewOutcome.again => strings.notificationToReview,
    },
    dueAt,
    answeredAt,
  );

  String _answered(String outcome, DateTime? dueAt, DateTime answeredAt) =>
      switch (dueAt) {
        null => strings.notificationLearned(outcome),
        final dueAt => strings.notificationNextIn(
          outcome,
          strings.delayLabel(dueAt, now: answeredAt, calendar: calendar),
        ),
      };

  /// The sample card of the test notification, from the onboarding.
  String get testGroupName => strings.sampleGroupCapitals;

  String get testQuestion => strings.onboardingNotificationQuestion;

  String get testAnswer => strings.onboardingNotificationAnswer;
}
