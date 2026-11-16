import '../../domain/presets/preset.dart';
import '../../domain/scheduling/card_schedule.dart';

/// What an answer changed, to tell the user ("back to step 1, due tomorrow").
class ReviewResult {
  const ReviewResult({
    required this.isBonus,
    required this.schedule,
    required this.preset,
  });

  /// A bonus answer changed nothing but the history.
  final bool isBonus;

  /// New schedule of the card; `null` for a bonus answer.
  final CardSchedule? schedule;
  final Preset preset;
}
