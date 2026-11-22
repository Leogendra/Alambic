import '../../data/images/image_store.dart';
import '../../data/repositories/card_repository.dart';
import '../../data/repositories/group_repository.dart';
import '../../data/repositories/notification_settings_repository.dart';
import '../../data/repositories/preset_repository.dart';
import '../../domain/cards/card_state.dart';
import '../../domain/groups/after_last_step.dart';
import '../../domain/groups/remanence_interval.dart';
import '../../domain/scheduling/card_schedule.dart';
import '../../domain/scheduling/review_scheduler.dart';
import '../clock.dart';
import '../scheduling/schedule_change_listener.dart';

/// Creation and settings of groups.
class GroupService {
  const GroupService({
    required this._groups,
    required this._cards,
    required this._presets,
    required this._settings,
    required this._images,
    required this._scheduler,
    required this._clock,
    required this._scheduleChangeListener,
  });

  final GroupRepository _groups;
  final CardRepository _cards;
  final PresetRepository _presets;
  final NotificationSettingsRepository _settings;
  final ImageStore _images;
  final ReviewScheduler _scheduler;
  final Clock _clock;
  final ScheduleChangeListener _scheduleChangeListener;

  /// Returns the id of the new group.
  Future<int> create(String name) {
    _checkName(name);
    return _groups.create(name.trim(), _clock());
  }

  /// The id of the group named [name], or `null` when there is none.
  Future<int?> findIdByName(String name) async =>
      (await _groups.findByName(name.trim()))?.id;

  Future<void> rename(int groupId, String name) {
    _checkName(name);
    return _groups.rename(groupId, name.trim());
  }

  /// Steps and due dates of the cards of the group are kept; their
  /// notifications follow the new preset.
  Future<void> setPreset(int groupId, int presetId) async {
    await _groups.setPreset(groupId, presetId);
    await _scheduleChangeListener.onSchedulesChanged();
  }

  /// With the back enabled, each display of a card of the group asks the
  /// front or the back, drawn one chance in two. Progressions are untouched.
  Future<void> setReverseEnabled(int groupId, {required bool enabled}) =>
      _groups.setReverseEnabled(groupId, enabled: enabled);

  /// Applies at once to the cards past their last step. Switched to
  /// "acquired", they lose their due date. Switched back to remanence, each
  /// is due one remanence interval after its last review, or after today
  /// when that day has already passed.
  Future<void> setAfterLastStep(
    int groupId,
    AfterLastStep afterLastStep,
  ) async {
    final rescheduled = await _cards.transaction(() async {
      if ((await _groups.find(groupId))?.afterLastStep == afterLastStep) {
        return false;
      }
      await _groups.setAfterLastStep(groupId, afterLastStep);
      final completed = [
        for (final card in await _cards.getCardsOfGroup(groupId))
          if (card.state == CardState.completed) card,
      ];
      if (completed.isEmpty) {
        return false;
      }
      switch (afterLastStep) {
        case AfterLastStep.acquired:
          for (final card in completed) {
            await _cards.applySchedule(card.id, CardSchedule.acquired);
          }
        case AfterLastStep.remanence:
          final catalog = await _presets.loadCatalog();
          final dailySlot = (await _settings.loadReminderSettings()).dailySlot;
          final now = _clock();
          for (final card in completed) {
            await _cards.applySchedule(
              card.id,
              _scheduler.backToRemanence(
                lastReviewedAt: card.lastReviewedAt ?? now,
                preset: catalog.presetForGroup(groupId),
                end: catalog.sequenceEndForGroup(groupId),
                now: now,
                dailySlot: dailySlot,
              ),
            );
          }
      }
      return true;
    });
    if (rescheduled) {
      await _scheduleChangeListener.onSchedulesChanged();
    }
  }

  /// Moves no due date: the new interval applies from the next answer.
  Future<void> setRemanenceInterval(int groupId, RemanenceInterval interval) =>
      _groups.setRemanenceInterval(groupId, interval);

  /// The cards of the group whose answer face has text are answered by
  /// typing it. Their next notifications follow.
  Future<void> setTypedAnswer(int groupId, {required bool enabled}) =>
      _groups.setTypedAnswer(groupId, enabled: enabled);

  /// Deletes the group with all its cards, their history and their images.
  Future<void> delete(int groupId) async {
    final images = [
      for (final card in await _cards.getCardsOfGroup(groupId))
        for (final image in [card.frontImagePath, card.backImagePath]) ?image,
    ];
    await _groups.delete(groupId);
    for (final image in images) {
      await _images.delete(image);
    }
    await _scheduleChangeListener.onSchedulesChanged();
  }

  void _checkName(String name) {
    if (name.trim().isEmpty) {
      throw ArgumentError.value(name, 'name', 'must not be empty');
    }
  }
}
