import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:alambic/data/database/alambic_database.dart';
import 'package:alambic/data/repositories/card_repository.dart';
import 'package:alambic/data/repositories/group_repository.dart';
import 'package:alambic/data/repositories/preset_repository.dart';
import 'package:alambic/domain/distillation/distillation_settings.dart';
import 'package:alambic/domain/groups/after_last_step.dart';
import 'package:alambic/domain/groups/card_group.dart';
import 'package:alambic/domain/groups/remanence_interval.dart';
import 'package:alambic/domain/reviews/review_outcome.dart';
import 'package:alambic/domain/reviews/review_source.dart';
import 'package:alambic/domain/scheduling/card_schedule.dart';
import 'package:alambic/features/cards/bulk_add_screen.dart';
import 'package:alambic/features/cards/card_editor_screen.dart';
import 'package:alambic/features/cards/card_list_tile.dart';
import 'package:alambic/features/distillation/distill_screen.dart';
import 'package:alambic/features/groups/group_detail_screen.dart';
import 'package:alambic/features/groups/group_settings_screen.dart';
import 'package:alambic/features/groups/groups_screen.dart';
import 'package:alambic/features/presets/preset_editor_screen.dart';
import 'package:alambic/features/session/session_screen.dart';

import '../../support/fixed_clock.dart';
import '../../support/screen_harness.dart';
import '../../support/sample_data.dart';
import '../../support/test_database.dart';
import '../../support/test_screen.dart';

