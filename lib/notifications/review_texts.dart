import '../app/formatting/due_labels.dart';
import '../app/formatting/review_duration_labels.dart';
import '../app/formatting/typed_answer_labels.dart';
import '../application/notifications/answer_confirmation.dart';
import '../application/notifications/group_reminder.dart';
import '../application/notifications/notification_digest.dart';
import '../application/notifications/review_prompt.dart';
import '../application/notifications/typed_answer_verdict.dart';
import '../domain/scheduling/card_schedule.dart';
import '../domain/scheduling/scheduling_calendar.dart';
import '../l10n/generated/app_localizations.dart';

/// Texts of the review notifications, shared by every platform
/// implementation so that a card reads the same everywhere.
class ReviewTexts {
  const ReviewTexts(this.strings, this.calendar);

  final AppLocalizations strings;
  final SchedulingCalendar calendar;

  /// Title of a card notification: the asked face, or a mention of its image
  /// when it has no text.
  String promptTitle(String prompt) =>
      prompt.isEmpty ? strings.notificationImagePrompt : prompt;

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

  /// The text of the answer face, or a mention of its image when it has no
  /// text.
  String answerLine(String answer) =>
      answer.isEmpty ? strings.notificationAnswerImage : answer;

  /// How the typed answer compared, then what the answer did: "\"canbera\"
  /// accepted, 1 typo · Next tomorrow"; the comparison alone for a bonus
  /// review.
  String verdict(TypedAnswerVerdict verdict) {
    final typedPart = strings.typedAnswerVerdict(verdict.typed, verdict.match);
    final schedule = verdict.result.schedule;
    if (verdict.result.isBonus || schedule == null) {
      return typedPart;
    } else {
      return '$typedPart · ${_next(schedule, verdict.answeredAt)}';
    }
  }

  /// "Next in 3 d", or "Card learned".
  String confirmation(AnswerConfirmation confirmation) =>
      _next(confirmation.schedule, confirmation.answeredAt);

  String _next(CardSchedule schedule, DateTime answeredAt) => strings
      .nextReviewLabel(schedule, answeredAt: answeredAt, calendar: calendar);
}
