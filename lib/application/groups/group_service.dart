import '../../data/images/image_store.dart';
import '../../data/repositories/card_repository.dart';
import '../../data/repositories/group_repository.dart';
import '../clock.dart';
import '../scheduling/schedule_change_listener.dart';

/// Creation and settings of groups.
class GroupService {
  const GroupService({
    required this._groups,
    required this._cards,
    required this._images,
    required this._clock,
    required this._scheduleChangeListener,
  });

  final GroupRepository _groups;
  final CardRepository _cards;
  final ImageStore _images;
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
