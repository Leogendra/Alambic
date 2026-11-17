import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/domain/presets/preset_catalog.dart';

import '../test_presets.dart';

void main() {
  final catalog = PresetCatalog(
    presetsById: {
      standardPreset.id: standardPreset,
      intensivePreset.id: intensivePreset,
    },
    globalPresetId: standardPreset.id,
    groupPresetIds: {10: intensivePreset.id, 11: null},
  );

  test('a group follows its own choice', () {
    expect(catalog.presetForGroup(10), intensivePreset);
  });

  test('a group without choice, or unknown, follows the global preset', () {
    expect(catalog.presetForGroup(11), standardPreset);
    expect(catalog.presetForGroup(12), standardPreset);
  });
}
