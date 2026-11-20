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
