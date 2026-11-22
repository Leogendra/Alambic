import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:alambic/app/widgets/choice_tile.dart';
import 'package:alambic/data/data_providers.dart';
import 'package:alambic/data/database/alambic_database.dart';
import 'package:alambic/data/repositories/group_repository.dart';
import 'package:alambic/data/repositories/preset_repository.dart';
import 'package:alambic/app/formatting/interval_labels.dart';
import 'package:alambic/domain/presets/built_in_preset_key.dart';
import 'package:alambic/domain/presets/interval_unit.dart';
import 'package:alambic/domain/presets/preset_interval.dart';
import 'package:alambic/features/presets/preset_editor_screen.dart';
import 'package:alambic/features/presets/presets_screen.dart';

import '../../support/screen_harness.dart';
import '../../support/test_database.dart';
import '../../support/test_screen.dart';

void main() {
  late AlambicDatabase database;

  setUp(() => database = openTestDatabase());
  tearDown(() => closeTestDatabase(database));

  for (final (brightness, suffix) in [
    (Brightness.light, ''),
    (Brightness.dark, '_dark'),
  ]) {
    testScreen('presets list, ${brightness.name} theme', (tester) async {
      await pumpScreen(
        tester,
        const PresetsScreen(),
        brightness: brightness,
        overrides: [databaseProvider.overrideWithValue(database)],
      );
      expect(find.text('Default'), findsOneWidget);
      expect(find.text('Make default'), findsOneWidget);
      expect(find.text('On failure: one step back'), findsNWidgets(2));
      await captureShot(
        tester,
        find.byType(PresetsScreen),
        'presets_list$suffix',
      );
      await expectNoOverflow(tester);
    });
  }

  testScreen('"Make default" makes a preset the global one', (tester) async {
    await pumpScreen(
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

  testScreen('the tile menu duplicates a preset', (tester) async {
    await pumpScreen(
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

  testScreen('the tile menu deletes a preset after saying who uses it', (
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
    await pumpScreen(
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
    testScreen('preset editor on Standard, ${brightness.name} theme', (
      tester,
    ) async {
      final standard = await tester.runAsync(
        () async =>
            (await PresetRepository(database).loadCatalog()).globalPreset,
      );
      await pumpScreen(
        tester,
        PresetEditorScreen(initialPreset: standard!),
        brightness: brightness,
        overrides: [databaseProvider.overrideWithValue(database)],
      );
      expect(find.text('Standard'), findsNWidgets(2));
      await tester.ensureVisible(find.text(l10n.presetFailureStay));
      expect(find.text(l10n.presetFailureStepBackEffect), findsOneWidget);
      await captureShot(
        tester,
        find.byType(PresetEditorScreen),
        'preset_editor$suffix',
      );
      await expectNoOverflow(tester);
    });
  }

  testScreen('a step added in the editor lands in order on the timeline', (
    tester,
  ) async {
    final standard = await tester.runAsync(
      () async => (await PresetRepository(database).loadCatalog()).globalPreset,
    );
    await pumpScreen(
      tester,
      PresetEditorScreen(initialPreset: standard!),
      overrides: [databaseProvider.overrideWithValue(database)],
    );
    final addStep = find.widgetWithText(ActionChip, l10n.presetEditorAddStep);
    await tester.ensureVisible(addStep);
    await tester.tap(addStep);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, '3');
    await tester.tap(find.text(l10n.commonAdd));
    await tester.pumpAndSettle();
    double top(PresetInterval step) =>
        tester.getTopLeft(find.text(l10n.intervalLabel(step))).dy;
    const twoDays = PresetInterval(2, IntervalUnit.day);
    const threeDays = PresetInterval(3, IntervalUnit.day);
    const oneWeek = PresetInterval(1, IntervalUnit.week);
    expect(top(twoDays), lessThan(top(threeDays)));
    expect(top(threeDays), lessThan(top(oneWeek)));
  });

  testScreen('a step removed in the editor leaves the others in order', (
    tester,
  ) async {
    final standard = await tester.runAsync(
      () async => (await PresetRepository(database).loadCatalog()).globalPreset,
    );
    await pumpScreen(
      tester,
      PresetEditorScreen(initialPreset: standard!),
      overrides: [databaseProvider.overrideWithValue(database)],
    );
    await tester.tap(find.byTooltip(l10n.presetEditorRemoveStep).first);
    await tester.pump();
    expect(
      find.text(l10n.intervalLabel(const PresetInterval(1, IntervalUnit.day))),
      findsNothing,
    );
    expect(find.byTooltip(l10n.presetEditorRemoveStep), findsNWidgets(5));
  });

  testScreen('the failure tiles are ordered and say their effect', (
    tester,
  ) async {
    final standard = await tester.runAsync(
      () async => (await PresetRepository(database).loadCatalog()).globalPreset,
    );
    await pumpScreen(
      tester,
      PresetEditorScreen(initialPreset: standard!),
      overrides: [databaseProvider.overrideWithValue(database)],
    );
    for (final label in [
      l10n.presetFailureRestart,
      l10n.presetFailureStepBack,
      l10n.presetFailureStay,
    ]) {
      await tester.ensureVisible(find.text(label));
    }
    double top(String text) => tester.getTopLeft(find.text(text)).dy;
    expect(
      top(l10n.presetFailureRestart),
      lessThan(top(l10n.presetFailureStepBack)),
    );
    expect(
      top(l10n.presetFailureStepBack),
      lessThan(top(l10n.presetFailureStay)),
    );
    expect(find.text(l10n.presetFailureStepBackEffect), findsOneWidget);
    expect(find.text(l10n.presetFailureRestartEffect), findsOneWidget);
    expect(find.text(l10n.presetFailureStayEffect), findsOneWidget);
  });

  testScreen('a failure tile selects its behaviour in the draft', (
    tester,
  ) async {
    final standard = await tester.runAsync(
      () async => (await PresetRepository(database).loadCatalog()).globalPreset,
    );
    await pumpScreen(
      tester,
      PresetEditorScreen(initialPreset: standard!),
      overrides: [databaseProvider.overrideWithValue(database)],
    );
    Finder tile(String label) =>
        find.ancestor(of: find.text(label), matching: find.byType(ChoiceTile));
    bool isSelected(String label) =>
        tester.widget<ChoiceTile>(tile(label)).isSelected;
    expect(isSelected(l10n.presetFailureStepBack), isTrue);
    await tester.ensureVisible(find.text(l10n.presetFailureStay));
    await tester.tap(find.text(l10n.presetFailureStay));
    await tester.pump();
    expect(isSelected(l10n.presetFailureStay), isTrue);
    expect(isSelected(l10n.presetFailureStepBack), isFalse);
  });
}
