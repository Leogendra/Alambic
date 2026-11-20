import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/data/data_providers.dart';
import 'package:alambic/data/database/alambic_database.dart';
import 'package:alambic/data/repositories/group_repository.dart';
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

  for (final (brightness, suffix) in [
    (Brightness.light, ''),
    (Brightness.dark, '_dark'),
  ]) {
    testWidgets('presets list, ${brightness.name} theme', (tester) async {
      await pumpGolden(
        tester,
        const PresetsScreen(),
        brightness: brightness,
        overrides: [databaseProvider.overrideWithValue(database)],
        locale: const Locale('fr'),
      );
      expect(find.text('Par défaut'), findsNWidgets(2));
      expect(find.text("En cas d'échec : recule d'un cran"), findsNWidgets(2));
      await expectLater(
        find.byType(PresetsScreen),
        matchesGoldenFile('goldens/presets_list$suffix.png'),
      );
    });
  }

  testWidgets('"Par défaut" makes a preset the global one', (tester) async {
    await pumpGolden(
      tester,
      const PresetsScreen(),
      overrides: [databaseProvider.overrideWithValue(database)],
      locale: const Locale('fr'),
    );
    await tester.tap(find.widgetWithText(OutlinedButton, 'Par défaut'));
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();
    final catalog = await tester.runAsync(
      () => PresetRepository(database).loadCatalog(),
    );
    expect(catalog!.globalPreset.builtInKey, BuiltInPresetKey.intensive);
  });

  testWidgets('the tile menu duplicates a preset', (tester) async {
    await pumpGolden(
      tester,
      const PresetsScreen(),
      overrides: [databaseProvider.overrideWithValue(database)],
      locale: const Locale('fr'),
    );
    await tester.tap(find.byTooltip('Actions du preset Intensif'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dupliquer'));
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();
    final presets = await tester.runAsync(
      () => PresetRepository(database).watchAll().first,
    );
    expect(presets!.map((preset) => preset.name), [
      'Standard',
      'Intensive',
      'Intensif (copie)',
    ]);
  });

  testWidgets('the tile menu deletes a preset after saying who uses it', (
    tester,
  ) async {
    await tester.runAsync(() async {
      final groups = GroupRepository(database);
      final catalog = await PresetRepository(database).loadCatalog();
      final intensiveId = catalog.presetsById.values
          .firstWhere(
            (preset) => preset.builtInKey == BuiltInPresetKey.intensive,
          )
          .id;
      for (final name in ['Capitales', 'Espagnol']) {
        final groupId = await groups.create(name, DateTime(2026, 11, 10));
        await groups.setPreset(groupId, intensiveId);
      }
    });
    await pumpGolden(
      tester,
      const PresetsScreen(),
      overrides: [databaseProvider.overrideWithValue(database)],
      locale: const Locale('fr'),
    );
    await tester.tap(find.byTooltip('Actions du preset Standard'));
    await tester.pumpAndSettle();
    expect(find.text('Dupliquer'), findsOneWidget);
    expect(find.text('Supprimer'), findsNothing);
    await tester.tapAt(Offset.zero);
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Actions du preset Intensif'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Supprimer'));
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();
    expect(find.text('Supprimer « Intensif » ?'), findsOneWidget);
    expect(
      find.text(
        "2 groupes l'utilisent : ils passeront sur le preset par défaut, "
        'Standard, en gardant leurs crans et leurs échéances.',
      ),
      findsOneWidget,
    );
    await tester.tap(find.widgetWithText(TextButton, 'Supprimer'));
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();
    final presets = await tester.runAsync(
      () => PresetRepository(database).watchAll().first,
    );
    expect(presets!.map((preset) => preset.name), ['Standard']);
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
        locale: const Locale('fr'),
      );
      await expectLater(
        find.byType(PresetEditorScreen),
        matchesGoldenFile('goldens/preset_editor$suffix.png'),
      );
    });
  }

  testWidgets('the line under the failure choice says its effect', (
    tester,
  ) async {
    final standard = await tester.runAsync(
      () async => (await PresetRepository(database).loadCatalog()).globalPreset,
    );
    await pumpGolden(
      tester,
      PresetEditorScreen(initialPreset: standard!),
      overrides: [databaseProvider.overrideWithValue(database)],
      locale: const Locale('fr'),
    );
    expect(
      find.text('Une carte ratée revient au cran précédent.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Retour au début'));
    await tester.pump();
    expect(
      find.text(
        'Une carte ratée repart du premier cran, sans retourner dans la file.',
      ),
      findsOneWidget,
    );
    await tester.tap(find.text('Reste'));
    await tester.pump();
    expect(
      find.text(
        'Une carte ratée garde son cran et revient après le même intervalle.',
      ),
      findsOneWidget,
    );
  });
}
