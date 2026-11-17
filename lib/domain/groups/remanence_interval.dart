import '../presets/interval_unit.dart';
import '../presets/preset_interval.dart';

/// Interval at which a card in remanence comes back, chosen by its group.
enum RemanenceInterval {
  threeMonths(PresetInterval(3, IntervalUnit.month)),
  sixMonths(PresetInterval(6, IntervalUnit.month)),
  oneYear(PresetInterval(1, IntervalUnit.year));

  const RemanenceInterval(this.interval);

  final PresetInterval interval;
}
