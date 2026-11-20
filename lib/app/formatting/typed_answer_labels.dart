import '../../domain/reviews/typed_answer_match.dart';
import '../../domain/scheduling/card_schedule.dart';
import '../../domain/scheduling/scheduling_calendar.dart';
import '../../l10n/generated/app_localizations.dart';
import 'due_labels.dart';

/// What a typed answer gave, shared by the session and the notifications.
extension TypedAnswerLabels on AppLocalizations {
  /// "\"canbera\" accepted, 1 typo", "\"Quito\" refused".
  String typedAnswerVerdict(String typed, TypedAnswerMatch match) =>
      switch (match) {
        TypedAnswerMatch.exact => typedAnswerAccepted(typed),
        TypedAnswerMatch.oneTypo => typedAnswerAcceptedTypo(typed),
        TypedAnswerMatch.wrong => typedAnswerRefused(typed),
      };

  /// What the answer did to the schedule, accepted or not: "Next tomorrow";
  /// [schedule] is `null` for a bonus review.
  String typedAnswerEffect(
    CardSchedule? schedule, {
    required DateTime answeredAt,
    required SchedulingCalendar calendar,
  }) => schedule == null
      ? typedAnswerBonus
      : nextReviewLabel(schedule, answeredAt: answeredAt, calendar: calendar);
}
