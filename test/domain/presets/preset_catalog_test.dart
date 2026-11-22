import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/domain/groups/remanence_interval.dart';
import 'package:alambic/domain/groups/sequence_end.dart';
import 'package:alambic/domain/presets/preset_catalog.dart';

import '../test_groups.dart';
import '../test_presets.dart';

void main() {
  final catalog = PresetCatalog(
    presetsById: {
      standardPreset.id: standardPreset,
      intensivePreset.id: intensivePreset,
    },
    globalPresetId: standardPreset.id,
    groupPresetIds: {10: intensivePreset.id, 11: standardPreset.id},
    groupSequenceEnds: {
      10: acquiredEnd,
      11: remanence(RemanenceInterval.oneYear),
    },
  );

  test('a group follows its own preset', () {
    expect(catalog.presetForGroup(10), intensivePreset);
    expect(catalog.presetForGroup(11), standardPreset);
  });

  test('a group created after the snapshot follows the global preset', () {
    expect(catalog.presetForGroup(12), standardPreset);
  });

  test('each group has its own end of sequence', () {
    expect(catalog.sequenceEndForGroup(10), acquiredEnd);
    expect(
      catalog.sequenceEndForGroup(11),
      remanence(RemanenceInterval.oneYear),
    );
    expect(catalog.sequenceEndForGroup(12), SequenceEnd.standard);
  });

  test('counts the groups that follow a preset', () {
    expect(catalog.groupCountFollowing(intensivePreset.id), 1);
    expect(catalog.groupCountFollowing(standardPreset.id), 1);
  });
}
