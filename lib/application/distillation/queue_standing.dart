import '../../domain/cards/flashcard.dart';
import '../../domain/distillation/distillation.dart';
import '../../domain/distillation/distillation_queue.dart';
import '../../domain/distillation/distillation_rhythm.dart';
import '../../domain/groups/sequence_end.dart';
import '../../domain/presets/preset.dart';

/// Where a pending card stands in the queue of its group: its [rank] (1 for
/// the head) among [size] cards, and when it should come out.
class QueueStanding {
  const QueueStanding({
    required this.rank,
    required this.size,
    required this.arrival,
  });

  /// The standing of [card] among [groupCards], `null` once it is
  /// introduced. Its arrival follows the [distillation] of the group as
  /// "Distill" estimates it, the reviews of the group taking the places of
  /// new cards with "Prioritize reviews".
  static QueueStanding? of(
    Flashcard card,
    Iterable<Flashcard> groupCards, {
    required Distillation? distillation,
    required bool globallyPaused,
    required Preset preset,
    required SequenceEnd end,
    required DistillationRhythm rhythm,
    required DateTime now,
  }) {
    final queue = DistillationQueue.inOrder(groupCards);
    final index = queue.indexWhere((other) => other.id == card.id);
    if (index < 0) {
      return null;
    }
    final rank = index + 1;
    return QueueStanding(
      rank: rank,
      size: queue.length,
      arrival: switch (distillation) {
        null => const NoDistillation(),
        Distillation(isPaused: true) => const DistillationPaused(),
        _ when globallyPaused => const DistillationPaused(),
        _ => _arrival(
          DistillationRhythm.arrivalDay(
            rhythm.forecast(
              distillation.settings,
              groupCards,
              preset: preset,
              end: end,
              firstDay: rhythm.nextIntroductionDay(
                distillation,
                rhythm.calendar.dayOf(now),
              ),
              now: now,
            ),
            rank,
          ),
        ),
      },
    );
  }

  static QueueArrival _arrival(DateTime? day) =>
      day == null ? const ArrivalBeyondHorizon() : ExpectedArrival(day);

  final int rank;
  final int size;
  final QueueArrival arrival;
}

/// When a pending card should come out of its queue.
sealed class QueueArrival {
  const QueueArrival();
}

/// On [day], at the pass of its distillation.
final class ExpectedArrival extends QueueArrival {
  const ExpectedArrival(this.day);

  final DateTime day;
}

/// Not within the period the estimate looks at, two years.
final class ArrivalBeyondHorizon extends QueueArrival {
  const ArrivalBeyondHorizon();
}

/// The distillation of the group, or every distillation, is paused.
final class DistillationPaused extends QueueArrival {
  const DistillationPaused();
}

/// The group does not distill: nothing comes out of its queue.
final class NoDistillation extends QueueArrival {
  const NoDistillation();
}
