import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/data/data_providers.dart';
import 'package:alambic/data/database/alambic_database.dart';
import 'package:alambic/data/repositories/preset_repository.dart';
import 'package:alambic/domain/presets/built_in_preset_key.dart';
import 'package:alambic/features/presets/preset_editor_screen.dart';
import 'package:alambic/features/presets/presets_screen.dart';

import '../../support/golden_harness.dart';
import '../../support/test_database.dart';

void main() {
  late AlambicDatabase database;

  setUp(() => database = openTestDatabase());
  tearDown(() => database.close());

  testWidgets('presets list', (tester) async {
    await pumpGolden(
      tester,
      const PresetsScreen(),
      overrides: [databaseProvider.overrideWithValue(database)],
    );
    await expectLater(
      find.byType(PresetsScreen),
      matchesGoldenFile('goldens/presets_list.png'),
    );
  });

  testWidgets('preset editor on Standard', (tester) async {
    final standard = await tester.runAsync(
      () async => (await PresetRepository(database).loadCatalog()).globalPreset,
    );
    await pumpGolden(
      tester,
      PresetEditorScreen(initialPreset: standard!),
      overrides: [databaseProvider.overrideWithValue(database)],
    );
    await expectLater(
      find.byType(PresetEditorScreen),
      matchesGoldenFile('goldens/preset_editor.png'),
    );
  });

  testWidgets('preset editor on Adaptatif', (tester) async {
    final adaptive = await tester.runAsync(
      () async =>
          (await PresetRepository(database).watchAll().first).firstWhere(
            (preset) => preset.builtInKey == BuiltInPresetKey.adaptive,
          ),
    );
    await pumpGolden(
      tester,
      PresetEditorScreen(initialPreset: adaptive!),
      overrides: [databaseProvider.overrideWithValue(database)],
    );
    await expectLater(
      find.byType(PresetEditorScreen),
      matchesGoldenFile('goldens/preset_editor_adaptive.png'),
    );
    await tester.tap(find.byTooltip('Augmenter la rétention visée'));
    await tester.pump();
    expect(find.text('91 %'), findsOneWidget);
  });
}
