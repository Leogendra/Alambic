import 'interval_unit.dart';

/// One step of a preset sequence, such as "10 min" or "3 mo".
class PresetInterval {
  const PresetInterval(this.amount, this.unit) : assert(amount > 0);

  final int amount;
  final IntervalUnit unit;

  /// Intervals of a day or more are counted in days from the answer day and
  /// land on the preset time slot. Shorter ones are counted from the answer.
  bool get isDayBased => unit.isDayBased;

  int get days => amount * unit.daysPerUnit;

  Duration get subDayDuration =>
      Duration(minutes: amount * unit.minutesPerUnit);

  /// Length of the interval, a day counting 24 hours; used to rank intervals.
  Duration get length => isDayBased ? Duration(days: days) : subDayDuration;

  /// The same interval in the largest unit that holds it exactly: 24 hours
  /// become 1 day, 7 days 1 week, 4 weeks (or 30 days) 1 month, 12 months
  /// 1 year. An interval that no unit simplifies is returned as is.
  PresetInterval get normalized {
    for (final (factor, larger) in _promotions[unit]!) {
      if (amount % factor == 0) {
        return PresetInterval(amount ~/ factor, larger).normalized;
      }
    }
    return this;
  }

  // For each unit, the larger units it converts to, the largest first.
  static const Map<IntervalUnit, List<(int, IntervalUnit)>> _promotions = {
    IntervalUnit.minute: [(60, IntervalUnit.hour)],
    IntervalUnit.hour: [(24, IntervalUnit.day)],
    IntervalUnit.day: [
      (365, IntervalUnit.year),
      (30, IntervalUnit.month),
      (7, IntervalUnit.week),
    ],
    IntervalUnit.week: [(4, IntervalUnit.month)],
    IntervalUnit.month: [(12, IntervalUnit.year)],
    IntervalUnit.year: [],
  };

  Map<String, Object> toJson() => {'amount': amount, 'unit': unit.name};

  factory PresetInterval.fromJson(Map<String, Object?> json) => PresetInterval(
    json['amount']! as int,
    IntervalUnit.values.byName(json['unit']! as String),
  );

  @override
  bool operator ==(Object other) =>
      other is PresetInterval && other.amount == amount && other.unit == unit;

  @override
  int get hashCode => Object.hash(amount, unit);

  @override
  String toString() => '$amount ${unit.name}';
}
