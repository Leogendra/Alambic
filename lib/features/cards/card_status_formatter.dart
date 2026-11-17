import '../../app/formatting/due_labels.dart';
import '../../app/formatting/reminder_labels.dart';
import '../../domain/cards/card_state.dart';
import '../../domain/cards/flashcard.dart';
import '../../domain/presets/preset_catalog.dart';
import '../../domain/scheduling/card_progress.dart';
import '../../domain/scheduling/due_policy.dart';
import '../../domain/scheduling/scheduling_calendar.dart';
import '../../l10n/generated/app_localizations.dart';

/// Texts describing where a card stands: its reminder label and next date
/// ("S1 · in 4 d"), or why it has no date ("waiting").
class CardStatusFormatter {
  const CardStatusFormatter({
    required this.strings,
    required this.catalog,
    required this.duePolicy,
    required this.calendar,
    required this.now,
  });

  final AppLocalizations strings;
  final PresetCatalog catalog;
  final DuePolicy duePolicy;
  final SchedulingCalendar calendar;
  final DateTime now;

  /// "S1 · in 4 d", "J2 · Due", only the date for a card never answered;
  /// "waiting", "suspended" or "learned" for a card with no next date.
  String standing(Flashcard card) {
    if (card.suspended) {
      return strings.cardStatusSuspended;
    } else {
      return switch (card.state) {
        CardState.pending => strings.cardStatusPending,
        CardState.acquired => strings.cardStatusAcquired,
        CardState.active => _scheduled(card),
      };
    }
  }

  bool isDue(Flashcard card) => duePolicy.isDueToday(card, now: now);

  /// "Due", "at 15:17", "tomorrow" or "in 3 d" for a future due date.
  String dueDateLabel(DateTime dueAt) =>
      strings.dueDateLabel(dueAt, now: now, calendar: calendar);

  /// "S1"; `null` for a card never answered.
  String? reminderLabel(Flashcard card) =>
      strings.progressLabel(CardProgress.of(card, catalog.presetForCard(card)));

  String _scheduled(Flashcard card) {
    final when = isDue(card) ? strings.dueNow : dueDateLabel(card.dueAt!);
    final label = reminderLabel(card);
    return label == null ? when : '$label · $when';
  }
}
