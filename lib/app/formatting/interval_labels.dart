import '../../domain/presets/interval_unit.dart';
import '../../domain/presets/preset_interval.dart';
import '../../l10n/generated/app_localizations.dart';

/// Short labels of intervals: "10 min", "1 j", "3 mois".
extension IntervalLabels on AppLocalizations {
  String intervalLabel(PresetInterval interval) =>
      intervalAmount(interval.amount, interval.unit);

  String intervalAmount(int amount, IntervalUnit unit) => switch (unit) {
    IntervalUnit.minute => intervalMinutes(amount),
    IntervalUnit.hour => intervalHours(amount),
    IntervalUnit.day => intervalDays(amount),
    IntervalUnit.week => intervalWeeks(amount),
    IntervalUnit.month => intervalMonths(amount),
  };

  String intervalUnitName(IntervalUnit unit) => switch (unit) {
    IntervalUnit.minute => unitMinutes,
    IntervalUnit.hour => unitHours,
    IntervalUnit.day => unitDays,
    IntervalUnit.week => unitWeeks,
    IntervalUnit.month => unitMonths,
  };
}
