import '../groups/sequence_end.dart';
import 'preset.dart';

/// Snapshot of every preset, of the preset of each group and of the end of
/// sequence of each group, to resolve the rhythm of many groups at once
/// (lists, sessions) without querying.
class PresetCatalog {
  const PresetCatalog({
    required this.presetsById,
    required this.globalPresetId,
    required this.groupPresetIds,
    required this.groupSequenceEnds,
  });

  final Map<int, Preset> presetsById;

  /// The preset given to a new group, and to the groups of a deleted preset.
  /// A group that already has a preset does not follow its changes.
  final int globalPresetId;

  /// Preset followed by each group.
  final Map<int, int> groupPresetIds;

  /// End of sequence chosen by each group.
  final Map<int, SequenceEnd> groupSequenceEnds;

  Preset get globalPreset => presetsById[globalPresetId]!;

  /// Number of groups that follow [presetId].
  int groupCountFollowing(int presetId) =>
      groupPresetIds.values.where((followed) => followed == presetId).length;

  /// Preset followed by the cards of [groupId]; the global preset for a group
  /// created after the snapshot.
  Preset presetForGroup(int groupId) =>
      presetsById[groupPresetIds[groupId] ?? globalPresetId]!;

  /// End of sequence of the cards of [groupId].
  SequenceEnd sequenceEndForGroup(int groupId) =>
      groupSequenceEnds[groupId] ?? SequenceEnd.standard;
}
