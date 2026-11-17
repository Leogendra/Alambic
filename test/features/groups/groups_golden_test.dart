import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/data/database/alambic_database.dart';
import 'package:alambic/data/repositories/card_repository.dart';
import 'package:alambic/data/repositories/group_repository.dart';
import 'package:alambic/data/repositories/pause_repository.dart';
import 'package:alambic/domain/cards/card_state.dart';
import 'package:alambic/domain/groups/after_last_step.dart';
import 'package:alambic/domain/groups/card_group.dart';
import 'package:alambic/domain/groups/remanence_interval.dart';
import 'package:alambic/domain/reviews/review_outcome.dart';
import 'package:alambic/domain/reviews/review_source.dart';
import 'package:alambic/domain/scheduling/card_schedule.dart';
import 'package:alambic/features/cards/card_list_tile.dart';
import 'package:alambic/features/distillation/distill_screen.dart';
import 'package:alambic/features/groups/group_detail_screen.dart';
import 'package:alambic/features/groups/group_settings_screen.dart';
import 'package:alambic/features/groups/groups_screen.dart';
import 'package:alambic/features/session/session_screen.dart';

import '../../support/fixed_clock.dart';
import '../../support/golden_harness.dart';
import '../../support/sample_data.dart';
import '../../support/test_database.dart';

