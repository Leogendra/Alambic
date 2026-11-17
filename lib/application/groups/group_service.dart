import '../../data/images/image_store.dart';
import '../../data/repositories/card_repository.dart';
import '../../data/repositories/group_repository.dart';
import '../../data/repositories/notification_settings_repository.dart';
import '../../data/repositories/preset_repository.dart';
import '../../domain/cards/card_state.dart';
import '../../domain/groups/after_last_step.dart';
import '../../domain/groups/remanence_interval.dart';
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

  Future<void> rename(int groupId, String name) {
    _checkName(name);
    return _groups.rename(groupId, name.trim());
  }

  /// `null` makes the group inherit the global preset. Steps and due dates of
  /// its cards are kept; their notifications follow the new preset.
  Future<void> setPreset(int groupId, int? presetId) async {
    await _groups.setPreset(groupId, presetId);
    await _scheduleChangeListener.onSchedulesChanged();
  }

  /// With the back enabled, each display of a card of the group asks the
  /// front or the back, drawn one chance in two. Progressions are untouched.
  Future<void> setReverseEnabled(int groupId, {required bool enabled}) =>
      _groups.setReverseEnabled(groupId, enabled: enabled);

  /// Read at each answer, so a card in remanence of a group switched to
  /// "acquired" becomes acquired at its next success. Switching back to
  /// remanence sends the acquired cards of the group into remanence, due one
  /// remanence interval from today: none becomes due at once.
  Future<void> setAfterLastStep(
    int groupId,
    AfterLastStep afterLastStep,
  ) async {
    final revived = await _cards.transaction(() async {
      await _groups.setAfterLastStep(groupId, afterLastStep);
      if (afterLastStep != AfterLastStep.remanence) {
        return false;
      }
      final acquired = [
        for (final card in await _cards.getCardsOfGroup(groupId))
          if (card.state == CardState.acquired) card,
      ];
      if (acquired.isEmpty) {
        return false;
      }
      final catalog = await _presets.loadCatalog();
      final schedule = _scheduler.backToRemanence(
        preset: catalog.presetForGroup(groupId),
        end: catalog.sequenceEndForGroup(groupId),
        now: _clock(),
        dailySlot: (await _settings.loadReminderSettings()).dailySlot,
      );
      for (final card in acquired) {
        await _cards.applySchedule(card.id, schedule);
      }
      return true;
    });
    if (revived) {
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
