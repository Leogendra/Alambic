import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/data/data_providers.dart';
import 'package:alambic/data/database/alambic_database.dart';
import 'package:alambic/data/repositories/preset_repository.dart';
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

  for (final (brightness, suffix) in [
    (Brightness.light, ''),
    (Brightness.dark, '_dark'),
  ]) {
    testWidgets('preset editor on Standard, ${brightness.name} theme', (
      tester,
    ) async {
      final standard = await tester.runAsync(
        () async =>
            (await PresetRepository(database).loadCatalog()).globalPreset,
      );
      await pumpGolden(
        tester,
        PresetEditorScreen(initialPreset: standard!),
        brightness: brightness,
        overrides: [databaseProvider.overrideWithValue(database)],
      );
      await expectLater(
        find.byType(PresetEditorScreen),
        matchesGoldenFile('goldens/preset_editor$suffix.png'),
      );
    });
  }
}
