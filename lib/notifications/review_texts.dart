import '../app/formatting/due_labels.dart';
import '../application/notifications/answer_reveal.dart';
import '../application/notifications/review_prompt.dart';
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

  String groupLabel(ReviewPrompt prompt) => prompt.groupName ?? strings.noGroup;

  String answerLine(AnswerReveal reveal) =>
      strings.notificationAnswer(reveal.answer);

  /// "Compté raté · retour au cran 1, revue demain", or the bonus mention.
  String verdict(AnswerReveal reveal) {
    final schedule = reveal.result.schedule;
    final dueAt = schedule?.dueAt;
    if (reveal.result.isBonus || schedule == null || dueAt == null) {
      return strings.notificationBonus;
    }
    return strings.notificationFailed(
      (schedule.step ?? 0) + 1,
      strings.dueDateLabel(dueAt, now: reveal.answeredAt, calendar: calendar),
    );
  }
}