void main() {
  late AlambicDatabase database;
  late SampleServices samples;
  late int capitalsId;

  setUp(() async {
    database = openTestDatabase();
  });

  tearDown(() => closeTestDatabase(database));

  Future<void> seed(WidgetTester tester) async {
    await tester.runAsync(() async {
      samples = SampleServices(database, FixedClock(sampleNow));
      capitalsId = await seedSampleData(samples);
    });
  }

  /// Adds to Capitals a card acquired at the end of its sequence.
  Future<void> seedAcquired(WidgetTester tester) => tester.runAsync(() async {
    final cardId = await samples.card('Chile', 'Santiago', groupId: capitalsId);
    await CardRepository(database).applySchedule(cardId, CardSchedule.acquired);
  });

  /// Adds to Capitals a queue of two cards, the first one suspended, and
  /// suspends Myanmar, in progress.
  Future<void> seedWaiting(WidgetTester tester) => tester.runAsync(() async {
    final kenya = await samples.card('Kenya', 'Nairobi', groupId: capitalsId);
    await samples.card('Morocco', 'Rabat', groupId: capitalsId);
    await samples.cards.setSuspended(kenya, suspended: true);
    final myanmar = (await CardRepository(database).getCardsOfGroup(capitalsId))
        .firstWhere((card) => card.frontText == 'Myanmar');
    await samples.cards.setSuspended(myanmar.id, suspended: true);
  });

  /// Makes Capitals distill; its first batch comes out at once, so it goes
  /// before the cards that must wait.
  Future<void> activate(WidgetTester tester) => tester.runAsync(
    () => samples.distillations.activate(
      capitalsId,
      const DistillationSettings(),
    ),
  );

  testScreen('groups tab, "distillation" on a distilled group', (tester) async {
    await seed(tester);
    await activate(tester);
    await pumpScreen(
      tester,
      const Scaffold(body: SafeArea(child: GroupsScreen())),
      overrides: screenOverrides(database, sampleNow),
    );
    expect(find.text('4 cards · distillation'), findsOneWidget);
    expect(find.text('2 cards'), findsOneWidget);
    await captureShot(tester, find.byType(GroupsScreen), 'groups_tab');
    await expectNoOverflow(tester);
  });

  testScreen('groups tab with a paused distillation', (tester) async {
    await seed(tester);
    await tester.runAsync(() async {
      await samples.distillations.activate(
        capitalsId,
        const DistillationSettings(),
      );
      await samples.distillations.pause(capitalsId);
    });
    await pumpScreen(
      tester,
      const Scaffold(body: SafeArea(child: GroupsScreen())),
      overrides: screenOverrides(database, sampleNow),
    );
    expect(find.text('4 cards · Paused'), findsOneWidget);
    await captureShot(tester, find.byType(GroupsScreen), 'groups_tab_paused');
    await expectNoOverflow(tester);
  });

  testScreen('groups tab searching a card', (tester) async {
    await seed(tester);
    await pumpScreen(
      tester,
      const Scaffold(body: SafeArea(child: GroupsScreen())),
      overrides: screenOverrides(database, sampleNow),
    );
    await tester.enterText(find.byType(TextField), 'an');
    await tester.pumpAndSettle();
    for (final country in ['Mongolia', 'Laos', 'Myanmar']) {
      expect(find.text(country), findsOneWidget);
    }
    expect(find.text('Peru'), findsNothing);
    await captureShot(tester, find.byType(GroupsScreen), 'groups_search');
    await expectNoOverflow(tester);
  });

  for (final (brightness, suffix) in [
    (Brightness.light, ''),
    (Brightness.dark, '_dark'),
  ]) {
    testScreen('group detail, ${brightness.name} theme', (tester) async {
      await seed(tester);
      await activate(tester);
      await seedAcquired(tester);
      await seedWaiting(tester);
      await pumpScreen(
        tester,
        GroupDetailScreen(groupId: capitalsId),
        brightness: brightness,
        overrides: screenOverrides(database, sampleNow),
      );
      expect(find.text('Capitals'), findsOneWidget);
      expect(find.text('In progress · 4'), findsOneWidget);
      await captureShot(
        tester,
        find.byType(GroupDetailScreen),
        'group_detail$suffix',
      );
      await expectNoOverflow(tester);
    });
  }

  testScreen('without distillation, the waiting cards say nothing of where '
      'they stand', (tester) async {
    await seed(tester);
    await seedWaiting(tester);
    await pumpScreen(
      tester,
      GroupDetailScreen(groupId: capitalsId),
      overrides: screenOverrides(database, sampleNow),
    );
    expect(find.text('Waiting · 2'), findsOneWidget);
    expect(find.text('waiting'), findsNothing);
    expect(find.text('next'), findsNothing);
    expect(find.text('suspended'), findsNWidgets(2));
  });

  testScreen('"Review all" sits beside the first section title', (
    tester,
  ) async {
    await seed(tester);
    await pumpScreen(
      tester,
      GroupDetailScreen(groupId: capitalsId),
      overrides: screenOverrides(database, sampleNow),
    );
    final title = tester.getRect(find.textContaining('In progress'));
    final button = tester.getRect(
      find.ancestor(
        of: find.text('Review all'),
        matching: find.byType(OutlinedButton),
      ),
    );
    expect(title.bottom, closeTo(button.bottom, 1));
    expect(find.text('Cards'), findsNothing);
  });

  testScreen('the "+" button opens two separate floating buttons above it, '
      'and a close button in its place', (tester) async {
    await seed(tester);
    await pumpScreen(
      tester,
      GroupDetailScreen(groupId: capitalsId),
      overrides: screenOverrides(database, sampleNow),
    );
    expect(find.byIcon(Icons.playlist_add), findsNothing);
    final plus = tester.getRect(find.byTooltip(l10n.addCardsTooltip));
    await tester.tap(find.byTooltip(l10n.addCardsTooltip));
    await tester.pumpAndSettle();
    await captureShot(tester, find.byType(Overlay).first, 'add_cards_buttons');
    final card = tester.getRect(find.text(l10n.addCardsOne));
    final bulk = tester.getRect(find.text(l10n.addCardsBulk));
    expect(bulk.bottom, lessThan(card.top));
    expect(card.bottom, lessThan(plus.top));
    expect(tester.getRect(find.byTooltip(l10n.commonClose)), plus);
    await tester.tap(find.byTooltip(l10n.commonClose));
    await tester.pumpAndSettle();
    expect(find.text(l10n.addCardsOne), findsNothing);
  });

  testScreen('touching beside the floating buttons closes them', (
    tester,
  ) async {
    await seed(tester);
    await pumpScreen(
      tester,
      GroupDetailScreen(groupId: capitalsId),
      overrides: screenOverrides(database, sampleNow),
    );
    await tester.tap(find.byTooltip(l10n.addCardsTooltip));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(20, 100));
    await tester.pumpAndSettle();
    expect(find.text(l10n.addCardsOne), findsNothing);
    expect(find.byType(CardEditorScreen), findsNothing);
  });

  testScreen('"Add a card" opens the card editor on the group', (tester) async {
    await seed(tester);
    await pumpScreen(
      tester,
      GroupDetailScreen(groupId: capitalsId),
      overrides: screenOverrides(database, sampleNow),
    );
    await tester.tap(find.byTooltip(l10n.addCardsTooltip));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.addCardsOne));
    await tester.pumpAndSettle();
    final editor = tester.widget<CardEditorScreen>(
      find.byType(CardEditorScreen),
    );
    expect(editor.initialGroupId, capitalsId);
  });

  testScreen('"Add several cards" opens the bulk add on the group', (
    tester,
  ) async {
    await seed(tester);
    await pumpScreen(
      tester,
      GroupDetailScreen(groupId: capitalsId),
      overrides: screenOverrides(database, sampleNow),
    );
    await tester.tap(find.byTooltip(l10n.addCardsTooltip));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.addCardsBulk));
    await tester.pumpAndSettle();
    final bulk = tester.widget<BulkAddScreen>(find.byType(BulkAddScreen));
    expect(bulk.initialGroupId, capitalsId);
  });

  testScreen('three sections with their counts; the head of the queue '
      'that is not suspended is "next"', (tester) async {
    await seed(tester);
    await activate(tester);
    await seedAcquired(tester);
    await seedWaiting(tester);
    await pumpScreen(
      tester,
      GroupDetailScreen(groupId: capitalsId),
      overrides: screenOverrides(database, sampleNow),
    );
    final acquired = find.text('Learned · 1');
    await tester.scrollUntilVisible(acquired, 200);
    expect(find.text('In progress · 4'), findsOneWidget);
    expect(find.text('Waiting · 2'), findsOneWidget);
    expect(find.text('next'), findsOneWidget);
    expect(find.text('waiting'), findsNothing);
    final morocco = find.ancestor(
      of: find.text('Morocco'),
      matching: find.byType(CardListTile),
    );
    expect(
      find.descendant(of: morocco, matching: find.text('next')),
      findsOneWidget,
    );
    expect(find.text('Active'), findsNothing);
    expect(find.textContaining('Review the'), findsNothing);
  });

  testScreen('the acquired cards are apart, folded until touched', (
    tester,
  ) async {
    await seed(tester);
    await seedAcquired(tester);
    await pumpScreen(
      tester,
      GroupDetailScreen(groupId: capitalsId),
      overrides: screenOverrides(database, sampleNow),
    );
    final title = find.text('Learned · 1');
    await tester.scrollUntilVisible(title, 200);
    expect(find.text('Chile'), findsNothing);
    await tester.tap(title);
    await tester.pumpAndSettle();
    expect(find.text('Chile'), findsOneWidget);
    await tester.tap(title);
    await tester.pumpAndSettle();
    expect(find.text('Chile'), findsNothing);
  });

  for (final (brightness, suffix) in [
    (Brightness.light, ''),
    (Brightness.dark, '_dark'),
  ]) {
    testScreen('group settings, ${brightness.name} theme', (tester) async {
      await seed(tester);
      await pumpScreen(
        tester,
        GroupSettingsScreen(groupId: capitalsId),
        brightness: brightness,
        overrides: screenOverrides(database, sampleNow),
      );
      expect(
        find.text(
          'The card stays in the cycle and always comes back after 6\u00A0mo.',
        ),
        findsOneWidget,
      );
      await captureShot(
        tester,
        find.byType(GroupSettingsScreen),
        'group_settings$suffix',
      );
      await expectNoOverflow(tester);
    });
  }

  testScreen('the group settings set the end of sequence and the typed '
      'answer', (tester) async {
    await seed(tester);
    await pumpScreen(
      tester,
      GroupSettingsScreen(groupId: capitalsId),
      overrides: screenOverrides(database, sampleNow),
    );
    Future<CardGroup> tapThenRead(Finder finder) async {
      await tester.runAsync(() async {
        await tester.tap(finder);
        await Future<void>.delayed(const Duration(milliseconds: 100));
      });
      await tester.pumpAndSettle();
      return (await tester.runAsync(
        () => GroupRepository(database).find(capitalsId),
      ))!;
    }

    var group = await tapThenRead(find.text(l10n.intervalYears(1)));
    expect(group.remanenceInterval, RemanenceInterval.oneYear);
    expect(
      find.text(
        'The card stays in the cycle and always comes back after 1\u00A0yr.',
      ),
      findsOneWidget,
    );
    group = await tapThenRead(find.byType(Switch).first);
    expect(group.typedAnswer, isTrue);
    group = await tapThenRead(find.text(l10n.groupAcquired));
    expect(group.afterLastStep, AfterLastStep.acquired);
    expect(find.text('Comes back every'), findsNothing);
    expect(
      find.text(
        'Once the last step is passed, the card is learned: it never comes '
        'back.',
      ),
      findsOneWidget,
    );
  });

  testScreen('"New preset" of the picker is followed by the group once saved', (
    tester,
  ) async {
    await seed(tester);
    await pumpScreen(
      tester,
      GroupSettingsScreen(groupId: capitalsId),
      overrides: screenOverrides(database, sampleNow),
    );
    await tester.tap(find.text(l10n.cardPreset));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.presetsNew));
    await tester.pumpAndSettle();
    expect(find.byType(PresetEditorScreen), findsOne);
    await tester.tap(find.text(l10n.commonSave));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pumpAndSettle();
    final catalog = await tester.runAsync(
      () => PresetRepository(database).loadCatalog(),
    );
    expect(catalog!.presetForGroup(capitalsId).name, l10n.presetNewName);
    expect(find.text(l10n.presetNewName), findsOne);
  });

  testScreen('"Hide the back" hides the backs of the list and "Show" brings '
      'them back', (tester) async {
    await seed(tester);
    await pumpScreen(
      tester,
      GroupDetailScreen(groupId: capitalsId),
      overrides: screenOverrides(database, sampleNow),
    );
    expect(find.text('Lima'), findsOneWidget);
    await tester.runAsync(() async {
      await tester.tap(find.text(l10n.groupBackHide));
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();
    final group = await tester.runAsync(
      () => GroupRepository(database).find(capitalsId),
    );
    expect(group!.backHidden, isTrue);
    expect(group.reverseEnabled, isFalse);
    expect(find.text('Peru'), findsOneWidget);
    expect(find.text('Lima'), findsNothing);
    expect(find.text('Show the back'), findsOneWidget);
    await tester.runAsync(() async {
      await tester.tap(find.text(l10n.groupBackShow));
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();
    expect(find.text('Lima'), findsOneWidget);
  });

  testScreen('"Distill" opens the activation of the distillation', (
    tester,
  ) async {
    await seed(tester);
    await pumpScreen(
      tester,
      GroupDetailScreen(groupId: capitalsId),
      overrides: screenOverrides(database, sampleNow),
    );
    await tester.tap(find.widgetWithText(FilledButton, l10n.distillTitle));
    await tester.pumpAndSettle();
    expect(find.text('Start distilling'), findsOneWidget);
    expect(find.byType(DistillScreen), findsOneWidget);
  });

  testScreen('"Review all" asks the due cards, then the others, then the '
      'queue, without the acquired ones', (tester) async {
    await seed(tester);
    final ids = (await tester.runAsync(() async {
      final cards = await CardRepository(database).getCardsOfGroup(capitalsId);
      await samples.reviews.answer(
        cards.first.id,
        ReviewOutcome.correct,
        source: ReviewSource.session,
      );
      final chile = await samples.card(
        'Chile',
        'Santiago',
        groupId: capitalsId,
      );
      return [for (final card in cards) card.id, chile];
    }))!;
    await seedAcquired(tester);
    await pumpScreen(
      tester,
      GroupDetailScreen(groupId: capitalsId),
      overrides: screenOverrides(database, sampleNow),
    );
    await tester.ensureVisible(find.text(l10n.groupReviewAll));
    await tester.runAsync(() async {
      await tester.tap(find.text(l10n.groupReviewAll));
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pumpAndSettle();
    final session = tester.widget<SessionScreen>(find.byType(SessionScreen));
    expect(session.isBonus, isFalse);
    expect(session.raisesMissedPending, isTrue);
    expect(session.items.map((item) => item.cardId), [
      ids[1],
      ids[2],
      ids[3],
      ids[0],
      ids[4],
    ]);
  });
}
