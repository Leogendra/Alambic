import '../../data/repositories/card_repository.dart';
import '../../domain/cards/flashcard.dart';
import '../../data/repositories/pause_repository.dart';
import '../../domain/pauses/pause_shift.dart';
import '../../domain/scheduling/card_schedule.dart';
import '../clock.dart';
import '../scheduling/schedule_change_listener.dart';

/// Pauses and resumes a group, or everything (holidays). While paused,
/// nothing is notified and no distillation introduces a card; the cards stay
/// reviewable in the app. On resume, the due dates are shifted by the length
/// of the pause.
class PauseService {
  const PauseService({
    required this._pauses,
    required this._cards,
    required this._shift,
    required this._clock,
    required this._scheduleChangeListener,
  });

  final PauseRepository _pauses;
  final CardRepository _cards;
  final PauseShift _shift;
  final Clock _clock;
  final ScheduleChangeListener _scheduleChangeListener;

  Future<void> pauseGroup(int groupId) async {
    if (!(await _pauses.loadPauses()).groupsSince.containsKey(groupId)) {
      await _pauses.setGroupPausedAt(groupId, _clock());
      await _scheduleChangeListener.onSchedulesChanged();
    }
  }

  /// Shifts the due dates of the group's cards by the length of its pause.
  Future<void> resumeGroup(int groupId) async {
    final pausedAt = (await _pauses.loadPauses()).groupsSince[groupId];
    if (pausedAt == null) {
      return;
    }
    await _cards.transaction(() async {
      await _shiftDueDates(await _cards.getCardsOfGroup(groupId), pausedAt);
      await _pauses.setGroupPausedAt(groupId, null);
    });
    await _scheduleChangeListener.onSchedulesChanged();
  }

  Future<void> pauseAll() async {
    if (!(await _pauses.loadPauses()).isGlobal) {
      await _pauses.setGlobalPausedAt(_clock());
      await _scheduleChangeListener.onSchedulesChanged();
    }
  }

  /// Shifts every due date by the length of the global pause, except in the
  /// groups still paused on their own: their resume shifts them by their
  /// whole pause.
  Future<void> resumeAll() async {
    final pauses = await _pauses.loadPauses();
    final pausedAt = pauses.globalSince;
    if (pausedAt == null) {
      return;
    }
    await _cards.transaction(() async {
      await _shiftDueDates(
        (await _cards.getAll()).where(
          (card) => !pauses.groupsSince.containsKey(card.groupId),
        ),
        pausedAt,
      );
      await _pauses.setGlobalPausedAt(null);
    });
    await _scheduleChangeListener.onSchedulesChanged();
  }

  Future<void> _shiftDueDates(
    Iterable<Flashcard> cards,
    DateTime pausedAt,
  ) async {
    final now = _clock();
    for (final card in cards) {
      final shifted = _shift.shiftedDueAt(
        card,
        pausedAt: pausedAt,
        resumedAt: now,
      );
      if (shifted != null) {
        await _cards.applySchedule(
          card.id,
          CardSchedule(state: card.state, step: card.step, dueAt: shifted),
        );
      }
    }
  }
}
