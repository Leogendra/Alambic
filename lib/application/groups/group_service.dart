import '../../data/repositories/group_repository.dart';
import '../clock.dart';
import '../scheduling/schedule_change_listener.dart';

/// Creation and settings of groups.
class GroupService {
  const GroupService({
    required this._groups,
    required this._clock,
    required this._scheduleChangeListener,
  });

  final GroupRepository _groups;
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
  /// its cards are kept.
  Future<void> setPreset(int groupId, int? presetId) =>
      _groups.setPreset(groupId, presetId);

  /// Deletes the group with all its cards and their history.
  Future<void> delete(int groupId) async {
    await _groups.delete(groupId);
    await _scheduleChangeListener.onSchedulesChanged();
  }

  void _checkName(String name) {
    if (name.trim().isEmpty) {
      throw ArgumentError.value(name, 'name', 'must not be empty');
    }
  }
}
