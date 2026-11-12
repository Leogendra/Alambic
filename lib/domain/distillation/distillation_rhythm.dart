import '../scheduling/scheduling_calendar.dart';
import 'distillation.dart';

/// Where the batches of a distillation stand after a day.
typedef BatchProgress = ({DateTime nextBatchDay, int introducedInBatch});

/// "N cards every X days", day by day.
///
/// A batch of N cards becomes due on its batch day. Cards held back (by the
/// budget, or because no card was ready) are introduced the next days, and
/// the next batch comes X days after the day the batch was completed. A
/// missed day is not caught up: at most one batch is introduced per day.
class DistillationRhythm {
  const DistillationRhythm(this.calendar);

  final SchedulingCalendar calendar;

  /// New cards [distillation] owes on [day], before any budget.
  int cardsDue(Distillation distillation, DateTime day) {
    if (day.isBefore(distillation.nextBatchDay)) {
      return 0;
    } else {
      return distillation.cardsPerBatch - distillation.introducedInBatch;
    }
  }

  /// Batches after [count] cards were introduced on [day].
  BatchProgress afterIntroducing(
    Distillation distillation,
    int count,
    DateTime day,
  ) {
    final introduced = distillation.introducedInBatch + count;
    if (introduced >= distillation.cardsPerBatch) {
      return (
        nextBatchDay: calendar.addDays(day, distillation.everyDays),
        introducedInBatch: 0,
      );
    } else {
      return (
        nextBatchDay: distillation.nextBatchDay,
        introducedInBatch: introduced,
      );
    }
  }

  /// Day on which the last of [remaining] cards arrives when every batch
  /// goes through, the first batch arriving on [firstDay]; `null` when
  /// nothing remains.
  DateTime? lastArrival({
    required int remaining,
    required int cardsPerBatch,
    required int everyDays,
    required DateTime firstDay,
  }) {
    if (remaining <= 0) {
      return null;
    } else {
      final batches = (remaining / cardsPerBatch).ceil();
      return calendar.addDays(firstDay, (batches - 1) * everyDays);
    }
  }

  /// Day on which [distillation] introduces its next cards, seen from
  /// [today].
  DateTime nextIntroductionDay(Distillation distillation, DateTime today) {
    final earliest = distillation.lastAdvancedDay == today
        ? calendar.addDays(today, 1)
        : today;
    return distillation.nextBatchDay.isAfter(earliest)
        ? distillation.nextBatchDay
        : earliest;
  }
}
