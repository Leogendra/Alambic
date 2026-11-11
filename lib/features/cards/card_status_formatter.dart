import '../../data/repositories/card_with_directions.dart';
import '../../domain/cards/card_direction.dart';
import '../../domain/cards/direction_sense.dart';
import '../../domain/cards/direction_state.dart';
import '../../domain/presets/preset_catalog.dart';
import '../../domain/scheduling/due_policy.dart';
import '../../domain/scheduling/scheduling_calendar.dart';
import '../../domain/scheduling/sequence_engine.dart';
import '../../l10n/generated/app_localizations.dart';

/// Texts describing where a card stands: "step 2 of 6", "Due", "in 3 d".
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

  /// Status of the front → back direction, the one every card has.
  String status(CardWithDirections card) {
    final direction = card.direction(DirectionSense.frontToBack);
    if (card.card.suspended) {
      return strings.cardStatusSuspended;
    } else if (direction == null) {
      return strings.cardStatusInactive;
    } else {
      return directionStatus(card, direction);
    }
  }

  String directionStatus(CardWithDirections card, CardDirection direction) =>
      switch (direction.state) {
        DirectionState.inactive => strings.cardStatusInactive,
        DirectionState.unstarted => strings.cardStatusUnstarted,
        DirectionState.pending => strings.cardStatusPending,
        DirectionState.acquired => strings.cardStatusAcquired,
        DirectionState.active => _stepLabel(card, direction),
      };

  /// When the card is next due, from its earliest direction; `null` when it is
  /// not scheduled at all.
  String? dueLabel(CardWithDirections card) {
    if (card.card.suspended) {
      return null;
    }
    final scheduled = card.directions.where(
      (direction) => direction.isScheduled,
    );
    if (scheduled.any(_isDue(card))) {
      return strings.dueNow;
    }
    final dueDates = scheduled.map((direction) => direction.dueAt!).toList()
      ..sort();
    return dueDates.isEmpty ? null : dueDateLabel(dueDates.first);
  }

  /// "Due", "at 15:17", "tomorrow" or "in 3 d" for a future due date.
  String dueDateLabel(DateTime dueAt) {
    final days = _daysBetween(calendar.dayOf(now), calendar.dayOf(dueAt));
    if (!dueAt.isAfter(now)) {
      return strings.dueNow;
    } else if (days <= 0) {
      return strings.dueAtTime(_time(dueAt));
    } else if (days == 1) {
      return strings.dueTomorrow;
    } else {
      return strings.dueInDays(days);
    }
  }

  bool Function(CardDirection) _isDue(CardWithDirections card) =>
      (direction) => duePolicy.isDueToday(
        direction,
        cardSuspended: card.card.suspended,
        now: now,
      );

  String _stepLabel(CardWithDirections card, CardDirection direction) {
    final preset = catalog.presetForCard(card.card);
    final step = SequenceEngine.clampToSequence(direction.step, preset);
    if (step == null) {
      return strings.cardStatusNew;
    } else {
      return strings.cardStatusStep(step + 1, preset.sequenceLength);
    }
  }

  /// Whole days between two scheduling days, robust to daylight saving.
  static int _daysBetween(DateTime from, DateTime to) =>
      (to.difference(from).inHours / 24).round();

  static String _time(DateTime moment) =>
      '${moment.hour.toString().padLeft(2, '0')}:'
      '${moment.minute.toString().padLeft(2, '0')}';
}
