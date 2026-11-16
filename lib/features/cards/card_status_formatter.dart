import '../../app/formatting/due_labels.dart';
import '../../domain/cards/card_state.dart';
import '../../domain/cards/flashcard.dart';
import '../../domain/presets/preset_catalog.dart';
import '../../domain/scheduling/card_progress.dart';
import '../../domain/scheduling/due_policy.dart';
import '../../domain/scheduling/scheduling_calendar.dart';
import '../../l10n/generated/app_localizations.dart';

/// Texts describing where a card stands: "step 2 of 6", "interval 12 d",
/// "Due", "in 3 d".
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

  String status(Flashcard card) {
    if (card.suspended) {
      return strings.cardStatusSuspended;
    } else {
      return switch (card.state) {
        CardState.pending => strings.cardStatusPending,
        CardState.acquired => strings.cardStatusAcquired,
        CardState.active => _progressLabel(card),
      };
    }
  }

  /// When the card is next due; `null` when it is not scheduled.
  String? dueLabel(Flashcard card) {
    final dueAt = card.dueAt;
    if (card.suspended || !card.isScheduled || dueAt == null) {
      return null;
    } else if (duePolicy.isDueToday(card, now: now)) {
      return strings.dueNow;
    } else {
      return dueDateLabel(dueAt);
    }
  }

  /// "Due", "at 15:17", "tomorrow" or "in 3 d" for a future due date.
  String dueDateLabel(DateTime dueAt) =>
      strings.dueDateLabel(dueAt, now: now, calendar: calendar);

  String _progressLabel(Flashcard card) =>
      switch (CardProgress.of(card, catalog.presetForCard(card))) {
        NewProgress() => strings.cardStatusNew,
        SequenceProgress(:final step, :final sequenceLength) =>
          strings.cardStatusStep(step + 1, sequenceLength),
        AdaptiveProgress(:final intervalDays) => strings.cardStatusInterval(
          strings.intervalDays(intervalDays),
        ),
      };
}
