import '../groups/sequence_end.dart';
import 'preset.dart';
import 'preset_resolver.dart';

/// Snapshot of every preset, of the choices made at each level and of the
/// end of sequence of each group, to resolve the rhythm of many groups at
/// once (lists, sessions) without querying.
class PresetCatalog {
  const PresetCatalog({
    required this.presetsById,
    required this.globalPresetId,
    required this.groupPresetIds,
    required this.groupSequenceEnds,
  });

  final Map<int, Preset> presetsById;
  final int globalPresetId;

  /// Preset chosen by each group; a missing or `null` entry inherits.
  final Map<int, int?> groupPresetIds;

  /// End of sequence chosen by each group.
  final Map<int, SequenceEnd> groupSequenceEnds;

  Preset get globalPreset => presetsById[globalPresetId]!;

  /// Groups that chose [presetId] themselves; the groups that inherit it as
  /// the global preset are not counted.
  int groupCountChoosing(int presetId) =>
      groupPresetIds.values.where((choice) => choice == presetId).length;

  /// Preset followed by the cards of [groupId].
  Preset presetForGroup(int groupId) =>
      presetsById[PresetResolver.resolve(
        groupPresetId: groupPresetIds[groupId],
        globalPresetId: globalPresetId,
      )]!;

  /// End of sequence of the cards of [groupId].
  SequenceEnd sequenceEndForGroup(int groupId) =>
      groupSequenceEnds[groupId] ?? SequenceEnd.standard;
}
