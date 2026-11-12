import '../app/formatting/due_labels.dart';
import '../app/formatting/review_duration_labels.dart';
import '../application/notifications/answer_reveal.dart';
import '../application/notifications/group_reminder.dart';
import '../application/notifications/notification_digest.dart';
import '../application/notifications/review_prompt.dart';
import '../domain/reviews/typed_answer_match.dart';
import '../domain/scheduling/scheduling_calendar.dart';
import '../l10n/generated/app_localizations.dart';

/// Texts of the review notifications, shared by every platform
/// implementation so that a card reads the same everywhere.
class ReviewTexts {
  const ReviewTexts(this.strings, this.calendar);

  final AppLocalizations strings;
  final SchedulingCalendar calendar;

  /// Line under the asked face: "Cran 2 sur 6", "verso → recto · Nouvelle
  /// carte", or the bonus mention of an extra reminder.
  String promptDetail(ReviewPrompt prompt) {
    if (prompt.key.isExtraReminder) {
      return strings.notificationExtra;
    }
    final step = prompt.step;
    final position = step == null
        ? strings.notificationNewCard
        : strings.cardSheetStepOf(step + 1, prompt.sequenceLength);
    return prompt.isReverse
        ? '${strings.sessionReverseBadge} · $position'
        : position;
  }

  /// The group, and the cards left when the card is chained in a grouped
  /// reminder: "Capitales · 3 à réviser".
  String groupLabel(ReviewPrompt prompt) {
    final group = prompt.groupName ?? strings.noGroup;
    final remaining = prompt.chainRemaining;
    return remaining == null
        ? group
        : strings.notificationChainRemaining(group, remaining);
  }

  /// "Capitales : 5 cartes à réviser".
  String groupReminderTitle(GroupReminder reminder) =>
      strings.notificationGroupTitle(
        reminder.groupName ?? strings.noGroup,
        reminder.count,
      );

  /// "Environ 3 min".
  String groupReminderDetail(GroupReminder reminder) =>
      strings.reviewDuration(reminder.count);

  /// "12 cartes à réviser".
  String digestTitle(NotificationDigest digest) =>
      strings.notificationDigestTitle(digest.count);

  /// "Capitales, Espagnol · Environ 6 min".
  String digestDetail(NotificationDigest digest) {
    final groups = digest.groupNames
        .map((name) => name ?? strings.noGroup)
        .join(', ');
    return '$groups · ${strings.reviewDuration(digest.count)}';
  }

  String answerLine(AnswerReveal reveal) =>
      strings.notificationAnswer(reveal.answer);

  /// How the typed answer compared, then what the answer did: "« canbera »
  /// accepté, 1 faute · prochain rappel demain", "Compté raté · retour au
  /// cran 1, revue demain", or the bonus mention.
  String verdict(AnswerReveal reveal) {
    final typed = reveal.typed;
    final match = reveal.match;
    final typedPart = typed == null || match == null
        ? null
        : switch (match) {
            TypedAnswerMatch.exact => strings.notificationTypedAccepted(typed),
            TypedAnswerMatch.oneTypo => strings.notificationTypedAcceptedTypo(
              typed,
            ),
            TypedAnswerMatch.wrong => strings.notificationTypedRefused(typed),
          };
    final schedulePart = _scheduleVerdict(
      reveal,
      correct: match?.isAccepted ?? false,
    );
    return typedPart == null ? schedulePart : '$typedPart · $schedulePart';
  }

  String _scheduleVerdict(AnswerReveal reveal, {required bool correct}) {
    final schedule = reveal.result.schedule;
    if (reveal.result.isBonus || schedule == null) {
      return strings.notificationBonus;
    }
    final dueAt = schedule.dueAt;
    if (dueAt == null) {
      return strings.notificationAcquired;
    }
    final when = strings.dueDateLabel(
      dueAt,
      now: reveal.answeredAt,
      calendar: calendar,
    );
    return correct
        ? strings.notificationNextReview(when)
        : strings.notificationFailed((schedule.step ?? 0) + 1, when);
  }
}
