import '../../data/repositories/card_repository.dart';
import '../../data/repositories/notification_settings_repository.dart';
import '../../data/repositories/preset_repository.dart';
import '../../data/repositories/review_repository.dart';
import '../../domain/cards/card_side.dart';
import '../../domain/cards/flashcard.dart';
import '../../domain/distillation/distillation_queue.dart';
import '../../domain/reviews/review_outcome.dart';
import '../../domain/reviews/review_source.dart';
import '../../domain/reviews/typed_answer_match.dart';
import '../../domain/scheduling/card_schedule.dart';
import '../../domain/scheduling/clock_time.dart';
import '../../domain/scheduling/due_policy.dart';
import '../../domain/scheduling/due_smoothing.dart';
import '../../domain/scheduling/review_scheduler.dart';
import '../clock.dart';
import '../scheduling/schedule_change_listener.dart';
import 'answer_preview.dart';
import 'review_result.dart';
import 'typed_answer_result.dart';

/// Records answers, from a session or a notification, and reschedules.
class ReviewService {
  const ReviewService({
    required this._cards,
    required this._presets,
    required this._settings,
    required this._reviews,
    required this._scheduler,
    required this._duePolicy,
    required this._clock,
    required this._scheduleChangeListener,
  });

  final CardRepository _cards;
  final PresetRepository _presets;
  final NotificationSettingsRepository _settings;
  final ReviewRepository _reviews;
  final ReviewScheduler _scheduler;
  final DuePolicy _duePolicy;
  final Clock _clock;
  final ScheduleChangeListener _scheduleChangeListener;

  /// Compares [typed] with the answer face of a card asking [askedSide],
  /// then records it like [answer]: Correct when accepted, Again otherwise.
  /// The same rules hold in a notification and in a session.
  Future<TypedAnswerResult> answerTyped(
    int cardId,
    String typed, {
    required CardSide askedSide,
    required ReviewSource source,
    bool forceBonus = false,
    bool raisesMissedPending = false,
  }) async {
    final card = await _cards.getCard(cardId);
    final match = TypedAnswerMatch.compare(
      typed,
      card.answerFor(askedSide).text ?? '',
    );
    final result = await answer(
      cardId,
      match.isAccepted ? ReviewOutcome.correct : ReviewOutcome.again,
      source: source,
      forceBonus: forceBonus,
      raisesMissedPending: raisesMissedPending,
    );
    return TypedAnswerResult(match: match, result: result);
  }

  /// Records [outcome] for a card. The answer is a bonus review, kept in the
  /// history without any effect, when the card is not due (a pending card
  /// stays pending) or when [forceBonus] is set (reviewing the missed cards
  /// again). With [raisesMissedPending] ("Review all" of a
  /// group), a pending card answered "Again" goes to the head of its queue.
  Future<ReviewResult> answer(
    int cardId,
    ReviewOutcome outcome, {
    required ReviewSource source,
    bool forceBonus = false,
    bool raisesMissedPending = false,
  }) async {
    final result = await _cards.transaction(() async {
      final now = _clock();
      final card = await _cards.getCard(cardId);
      final catalog = await _presets.loadCatalog();
      if (forceBonus || !_duePolicy.isDueToday(card, now: now)) {
        await _recordBonus(card, outcome, source, now);
        if (raisesMissedPending &&
            !forceBonus &&
            card.isPending &&
            outcome == ReviewOutcome.again) {
          await _raiseToHead(card);
        }
        return const ReviewResult(isBonus: true, schedule: null);
      } else {
        final schedule = _scheduler.afterAnswer(
          card: card,
          outcome: outcome,
          preset: catalog.presetForGroup(card.groupId),
          end: catalog.sequenceEndForGroup(card.groupId),
          answeredAt: now,
          dailySlot: await _dailySlot(),
          smoothing: await _smoothing(card),
        );
        await _cards.applySchedule(card.id, schedule, reviewedAt: now);
        await _reviews.insert(
          cardId: card.id,
          reviewedAt: now,
          outcome: outcome,
          isBonus: false,
          stepBefore: card.step,
          stepAfter: schedule.step,
          stateAfter: schedule.state,
          dueAtAfter: schedule.dueAt,
          source: source,
        );
        return ReviewResult(isBonus: false, schedule: schedule);
      }
    });
    if (!result.isBonus) {
      await _scheduleChangeListener.onSchedulesChanged();
    }
    return result;
  }

  /// What each answer would do to a card right now, without recording
  /// anything; [asBonus] previews a bonus review.
  Future<AnswerPreview> preview(int cardId, {bool asBonus = false}) async {
    final now = _clock();
    final card = await _cards.getCard(cardId);
    if (asBonus || !_duePolicy.isDueToday(card, now: now)) {
      return const AnswerPreview.noEffect();
    } else {
      final catalog = await _presets.loadCatalog();
      final dailySlot = await _dailySlot();
      final smoothing = await _smoothing(card);
      CardSchedule after(ReviewOutcome outcome) => _scheduler.afterAnswer(
        card: card,
        outcome: outcome,
        preset: catalog.presetForGroup(card.groupId),
        end: catalog.sequenceEndForGroup(card.groupId),
        answeredAt: now,
        dailySlot: dailySlot,
        smoothing: smoothing,
      );
      return AnswerPreview(
        correct: after(ReviewOutcome.correct),
        again: after(ReviewOutcome.again),
      );
    }
  }

  Future<void> _recordBonus(
    Flashcard card,
    ReviewOutcome outcome,
    ReviewSource source,
    DateTime now,
  ) => _reviews.insert(
    cardId: card.id,
    reviewedAt: now,
    outcome: outcome,
    isBonus: true,
    stepBefore: card.step,
    stepAfter: card.step,
    stateAfter: null,
    dueAtAfter: null,
    source: source,
  );

  /// The card will be the next one the distillation introduces, ahead of the
  /// cards raised before it.
  Future<void> _raiseToHead(Flashcard card) async => _cards.setQueuePosition(
    card.id,
    DistillationQueue.headPosition(await _cards.getCardsOfGroup(card.groupId)),
  );

  Future<ClockTime> _dailySlot() async =>
      (await _settings.loadReminderSettings()).dailySlot;

  /// The days [card] may move to after an answer, against every other card
  /// due; `null` when the smoothing is turned off in Settings.
  Future<DueSmoothing?> _smoothing(Flashcard card) async =>
      (await _settings.loadGuards()).smoothDueDates
      ? DueSmoothing.of(
          await _cards.getAll(),
          _scheduler.calendar,
          excluded: card.id,
        )
      : null;
}
