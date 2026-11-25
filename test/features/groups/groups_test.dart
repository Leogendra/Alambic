import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:alambic/data/database/alambic_database.dart';
import 'package:alambic/data/repositories/card_repository.dart';
import 'package:alambic/data/repositories/group_repository.dart';
import 'package:alambic/application/randomness.dart';
import 'package:alambic/domain/distillation/distillation_queue.dart';
import 'package:alambic/domain/distillation/distillation_settings.dart';
import 'package:alambic/domain/reviews/review_outcome.dart';
import 'package:alambic/domain/reviews/review_source.dart';
import 'package:alambic/domain/scheduling/card_schedule.dart';
import 'package:alambic/features/cards/add_cards_button.dart';
import 'package:alambic/features/cards/bulk_add_screen.dart';
import 'package:alambic/features/cards/card_editor_screen.dart';
import 'package:alambic/features/cards/card_list_tile.dart';
import 'package:alambic/features/cards/card_sheet_screen.dart';
import 'package:alambic/features/distillation/distill_screen.dart';
import 'package:alambic/features/groups/group_detail_screen.dart';
import 'package:alambic/features/groups/group_settings_screen.dart';
import 'package:alambic/features/groups/groups_screen.dart';
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

  /// Adds to Capitals a queue of two cards, Kenya then Morocco.
  Future<void> seedWaiting(WidgetTester tester) => tester.runAsync(() async {
    await samples.card('Kenya', 'Nairobi', groupId: capitalsId);
    await samples.card('Morocco', 'Rabat', groupId: capitalsId);
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

  testScreen('three sections with their counts; the head of the queue is '
      '"next"', (tester) async {
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
    final kenya = find.ancestor(
      of: find.text('Kenya'),
      matching: find.byType(CardListTile),
    );
    expect(
      find.descendant(of: kenya, matching: find.text('next')),
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
      expect(find.text(l10n.cardPreset), findsNothing);
      expect(find.text(l10n.groupAfterLastStep), findsNothing);
      await captureShot(
        tester,
        find.byType(GroupSettingsScreen),
        'group_settings$suffix',
      );
      await expectNoOverflow(tester);
    });
  }

  testScreen('the group settings set the typed answer', (tester) async {
    await seed(tester);
    await pumpScreen(
      tester,
      GroupSettingsScreen(groupId: capitalsId),
      overrides: screenOverrides(database, sampleNow),
    );
    await tester.runAsync(() async {
      await tester.tap(find.byType(Switch).first);
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();
    final group = await tester.runAsync(
      () => GroupRepository(database).find(capitalsId),
    );
    expect(group!.typedAnswer, isTrue);
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
    expect(find.byType(DistillScreen), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Start distilling'), 200);
    expect(find.text('Start distilling'), findsOneWidget);
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

  group('the queue', () {
    /// Capitals, distilling, then a queue of Kenya, Morocco, Nepal and Oman.
    Future<List<String>> seedQueue(WidgetTester tester) async {
      await seed(tester);
      await activate(tester);
      const queue = ['Kenya', 'Morocco', 'Nepal', 'Oman'];
      await tester.runAsync(() async {
        for (final country in queue) {
          await samples.card(country, 'capital', groupId: capitalsId);
        }
      });
      return queue;
    }

    Future<void> pumpGroup(WidgetTester tester, {Brightness? brightness}) =>
        pumpScreen(
          tester,
          GroupDetailScreen(groupId: capitalsId),
          brightness: brightness ?? Brightness.light,
          overrides: [
            ...screenOverrides(database, sampleNow),
            randomProvider.overrideWithValue(Random(7)),
          ],
        );

    /// The fronts of the queue of Capitals, in the order stored.
    Future<List<String?>> storedQueue(WidgetTester tester) async =>
        (await tester.runAsync(() async {
          final cards = await CardRepository(database)
              .getCardsOfGroup(capitalsId);
          return [
            for (final card in DistillationQueue.inOrder(cards)) card.frontText,
          ];
        }))!;

    /// Lets the database write what was asked, then settles.
    Future<void> settleWrites(WidgetTester tester) async {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pumpAndSettle();
    }

    Finder rowOf(String front) =>
        find.ancestor(of: find.text(front), matching: find.byType(Row)).first;

    Future<void> tapIn(
      WidgetTester tester,
      String front,
      String tooltip,
    ) async {
      await tester.tap(
        find.descendant(of: rowOf(front), matching: find.byTooltip(tooltip)),
      );
      await tester.pump();
      await settleWrites(tester);
    }

    Future<void> reorder(WidgetTester tester) async {
      await tester.ensureVisible(find.byTooltip(l10n.groupReorder));
      await tester.tap(find.byTooltip(l10n.groupReorder));
      await tester.pumpAndSettle();
    }

    testScreen('a long press drags a card to another place, and "next" '
        'follows', (tester) async {
      await seedQueue(tester);
      await pumpGroup(tester);
      final nepal = find.text('Nepal');
      await tester.ensureVisible(nepal);
      await tester.pumpAndSettle();
      final distance =
          tester.getCenter(nepal).dy - tester.getCenter(find.text('Kenya')).dy;
      final gesture = await tester.startGesture(tester.getCenter(nepal));
      await tester.pump(const Duration(seconds: 1));
      for (var step = 0; step < 10; step++) {
        await gesture.moveBy(Offset(0, -(distance + 20) / 10));
        await tester.pump(const Duration(milliseconds: 50));
      }
      await gesture.up();
      await tester.pumpAndSettle();
      await settleWrites(tester);
      expect(await storedQueue(tester), ['Nepal', 'Kenya', 'Morocco', 'Oman']);
      expect(
        find.descendant(
          of: find.ancestor(of: nepal, matching: find.byType(CardListTile)),
          matching: find.text('next'),
        ),
        findsOneWidget,
      );
      expect(find.text('next'), findsOneWidget);
    });

    testScreen('a tap still opens the card sheet', (tester) async {
      await seedQueue(tester);
      await pumpGroup(tester);
      await tester.ensureVisible(find.text('Morocco'));
      await tester.tap(find.text('Morocco'));
      await tester.pumpAndSettle();
      expect(find.byType(CardSheetScreen), findsOneWidget);
    });

    for (final (brightness, suffix) in [
      (Brightness.light, ''),
      (Brightness.dark, '_dark'),
    ]) {
      testScreen('"Reorder" shows compact rows that move to the head or the '
          'end, ${brightness.name} theme', (tester) async {
        await seedQueue(tester);
        await pumpGroup(tester, brightness: brightness);
        await reorder(tester);
        expect(find.text(l10n.groupReorderDone), findsOneWidget);
        expect(find.byTooltip(l10n.groupReorder), findsNothing);
        expect(find.byIcon(Icons.drag_handle), findsNWidgets(4));
        // The "+" button is gone, so it cannot cover the last rows.
        expect(find.byType(AddCardsButton), findsNothing);
        await tester.ensureVisible(find.text('Oman'));
        await tester.pumpAndSettle();
        await captureShot(
          tester,
          find.byType(GroupDetailScreen),
          'group_reorder$suffix',
        );
        await expectNoOverflow(tester);
        await tapIn(tester, 'Kenya', l10n.cardSheetToEnd);
        expect(await storedQueue(tester), [
          'Morocco',
          'Nepal',
          'Oman',
          'Kenya',
        ]);
        await tapIn(tester, 'Oman', l10n.cardSheetToHead);
        expect(await storedQueue(tester), [
          'Oman',
          'Morocco',
          'Nepal',
          'Kenya',
        ]);
        // In reordering, a tap does not open the card.
        await tester.tap(find.text('Nepal'));
        await tester.pumpAndSettle();
        expect(find.byType(CardSheetScreen), findsNothing);
        await tester.tap(find.text(l10n.groupReorderDone));
        await tester.pumpAndSettle();
        expect(find.byIcon(Icons.drag_handle), findsNothing);
        expect(find.byType(AddCardsButton), findsOneWidget);
        expect(find.text('next'), findsOneWidget);
        expect(
          find.descendant(
            of: find.ancestor(
              of: find.text('Oman'),
              matching: find.byType(CardListTile),
            ),
            matching: find.text('next'),
          ),
          findsOneWidget,
        );
      });
    }

    testScreen('"Shuffle the queue" draws a new order once confirmed', (
      tester,
    ) async {
      final queue = await seedQueue(tester);
      await pumpGroup(tester);
      await reorder(tester);
      await tester.tap(find.byTooltip(l10n.groupShuffleQueue));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.commonCancel));
      await tester.pumpAndSettle();
      expect(await storedQueue(tester), queue);
      await tester.tap(find.byTooltip(l10n.groupShuffleQueue));
      await tester.pumpAndSettle();
      expect(find.text(l10n.groupShuffleConfirmTitle), findsOneWidget);
      await tester.tap(find.text(l10n.groupShuffleConfirm));
      await tester.pump();
      await settleWrites(tester);
      final shuffled = [...queue]..shuffle(Random(7));
      expect(shuffled, isNot(queue));
      expect(await storedQueue(tester), shuffled);
    });

    testScreen('a group without card in progress has "Review all" and '
        '"Reorder" side by side on the queue title', (tester) async {
      late int riversId;
      await tester.runAsync(() async {
        samples = SampleServices(database, FixedClock(sampleNow));
        riversId = await samples.groups.create('Rivers');
        for (final river in ['Nile', 'Amazon']) {
          await samples.card(river, 'river', groupId: riversId);
        }
      });
      await pumpScreen(
        tester,
        GroupDetailScreen(groupId: riversId),
        overrides: screenOverrides(database, sampleNow),
      );
      final title = tester.getRect(find.text('Waiting · 2'));
      final reviewAll = tester.getRect(
        find.ancestor(
          of: find.text(l10n.groupReviewAll),
          matching: find.byType(OutlinedButton),
        ),
      );
      final reorderButton = tester.getRect(find.byTooltip(l10n.groupReorder));
      expect(title.right, lessThanOrEqualTo(reviewAll.left));
      expect(reviewAll.right, lessThanOrEqualTo(reorderButton.left));
      await expectNoOverflow(tester);
    });

    testScreen('a queue of one card offers no reordering', (tester) async {
      await tester.runAsync(() async {
        samples = SampleServices(database, FixedClock(sampleNow));
        final riversId = await samples.groups.create('Rivers');
        await samples.card('Nile', 'river', groupId: riversId);
        capitalsId = riversId;
      });
      await pumpGroup(tester);
      expect(find.text('Waiting · 1'), findsOneWidget);
      expect(find.byTooltip(l10n.groupReorder), findsNothing);
    });
  });
}
