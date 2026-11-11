import 'package:flutter_test/flutter_test.dart';
import 'package:remanence/data/data_providers.dart';
import 'package:remanence/data/database/remanence_database.dart';
import 'package:remanence/data/repositories/preset_repository.dart';
import 'package:remanence/features/presets/preset_editor_screen.dart';
import 'package:remanence/features/presets/presets_screen.dart';

import '../../support/golden_harness.dart';
import '../../support/test_database.dart';

void main() {
  late RemanenceDatabase database;

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
}
