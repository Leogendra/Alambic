import '../../data/repositories/group_repository.dart';
import '../../data/repositories/preset_repository.dart';
import '../../domain/presets/built_in_presets.dart';
import '../../domain/presets/preset.dart';
import '../scheduling/ignored_schedule_changes.dart';
import '../scheduling/schedule_change_listener.dart';

/// Creation, edition, duplication and deletion of presets.
class PresetService {
  const PresetService(
    this._presets,
    this._groups, [
    this._scheduleChangeListener = const IgnoredScheduleChanges(),
  ]);

  final PresetRepository _presets;
  final GroupRepository _groups;

  /// Told when a preset is edited: its steps decide when its cards come
  /// back.
  final ScheduleChangeListener _scheduleChangeListener;

  /// A new preset starts from the Standard values.
  Preset newDraft(String name) =>
      BuiltInPresets.standard.copyWith(name: name, builtInKey: () => null);

  /// Stores [preset]: inserted when it has no id yet, updated otherwise.
  /// Returns its id.
  Future<int> save(Preset preset) async {
    _checkValid(preset);
    if (preset.id == 0) {
      return _presets.insert(preset);
    } else {
      await _presets.update(preset);
      await _scheduleChangeListener.onSchedulesChanged();
      return preset.id;
    }
  }

  /// Changing the global preset keeps every step and due date; the
  /// notifications of the cards that inherit it follow the new preset.
  Future<void> setGlobalPreset(int presetId) async {
    await _presets.setGlobalPresetId(presetId);
    await _scheduleChangeListener.onSchedulesChanged();
  }

  /// Stores a copy of [preset] under [copyName] and returns its id. The copy is
  /// never a shipped preset, even when copied from one.
  Future<int> duplicate(Preset preset, String copyName) => _presets.insert(
    preset.copyWith(id: 0, name: copyName, builtInKey: () => null),
  );

  /// Deletes a preset other than the global one. The groups that chose it
  /// go back to the global preset, keeping the steps and due dates of their
  /// cards; their notifications follow it.
  Future<void> delete(int presetId) async {
    await _presets.transaction(() async {
      final catalog = await _presets.loadCatalog();
      if (presetId == catalog.globalPresetId) {
        throw StateError('The global preset cannot be deleted.');
      }
      await _groups.releasePreset(presetId);
      await _presets.delete(presetId);
    });
    await _scheduleChangeListener.onSchedulesChanged();
  }

  void _checkValid(Preset preset) {
    if (preset.name.trim().isEmpty) {
      throw ArgumentError.value(preset.name, 'name', 'must not be empty');
    } else if (preset.intervals.isEmpty) {
      throw ArgumentError.value(preset.intervals, 'intervals', 'needs a step');
    }
  }
}
