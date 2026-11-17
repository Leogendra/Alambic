/// Unit of a [PresetInterval]. Units of a day or more are calendar based.
enum IntervalUnit {
  minute(daysPerUnit: 0, minutesPerUnit: 1),
  hour(daysPerUnit: 0, minutesPerUnit: 60),
  day(daysPerUnit: 1, minutesPerUnit: 0),
  week(daysPerUnit: 7, minutesPerUnit: 0),

  /// A month counts as 30 days, so that "1 mois" is always the same length.
  month(daysPerUnit: 30, minutesPerUnit: 0),

  /// A year counts as 365 days.
  year(daysPerUnit: 365, minutesPerUnit: 0);

  const IntervalUnit({required this.daysPerUnit, required this.minutesPerUnit});

  final int daysPerUnit;
  final int minutesPerUnit;

  bool get isDayBased => daysPerUnit > 0;
}
