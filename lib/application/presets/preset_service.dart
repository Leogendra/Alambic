import '../../data/repositories/preset_repository.dart';
import '../../domain/presets/built_in_presets.dart';
import '../../domain/presets/preset.dart';

/// Creation, edition and duplication of presets.
class PresetService {
  const PresetService(this._presets);

  final PresetRepository _presets;

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
      return preset.id;
    }
  }

  /// Stores a copy of [preset] under [copyName] and returns its id. The copy is
  /// never a shipped preset, even when copied from one.
  Future<int> duplicate(Preset preset, String copyName) => _presets.insert(
    preset.copyWith(id: 0, name: copyName, builtInKey: () => null),
  );

  void _checkValid(Preset preset) {
    if (preset.name.trim().isEmpty) {
      throw ArgumentError.value(preset.name, 'name', 'must not be empty');
    } else if (preset.intervals.isEmpty) {
      throw ArgumentError.value(preset.intervals, 'intervals', 'needs a step');
    }
  }
}
