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
      );
      expect(find.text('Default'), findsOneWidget);
      expect(find.text('Make default'), findsOneWidget);
      expect(find.text('On failure: one step back'), findsNWidgets(2));
      await expectLater(
        find.byType(PresetsScreen),
        matchesGoldenFile('goldens/presets_list$suffix.png'),
      );
    });
  }

  testWidgets('"Make default" makes a preset the global one', (tester) async {
    await pumpGolden(
      tester,
      const PresetsScreen(),
      overrides: [databaseProvider.overrideWithValue(database)],
    );
    await tester.tap(
      find.widgetWithText(OutlinedButton, l10n.presetMakeDefault),
    );
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
    );
    await tester.tap(find.byTooltip('Actions for Intensive'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.presetDuplicate));
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();
    final presets = await tester.runAsync(
      () => PresetRepository(database).watchAll().first,
    );
    expect(presets!.map((preset) => preset.name), [
      'Standard',
      'Intensive',
      'Intensive (copy)',
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
      for (final name in ['Capitals', 'Spanish']) {
        final groupId = await groups.create(name, DateTime(2026, 11, 10));
        await groups.setPreset(groupId, intensiveId);
      }
    });
    await pumpGolden(
      tester,
      const PresetsScreen(),
      overrides: [databaseProvider.overrideWithValue(database)],
    );
    await tester.tap(find.byTooltip('Actions for Standard'));
    await tester.pumpAndSettle();
    expect(find.text('Duplicate'), findsOneWidget);
    expect(find.text('Delete'), findsNothing);
    await tester.tapAt(Offset.zero);
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Actions for Intensive'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.commonDelete));
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();
    expect(find.text('Delete "Intensive"?'), findsOneWidget);
    expect(
      find.text(
        '2 groups use it: they will move to the default preset, Standard, '
        'keeping their steps and due dates.',
      ),
      findsOneWidget,
    );
    await tester.tap(find.widgetWithText(TextButton, l10n.commonDelete));
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
    );
    expect(
      find.text('A missed card goes back to the previous step.'),
      findsOneWidget,
    );
    await tester.tap(find.text(l10n.presetFailureRestart));
    await tester.pump();
    expect(
      find.text(
        'A missed card starts again from the first step, without going back '
        'to the queue.',
      ),
      findsOneWidget,
    );
    await tester.tap(find.text(l10n.presetFailureStay));
    await tester.pump();
    expect(
      find.text(
        'A missed card keeps its step and comes back after the same interval.',
      ),
      findsOneWidget,
    );
  });
}
