import '../../domain/reviews/typed_answer_match.dart';
import '../../domain/scheduling/card_schedule.dart';
import '../../domain/scheduling/scheduling_calendar.dart';
import '../../l10n/generated/app_localizations.dart';
import 'due_labels.dart';

/// What a typed answer gave, shared by the session and the notifications.
extension TypedAnswerLabels on AppLocalizations {
  /// "« canbera » accepté, 1 faute", "« Quito » refusé".
  String typedAnswerVerdict(String typed, TypedAnswerMatch match) =>
      switch (match) {
        TypedAnswerMatch.exact => typedAnswerAccepted(typed),
        TypedAnswerMatch.oneTypo => typedAnswerAcceptedTypo(typed),
        TypedAnswerMatch.wrong => typedAnswerRefused(typed),
      };

  /// What the answer did to the schedule: "prochain rappel demain",
  /// "Compté raté · revue demain"; [schedule] is `null` for a bonus review.
  String typedAnswerEffect(
    CardSchedule? schedule, {
    required bool accepted,
    required DateTime answeredAt,
    required SchedulingCalendar calendar,
  }) {
    final dueAt = schedule?.dueAt;
    if (schedule == null) {
      return typedAnswerBonus;
    } else if (dueAt == null) {
      return typedAnswerAcquired;
    } else {
      final when = dueDateLabel(dueAt, now: answeredAt, calendar: calendar);
      return accepted ? typedAnswerNextReview(when) : typedAnswerFailed(when);
    }
  }
}
