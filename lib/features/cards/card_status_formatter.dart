import '../../app/formatting/due_labels.dart';
import '../../domain/cards/flashcard.dart';
import '../../domain/scheduling/due_policy.dart';
import '../../domain/scheduling/scheduling_calendar.dart';
import '../../l10n/generated/app_localizations.dart';

/// Texts describing where a card stands: how long until it is due ("4 d"),
/// or why it has no date ("waiting").
class CardStatusFormatter {
  const CardStatusFormatter({
    required this.strings,
    required this.duePolicy,
    required this.calendar,
    required this.now,
  });

  final AppLocalizations strings;
  final DuePolicy duePolicy;
  final SchedulingCalendar calendar;
  final DateTime now;

  /// "4 d", "3 mo", "Due"; "waiting", "suspended" or "learned" for a card
  /// with no next date.
  String standing(Flashcard card) {
    if (card.suspended) {
      return strings.cardStatusSuspended;
    } else if (card.isPending) {
      return strings.cardStatusPending;
    } else if (card.isAcquired) {
      return strings.cardStatusAcquired;
    } else {
      return isDue(card)
          ? strings.dueNow
          : strings.dueInLabel(card.dueAt!, now: now, calendar: calendar);
    }
  }

  /// Whether [standing] is a date, not a reason why the card has none.
  bool hasDate(Flashcard card) =>
      !card.suspended && !card.isPending && !card.isAcquired;

  bool isDue(Flashcard card) => duePolicy.isDueToday(card, now: now);

  /// "Due", "at 15:17", "tomorrow" or "in 3 d" for a future due date.
  String dueDateLabel(DateTime dueAt) =>
      strings.dueDateLabel(dueAt, now: now, calendar: calendar);
}
