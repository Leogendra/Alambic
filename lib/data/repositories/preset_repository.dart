import 'package:drift/drift.dart';

import '../../domain/presets/preset.dart';
import '../../domain/presets/preset_catalog.dart';
import '../database/preset_companions.dart';
import '../database/alambic_database.dart';

/// Presets, the global preset, and the resolution snapshot built from them.
class PresetRepository {
  const PresetRepository(this._database);

  final AlambicDatabase _database;

  Future<T> transaction<T>(Future<T> Function() action) =>
      _database.transaction(action);

  Stream<List<Preset>> watchAll() => (_database.select(
    _database.presets,
  )..orderBy([(preset) => OrderingTerm.asc(preset.id)])).watch();

  Future<Preset> getById(int id) => (_database.select(
    _database.presets,
  )..where((preset) => preset.id.equals(id))).getSingle();

  /// Stores a new preset and returns its id.
  Future<int> insert(Preset preset) => _database
      .into(_database.presets)
      .insert(PresetCompanions.forInsert(preset));

  Future<void> update(Preset preset) =>
      (_database.update(_database.presets)
            ..where((row) => row.id.equals(preset.id)))
          .write(PresetCompanions.forUpdate(preset));

  /// No group may still choose it: the foreign key refuses the deletion.
  Future<void> delete(int presetId) => (_database.delete(
    _database.presets,
  )..where((preset) => preset.id.equals(presetId))).go();

  Stream<int> watchGlobalPresetId() => _database
      .select(_database.appSettings)
      .watchSingle()
      .map((settings) => settings.globalPresetId);

  /// Changing the global preset keeps every step and due date as they are.
  Future<void> setGlobalPresetId(int presetId) => _database
      .update(_database.appSettings)
      .write(AppSettingsCompanion(globalPresetId: Value(presetId)));

  Future<PresetCatalog> loadCatalog() => watchCatalog().first;

  /// Re-emitted whenever a preset, the global choice or a group choice
  /// (preset or end of sequence) changes.
  Stream<PresetCatalog> watchCatalog() {
    final query = _database.customSelect(
      'SELECT 1',
      readsFrom: {
        _database.presets,
        _database.appSettings,
        _database.cardGroups,
      },
    );
    return query.watch().asyncMap((_) => _readCatalog());
  }

  Future<PresetCatalog> _readCatalog() => _database.transaction(() async {
    final presets = await _database.select(_database.presets).get();
    final settings = await _database.select(_database.appSettings).getSingle();
    final groups = await _database.select(_database.cardGroups).get();
    return PresetCatalog(
      presetsById: {for (final preset in presets) preset.id: preset},
      globalPresetId: settings.globalPresetId,
      groupPresetIds: {for (final group in groups) group.id: group.presetId},
      groupSequenceEnds: {
        for (final group in groups) group.id: group.sequenceEnd,
      },
    );
  });
}
