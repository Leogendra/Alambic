import 'package:flutter_test/flutter_test.dart';
import 'package:remanence/domain/presets/preset_resolver.dart';

void main() {
  test('the card choice wins over the group and the global preset', () {
    expect(
      PresetResolver.resolve(
        cardPresetId: 3,
        groupPresetId: 2,
        globalPresetId: 1,
      ),
      3,
    );
  });

  test('a card without choice inherits its group preset', () {
    expect(
      PresetResolver.resolve(
        cardPresetId: null,
        groupPresetId: 2,
        globalPresetId: 1,
      ),
      2,
    );
  });

  test('a card outside any group inherits the global preset', () {
    expect(
      PresetResolver.resolve(
        cardPresetId: null,
        groupPresetId: null,
        globalPresetId: 1,
      ),
      1,
    );
  });
}
