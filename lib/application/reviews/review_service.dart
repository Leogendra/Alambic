import '../../data/repositories/card_repository.dart';
import '../../data/repositories/preset_repository.dart';
import '../../data/repositories/review_repository.dart';
import '../../domain/cards/card_direction.dart';
import '../../domain/cards/flashcard.dart';
import '../../domain/presets/preset.dart';
import '../../domain/reviews/review_outcome.dart';
import '../../domain/reviews/review_source.dart';
import '../../domain/scheduling/direction_schedule.dart';
import '../../domain/scheduling/due_policy.dart';
import '../../domain/scheduling/review_scheduler.dart';
import '../clock.dart';
import '../scheduling/schedule_change_listener.dart';
import 'answer_preview.dart';
import 'review_result.dart';

/// Records answers, from a session or a notification, and reschedules.
class ReviewService {
  const ReviewService({
    required this._cards,
    required this._presets,
    required this._reviews,
    required this._scheduler,
    required this._duePolicy,
    required this._clock,
    required this._scheduleChangeListener,
  });

  final CardRepository _cards;
  final PresetRepository _presets;
  final ReviewRepository _reviews;
  final ReviewScheduler _scheduler;
  final DuePolicy _duePolicy;
  final Clock _clock;
  final ScheduleChangeListener _scheduleChangeListener;

  /// Records [outcome] for a direction. The answer is a bonus review, kept in
  /// the history without any effect, when the direction is not due or when
  /// [forceBonus] is set (reviewing the missed cards again, extra reminder).
  Future<ReviewResult> answer(
    int directionId,
    ReviewOutcome outcome, {
    required ReviewSource source,
    bool forceBonus = false,
  }) async {
    final result = await _cards.transaction(() async {
      final now = _clock();
      final direction = await _cards.getDirection(directionId);
      final card = await _cards.getCard(direction.cardId);
      final preset = await _presetOf(card);
      final isDue = _duePolicy.isDueToday(
        direction,
        cardSuspended: card.suspended,
        now: now,
      );
      if (forceBonus || !isDue) {
        await _recordBonus(direction, outcome, source, now);
        return ReviewResult(isBonus: true, schedule: null, preset: preset);
      } else {
        final schedule = await previewAnswer(direction, outcome, preset, now);
        await _cards.applySchedule(direction.id, schedule, reviewedAt: now);
        await _reviews.insert(
          directionId: direction.id,
          reviewedAt: now,
          outcome: outcome,
          isBonus: false,
          stepBefore: direction.step,
          stepAfter: schedule.step,
          dueAtAfter: schedule.dueAt,
          source: source,
        );
        return ReviewResult(isBonus: false, schedule: schedule, preset: preset);
      }
    });
    if (!result.isBonus) {
      await _scheduleChangeListener.onSchedulesChanged();
    }
    return result;
  }

  /// What each answer would do to a direction right now, without recording
  /// anything; [asBonus] previews a bonus review.
  Future<AnswerPreview> preview(int directionId, {bool asBonus = false}) async {
    final now = _clock();
    final direction = await _cards.getDirection(directionId);
    final card = await _cards.getCard(direction.cardId);
    final isDue = _duePolicy.isDueToday(
      direction,
      cardSuspended: card.suspended,
      now: now,
    );
    if (asBonus || !isDue) {
      return const AnswerPreview.noEffect();
    } else {
      final preset = await _presetOf(card);
      return AnswerPreview(
        correct: await previewAnswer(
          direction,
          ReviewOutcome.correct,
          preset,
          now,
        ),
        again: await previewAnswer(direction, ReviewOutcome.again, preset, now),
      );
    }
  }

  /// Schedule [outcome] would give, without recording anything.
  Future<DirectionSchedule> previewAnswer(
    CardDirection direction,
    ReviewOutcome outcome,
    Preset preset,
    DateTime now,
  ) async {
    final opposite = (await _cards.getDirections(direction.cardId))
        .where((other) => other.id != direction.id && other.isScheduled)
        .firstOrNull;
    return _scheduler.afterAnswer(
      direction: direction,
      outcome: outcome,
      preset: preset,
      answeredAt: now,
      oppositeDueAt: opposite?.dueAt,
    );
  }

  Future<void> _recordBonus(
    CardDirection direction,
    ReviewOutcome outcome,
    ReviewSource source,
    DateTime now,
  ) => _reviews.insert(
    directionId: direction.id,
    reviewedAt: now,
    outcome: outcome,
    isBonus: true,
    stepBefore: direction.step,
    stepAfter: direction.step,
    dueAtAfter: null,
    source: source,
  );

  Future<Preset> _presetOf(Flashcard card) async =>
      (await _presets.loadCatalog()).presetForCard(card);
}
