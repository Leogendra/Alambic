import '../../data/repositories/card_repository.dart';
import '../../data/repositories/notification_settings_repository.dart';
import '../../data/repositories/preset_repository.dart';
import '../../data/repositories/review_repository.dart';
import '../../domain/cards/flashcard.dart';
import '../../domain/presets/preset.dart';
import '../../domain/reviews/review_outcome.dart';
import '../../domain/reviews/review_source.dart';
import '../../domain/scheduling/card_schedule.dart';
import '../../domain/scheduling/clock_time.dart';
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

  /// Records [outcome] for a card. The answer is a bonus review, kept in the
  /// history without any effect, when the card is not due (a pending card
  /// stays pending) or when [forceBonus] is set (reviewing the missed cards
  /// again, extra reminder).
  Future<ReviewResult> answer(
    int cardId,
    ReviewOutcome outcome, {
    required ReviewSource source,
    bool forceBonus = false,
  }) async {
    final result = await _cards.transaction(() async {
      final now = _clock();
      final card = await _cards.getCard(cardId);
      final preset = await _presetOf(card);
      if (forceBonus || !_duePolicy.isDueToday(card, now: now)) {
        await _recordBonus(card, outcome, source, now);
        return ReviewResult(isBonus: true, schedule: null, preset: preset);
      } else {
        final schedule = previewAnswer(
          card,
          outcome,
          preset,
          now,
          await _dailySlot(),
        );
        await _cards.applySchedule(card.id, schedule, reviewedAt: now);
        await _reviews.insert(
          cardId: card.id,
          reviewedAt: now,
          outcome: outcome,
          isBonus: false,
          stepBefore: card.step,
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

  /// What each answer would do to a card right now, without recording
  /// anything; [asBonus] previews a bonus review.
  Future<AnswerPreview> preview(int cardId, {bool asBonus = false}) async {
    final now = _clock();
    final card = await _cards.getCard(cardId);
    if (asBonus || !_duePolicy.isDueToday(card, now: now)) {
      return const AnswerPreview.noEffect();
    } else {
      final preset = await _presetOf(card);
      final dailySlot = await _dailySlot();
      return AnswerPreview(
        correct: previewAnswer(
          card,
          ReviewOutcome.correct,
          preset,
          now,
          dailySlot,
        ),
        again: previewAnswer(card, ReviewOutcome.again, preset, now, dailySlot),
      );
    }
  }

  /// Schedule [outcome] would give, without recording anything.
  CardSchedule previewAnswer(
    Flashcard card,
    ReviewOutcome outcome,
    Preset preset,
    DateTime now,
    ClockTime dailySlot,
  ) => _scheduler.afterAnswer(
    card: card,
    outcome: outcome,
    preset: preset,
    answeredAt: now,
    dailySlot: dailySlot,
  );

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
    dueAtAfter: null,
    source: source,
  );

  Future<ClockTime> _dailySlot() async =>
      (await _settings.loadReminderSettings()).dailySlot;

  Future<Preset> _presetOf(Flashcard card) async =>
      (await _presets.loadCatalog()).presetForCard(card);
}
