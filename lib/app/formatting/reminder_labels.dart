import '../../domain/presets/interval_unit.dart';
import '../../domain/presets/preset_interval.dart';
import '../../domain/scheduling/card_progress.dart';
import '../../l10n/generated/app_localizations.dart';
import 'interval_labels.dart';

/// Reminder labels, taken from the interval a card waits: "J1", "S1", "M3",
/// or "10 min" below a day.
extension ReminderLabels on AppLocalizations {
  String reminderLabel(PresetInterval interval) => switch (interval.unit) {
    IntervalUnit.minute || IntervalUnit.hour => intervalLabel(interval),
    IntervalUnit.day => reminderDays(interval.amount),
    IntervalUnit.week => reminderWeeks(interval.amount),
    IntervalUnit.month => reminderMonths(interval.amount),
  };

  /// Label of a card at [progress]; `null` for a card never answered or
  /// followed by FSRS, which only show their date.
  String? progressLabel(CardProgress progress) => switch (progress) {
    SequenceProgress(:final interval) => reminderLabel(interval),
    NewProgress() || AdaptiveProgress() => null,
  };
}
