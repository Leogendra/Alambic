import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/data/database/alambic_database.dart';
import 'package:alambic/data/repositories/card_repository.dart';
import 'package:alambic/data/repositories/group_repository.dart';
import 'package:alambic/data/repositories/pause_repository.dart';
import 'package:alambic/domain/reviews/review_outcome.dart';
import 'package:alambic/domain/reviews/review_source.dart';
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

  testWidgets('group detail', (tester) async {
    await seed(tester);
    await pumpGolden(
      tester,
      GroupDetailScreen(groupId: capitalsId),
      overrides: screenOverrides(database, sampleNow),
    );
    await expectLater(
      find.byType(GroupDetailScreen),
      matchesGoldenFile('goldens/group_detail.png'),
    );
  });

  testWidgets('group settings', (tester) async {
    await seed(tester);
    await pumpGolden(
      tester,
      GroupSettingsScreen(groupId: capitalsId),
      overrides: screenOverrides(database, sampleNow),
    );
    await expectLater(
      find.byType(GroupSettingsScreen),
      matchesGoldenFile('goldens/group_settings.png'),
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
      'queue', (tester) async {
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
    expect(session.items.map((item) => item.cardId), [
      ids[1],
      ids[2],
      ids[3],
      ids[0],
      ids[4],
    ]);
  });
}
