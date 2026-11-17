import '../app/formatting/review_duration_labels.dart';
import '../app/formatting/typed_answer_labels.dart';
import '../application/notifications/group_reminder.dart';
import '../application/notifications/notification_digest.dart';
import '../application/notifications/review_prompt.dart';
import '../application/notifications/typed_answer_verdict.dart';
import '../domain/cards/card_side.dart';
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

  /// Line under the asked face: its group, and the cards left when the card
  /// is chained in a grouped reminder ("Capitales · 3 à réviser"); preceded
  /// by "verso → recto" when the back is asked, and by the bonus mention of
  /// an extra reminder.
  String promptDetail(ReviewPrompt prompt) {
    final remaining = prompt.chainRemaining;
    return [
      if (prompt.askedSide == CardSide.back) strings.sessionReverseBadge,
      if (prompt.key.isExtraReminder) strings.notificationExtra,
      if (remaining == null)
        prompt.groupName
      else
        strings.notificationChainRemaining(prompt.groupName, remaining),
    ].join(' · ');
  }

  /// "Capitales : 5 cartes à réviser".
  String groupReminderTitle(GroupReminder reminder) =>
      strings.notificationGroupTitle(reminder.groupName, reminder.count);

  /// "Environ 3 min".
  String groupReminderDetail(GroupReminder reminder) =>
      strings.reviewDuration(reminder.count);

  /// "12 cartes à réviser".
  String digestTitle(NotificationDigest digest) =>
      strings.notificationDigestTitle(digest.count);

  /// "Capitales, Espagnol · Environ 6 min".
  String digestDetail(NotificationDigest digest) {
    final groups = digest.groupNames.join(', ');
    return '$groups · ${strings.reviewDuration(digest.count)}';
  }

  /// "Réponse : Lima", or a mention of the image for an answer face that
  /// has no text.
  String answerLine(String answer) => answer.isEmpty
      ? strings.notificationAnswerImage
      : strings.notificationAnswer(answer);

  /// How the typed answer compared, then what the answer did: "« canbera »
  /// accepté, 1 faute · prochain rappel demain", "« Quito » refusé · Compté
  /// raté · revue demain", or the bonus mention.
  String verdict(TypedAnswerVerdict verdict) {
    final typedPart = strings.typedAnswerVerdict(verdict.typed, verdict.match);
    final effect = strings.typedAnswerEffect(
      verdict.result.isBonus ? null : verdict.result.schedule,
      accepted: verdict.match.isAccepted,
      answeredAt: verdict.answeredAt,
      calendar: calendar,
    );
    return '$typedPart · $effect';
  }
}