void main() {
  late AlambicDatabase database;
  late SampleServices samples;
  late int capitalsId;

  setUp(() async {
    database = openTestDatabase();
  });

  tearDown(() => database.close());

  Future<void> seed(WidgetTester tester) async {
    await tester.runAsync(() async {
      samples = SampleServices(database, FixedClock(sampleNow));
      capitalsId = await seedSampleData(samples);
    });
  }

  /// Adds to Capitales a card acquired at the end of its sequence.
  Future<void> seedAcquired(WidgetTester tester) => tester.runAsync(() async {
    final cardId = await samples.card('Chili', 'Santiago', groupId: capitalsId);
    await CardRepository(database).applySchedule(
      cardId,
      const CardSchedule(state: CardState.acquired, step: null, dueAt: null),
    );
  });

  /// Adds to Capitales a queue of two cards, the first one suspended, and
  /// suspends Myanmar, in progress.
  Future<void> seedWaiting(WidgetTester tester) => tester.runAsync(() async {
    final kenya = await samples.card('Kenya', 'Nairobi', groupId: capitalsId);
    await samples.card('Maroc', 'Rabat', groupId: capitalsId);
    await samples.cards.setSuspended(kenya, suspended: true);
    final myanmar = (await CardRepository(database).getCardsOfGroup(capitalsId))
        .firstWhere((card) => card.frontText == 'Myanmar');
    await samples.cards.setSuspended(myanmar.id, suspended: true);
  });

  testWidgets('groups tab', (tester) async {
    await seed(tester);
    await pumpGolden(
      tester,
      const Scaffold(body: SafeArea(child: GroupsScreen())),
      overrides: screenOverrides(database, sampleNow),
    );
    await expectLater(
      find.byType(GroupsScreen),
      matchesGoldenFile('goldens/groups_tab.png'),
    );
  });

  testWidgets('groups tab with a paused group', (tester) async {
    await seed(tester);
    await tester.runAsync(
      () => PauseRepository(database).setGroupPausedAt(capitalsId, sampleNow),
    );
    await pumpGolden(
      tester,
      const Scaffold(body: SafeArea(child: GroupsScreen())),
      overrides: screenOverrides(database, sampleNow),
    );
    await expectLater(
      find.byType(GroupsScreen),
      matchesGoldenFile('goldens/groups_tab_paused.png'),
    );
  });

  testWidgets('groups tab searching a card', (tester) async {
    await seed(tester);
    await pumpGolden(
      tester,
      const Scaffold(body: SafeArea(child: GroupsScreen())),
      overrides: screenOverrides(database, sampleNow),
    );
    await tester.enterText(find.byType(TextField), 'an');
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(GroupsScreen),
      matchesGoldenFile('goldens/groups_search.png'),
    );
  });

  for (final (brightness, suffix) in [
    (Brightness.light, ''),
    (Brightness.dark, '_dark'),
  ]) {
    testWidgets('group detail, ${brightness.name} theme', (tester) async {
      await seed(tester);
      await seedAcquired(tester);
      await seedWaiting(tester);
      await pumpGolden(
        tester,
        GroupDetailScreen(groupId: capitalsId),
        brightness: brightness,
        overrides: screenOverrides(database, sampleNow),
      );
      await expectLater(
        find.byType(GroupDetailScreen),
        matchesGoldenFile('goldens/group_detail$suffix.png'),
      );
    });
  }

  testWidgets('three sections with their counts; the head of the queue '
      'that is not suspended is "next"', (tester) async {
    await seed(tester);
    await seedAcquired(tester);
    await seedWaiting(tester);
    await pumpGolden(
      tester,
      GroupDetailScreen(groupId: capitalsId),
      overrides: screenOverrides(database, sampleNow),
    );
    final acquired = find.text('ACQUISES · 1');
    await tester.scrollUntilVisible(acquired, 200);
    expect(find.text('EN COURS · 4'), findsOneWidget);
    expect(find.text('EN ATTENTE · 2'), findsOneWidget);
    expect(find.text('prochaine'), findsOneWidget);
    final maroc = find.ancestor(
      of: find.text('Maroc'),
      matching: find.byType(CardListTile),
    );
    expect(
      find.descendant(of: maroc, matching: find.text('prochaine')),
      findsOneWidget,
    );
    expect(find.text('Dues'), findsNothing);
    expect(find.textContaining('Réviser les'), findsNothing);
  });

  testWidgets('the acquired cards are apart, folded until touched', (
    tester,
  ) async {
    await seed(tester);
    await seedAcquired(tester);
    await pumpGolden(
      tester,
      GroupDetailScreen(groupId: capitalsId),
      overrides: screenOverrides(database, sampleNow),
    );
    final title = find.text('ACQUISES · 1');
    await tester.scrollUntilVisible(title, 200);
    expect(find.text('Chili'), findsNothing);
    await tester.tap(title);
    await tester.pumpAndSettle();
    expect(find.text('Chili'), findsOneWidget);
    await tester.tap(title);
    await tester.pumpAndSettle();
    expect(find.text('Chili'), findsNothing);
  });

  for (final (brightness, suffix) in [
    (Brightness.light, ''),
    (Brightness.dark, '_dark'),
  ]) {
    testWidgets('group settings, ${brightness.name} theme', (tester) async {
      await seed(tester);
      await pumpGolden(
        tester,
        GroupSettingsScreen(groupId: capitalsId),
        brightness: brightness,
        overrides: screenOverrides(database, sampleNow),
      );
      expect(
        find.text(
          'La carte reste dans le cycle et revient toujours au bout de 6 mois.',
        ),
        findsOneWidget,
      );
      await expectLater(
        find.byType(GroupSettingsScreen),
        matchesGoldenFile('goldens/group_settings$suffix.png'),
      );
    });
  }

  testWidgets('the group settings set the end of sequence and the typed '
      'answer', (tester) async {
    await seed(tester);
    await pumpGolden(
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

    var group = await tapThenRead(find.text('1 an'));
    expect(group.remanenceInterval, RemanenceInterval.oneYear);
    expect(
      find.text(
        'La carte reste dans le cycle et revient toujours au bout de 1 an.',
      ),
      findsOneWidget,
    );
    group = await tapThenRead(find.byType(Switch).first);
    expect(group.typedAnswer, isTrue);
    group = await tapThenRead(find.text('Acquise'));
    expect(group.afterLastStep, AfterLastStep.acquired);
    expect(find.text('Revient tous les'), findsNothing);
    expect(
      find.text(
        'Une fois le dernier cran réussi, la carte est acquise : elle ne '
        'revient plus.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('"Enable the back" switches the option of the group', (
    tester,
  ) async {
    await seed(tester);
    await pumpGolden(
      tester,
      GroupDetailScreen(groupId: capitalsId),
      overrides: screenOverrides(database, sampleNow),
    );
    await tester.runAsync(() async {
      await tester.tap(find.text('Activer le verso'));
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();
    final group = await tester.runAsync(
      () => GroupRepository(database).find(capitalsId),
    );
    expect(group!.reverseEnabled, isTrue);
    expect(find.text('Désactiver le verso'), findsOneWidget);
  });

  testWidgets('"Distill" opens the activation of the distillation', (
    tester,
  ) async {
    await seed(tester);
    await pumpGolden(
      tester,
      GroupDetailScreen(groupId: capitalsId),
      overrides: screenOverrides(database, sampleNow),
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Distiller'));
    await tester.pumpAndSettle();
    expect(find.text('Activer la distillation'), findsOneWidget);
    expect(find.byType(DistillScreen), findsOneWidget);
  });

  testWidgets('"Review all" asks the due cards, then the others, then the '
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
        'Chili',
        'Santiago',
        groupId: capitalsId,
      );
      return [for (final card in cards) card.id, chile];
    }))!;
    await seedAcquired(tester);
    await pumpGolden(
      tester,
      GroupDetailScreen(groupId: capitalsId),
      overrides: screenOverrides(database, sampleNow),
    );
    await tester.ensureVisible(find.text('Tout réviser'));
    await tester.runAsync(() async {
      await tester.tap(find.text('Tout réviser'));
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
