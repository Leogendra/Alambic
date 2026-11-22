import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:alambic/data/database/alambic_database.dart';
import 'package:alambic/data/repositories/distillation_repository.dart';
import 'package:alambic/data/repositories/group_repository.dart';
import 'package:alambic/data/repositories/preset_repository.dart';
import 'package:alambic/domain/presets/built_in_presets.dart';
import 'package:alambic/domain/groups/card_group.dart';
import 'package:alambic/domain/distillation/distillation_settings.dart';
import 'package:alambic/app/formatting/interval_labels.dart';
import 'package:alambic/features/distillation/distill_screen.dart';
import 'package:alambic/features/groups/group_detail_screen.dart';
import 'package:alambic/features/home/home_screen.dart';
import 'package:alambic/features/presets/preset_editor_screen.dart';

import '../../support/fixed_clock.dart';
import '../../support/screen_harness.dart';
import '../../support/sample_data.dart';
import '../../support/test_database.dart';
import '../../support/test_screen.dart';

void main() {
  late AlambicDatabase database;
  late int japaneseId;

  setUp(() => database = openTestDatabase());
  tearDown(() => closeTestDatabase(database));

  /// Sample data, and a "Japanese" group of six cards distilled one card a
  /// day, activated at 9am unless [activate] is false.
  Future<void> seed(WidgetTester tester, {bool activate = true}) async {
    await tester.runAsync(() async {
      final samples = SampleServices(database, FixedClock(sampleNow));
      await seedSampleData(samples);
      japaneseId = await samples.groups.create('Japanese');
      for (final (word, meaning) in [
        ('neko', 'cat'),
        ('inu', 'dog'),
        ('tori', 'bird'),
        ('sakana', 'fish'),
        ('uma', 'horse'),
        ('ushi', 'cow'),
      ]) {
        await samples.card(word, meaning, groupId: japaneseId);
      }
      if (activate) {
        await samples.distillations.activate(
          japaneseId,
          const DistillationSettings(),
        );
      }
    });
  }

  testScreen('activating a distillation', (tester) async {
    await seed(tester, activate: false);
    await pumpScreen(
      tester,
      DistillScreen(groupId: japaneseId),
      overrides: screenOverrides(database, sampleNow),
    );
    expect(
      find.text('6 cards · last one arrives around November 15'),
      findsOne,
    );
    await captureShot(tester, find.byType(DistillScreen), 'distill_activate');
    await expectNoOverflow(tester);
  });

  testScreen('during the global pause, the waiting cards instead of an '
      'estimate', (tester) async {
    await seed(tester, activate: false);
    await tester.runAsync(
      () => SampleServices(
        database,
        FixedClock(sampleNow),
      ).distillations.pauseAll(),
    );
    await pumpScreen(
      tester,
      DistillScreen(groupId: japaneseId),
      overrides: screenOverrides(database, sampleNow),
    );
    expect(find.text('6 cards waiting · paused', findRichText: true), findsOne);
  });

  testScreen('distillation followed on the group page', (tester) async {
    await seed(tester);
    await pumpScreen(
      tester,
      GroupDetailScreen(groupId: japaneseId),
      overrides: screenOverrides(database, sampleNow),
    );
    expect(find.textContaining('cards waiting'), findsNothing);
    expect(find.textContaining('a day'), findsOneWidget);
    await captureShot(
      tester,
      find.byType(GroupDetailScreen),
      'group_distillation',
    );
    await expectNoOverflow(tester);
  });

  testScreen('new cards on the home timeline', (tester) async {
    await seed(tester);
    await pumpScreen(
      tester,
      const Scaffold(body: SafeArea(child: HomeScreen())),
      overrides: screenOverrides(database, sampleNow),
    );
    expect(find.text('Japanese: 1 new card'), findsNWidgets(6));
    await captureShot(tester, find.byType(HomeScreen), 'home_distillation');
    await expectNoOverflow(tester);
  });

  /// Lets the database work, as a tap on a button runs on it, then the screen
  /// follows.
  Future<void> settle(WidgetTester tester) async {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pumpAndSettle();
  }

  Future<CardGroup> japanese(WidgetTester tester) async => (await tester
      .runAsync(() => GroupRepository(database).find(japaneseId)))!;

  testScreen('the preset of the group shows its reminders', (tester) async {
    await seed(tester, activate: false);
    await pumpScreen(
      tester,
      DistillScreen(groupId: japaneseId),
      overrides: screenOverrides(database, sampleNow),
    );
    await tester.ensureVisible(find.text(l10n.presetEdit));
    expect(find.text('Standard'), findsOne);
    expect(find.text('Default'), findsNothing);
    for (final step in BuiltInPresets.standard.intervals) {
      expect(find.text(l10n.intervalLabel(step)), findsOne);
    }
    expect(find.text('On failure: one step back'), findsOne);
    await captureShot(tester, find.byType(DistillScreen), 'distill_preset');
    await expectNoOverflow(tester);
  });

  testScreen('"Edit" opens the editor of the preset', (tester) async {
    await seed(tester, activate: false);
    await pumpScreen(
      tester,
      DistillScreen(groupId: japaneseId),
      overrides: screenOverrides(database, sampleNow),
    );
    await tester.ensureVisible(find.text(l10n.presetEdit));
    await tester.tap(find.text(l10n.presetEdit));
    await tester.pumpAndSettle();
    expect(find.byType(PresetEditorScreen), findsOne);
  });

  testScreen('another preset is chosen from the screen', (tester) async {
    await seed(tester, activate: false);
    await pumpScreen(
      tester,
      DistillScreen(groupId: japaneseId),
      overrides: screenOverrides(database, sampleNow),
    );
    await tester.ensureVisible(find.text('Standard'));
    await tester.tap(find.text('Standard'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Intensive'));
    await settle(tester);
    final catalog = await tester.runAsync(
      () => PresetRepository(database).loadCatalog(),
    );
    expect((await japanese(tester)).presetId, isNot(catalog!.globalPresetId));
    expect(find.text('Intensive'), findsOne);
    expect(find.text('Default'), findsNothing);
    expect(
      find.text(l10n.intervalLabel(BuiltInPresets.intensive.intervals.first)),
      findsOne,
    );
  });

  testScreen('a new preset is created and followed by the group', (
    tester,
  ) async {
    await seed(tester, activate: false);
    await pumpScreen(
      tester,
      DistillScreen(groupId: japaneseId),
      overrides: screenOverrides(database, sampleNow),
    );
    await tester.ensureVisible(find.text('Standard'));
    await tester.tap(find.text('Standard'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.presetsNew));
    await tester.pumpAndSettle();
    expect(find.byType(PresetEditorScreen), findsOne);
    await tester.tap(find.text(l10n.commonSave));
    await settle(tester);
    expect(find.byType(PresetEditorScreen), findsNothing);
    final catalog = await tester.runAsync(
      () => PresetRepository(database).loadCatalog(),
    );
    expect(catalog!.presetForGroup(japaneseId).name, l10n.presetNewName);
    expect(catalog.groupPresetIds[japaneseId], isNot(catalog.globalPresetId));
    expect(find.text('Default'), findsNothing);
  });

  testScreen('activates the distillation from the screen', (tester) async {
    await seed(tester, activate: false);
    await pumpScreen(
      tester,
      DistillScreen(groupId: japaneseId),
      overrides: screenOverrides(database, sampleNow),
    );
    await tester.tap(find.byTooltip(l10n.distillMoreCards));
    await tester.pumpAndSettle();
    expect(
      find.text('6 cards · last one arrives around November 12'),
      findsOne,
    );
    await tester.tap(find.text(l10n.distillActivate));
    await tester.pumpAndSettle();
    final distillations = await tester.runAsync(
      () => DistillationRepository(database).getAll(),
    );
    expect(distillations!.single.groupId, japaneseId);
    expect(distillations.single.cardsPerBatch, 2);
    expect(find.byType(DistillScreen), findsNothing);
  });

  testScreen('"Adjust" opens the current settings and saves new ones', (
    tester,
  ) async {
    await seed(tester);
    await pumpScreen(
      tester,
      GroupDetailScreen(groupId: japaneseId),
      overrides: screenOverrides(database, sampleNow),
    );
    await tester.tap(find.byTooltip(l10n.distillAdjustTitle));
    await tester.pumpAndSettle();
    expect(find.text('Adjust the distillation'), findsOneWidget);
    expect(find.text('1'), findsOneWidget, reason: 'one card per batch');
    await tester.tap(find.byTooltip(l10n.distillMoreCards));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text(l10n.commonSave), 200);
    await tester.ensureVisible(find.text(l10n.commonSave));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.commonSave));
    // The save runs on the database, then the screen closes.
    for (
      var wait = 0;
      wait < 100 && find.byType(DistillScreen).evaluate().isNotEmpty;
      wait++
    ) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 10)),
      );
      await tester.pump();
    }
    await tester.pumpAndSettle();
    final distillation = await tester.runAsync(
      () => DistillationRepository(database).find(japaneseId),
    );
    expect(distillation!.cardsPerBatch, 2);
    expect(find.text('2 cards a day'), findsOne);
  });

  /// Pauses the distillation of Japanese, at 9am on the sample day.
  Future<void> pause(WidgetTester tester) => tester.runAsync(
    () => SampleServices(
      database,
      FixedClock(sampleNow),
    ).distillations.pause(japaneseId),
  );

  testScreen('paused distillation on the group page', (tester) async {
    await seed(tester);
    await pause(tester);
    await pumpScreen(
      tester,
      GroupDetailScreen(groupId: japaneseId),
      overrides: screenOverrides(database, sampleNow),
    );
    expect(find.text('Paused since Nov 10'), findsOne);
    await captureShot(
      tester,
      find.byType(GroupDetailScreen),
      'group_distillation_paused',
    );
    await expectNoOverflow(tester);
  });

  testScreen('a paused distillation resumes from its screen, at once', (
    tester,
  ) async {
    await seed(tester);
    await pause(tester);
    await pumpScreen(
      tester,
      DistillScreen(
        groupId: japaneseId,
        currentSettings: const DistillationSettings(),
      ),
      overrides: screenOverrides(database, sampleNow),
    );
    expect(
      find.text(
        'Paused since November 10: no new card comes out, reminders go on.',
      ),
      findsOne,
    );
    await captureShot(
      tester,
      find.byType(DistillScreen),
      'distill_adjust_paused',
    );
    await expectNoOverflow(tester);
    await tester.ensureVisible(find.text(l10n.pauseResume));
    await tester.tap(find.text(l10n.pauseResume));
    // The resume runs on the database, then the screen follows it.
    for (
      var wait = 0;
      wait < 100 && find.text('Pause').evaluate().isEmpty;
      wait++
    ) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 10)),
      );
      await tester.pump();
    }
    expect(find.text('Pause'), findsOne);
    expect(find.byType(DistillScreen), findsOne);
    final distillation = await tester.runAsync(
      () => DistillationRepository(database).find(japaneseId),
    );
    expect(distillation!.pausedAt, isNull);
  });
}
