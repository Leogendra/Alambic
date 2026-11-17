import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/domain/presets/preset_resolver.dart';

void main() {
  test('the group choice wins over the global preset', () {
    expect(PresetResolver.resolve(groupPresetId: 2, globalPresetId: 1), 2);
  });

  test('a group without choice inherits the global preset', () {
    expect(PresetResolver.resolve(groupPresetId: null, globalPresetId: 1), 1);
  });
}
