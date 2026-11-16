import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/data/database/alambic_database.dart';
import 'package:alambic/data/repositories/group_repository.dart';
import 'package:alambic/data/repositories/pause_repository.dart';
import 'package:alambic/features/groups/group_detail_screen.dart';
import 'package:alambic/features/groups/group_settings_screen.dart';
import 'package:alambic/features/groups/groups_screen.dart';

import '../../support/fixed_clock.dart';
import '../../support/golden_harness.dart';
import '../../support/sample_data.dart';
import '../../support/test_database.dart';

void main() {
  late AlambicDatabase database;
  late int capitalsId;

  setUp(() async {
    database = openTestDatabase();
  });

  tearDown(() => database.close());

  Future<void> seed(WidgetTester tester) async {
    await tester.runAsync(() async {
      capitalsId = await seedSampleData(
        SampleServices(database, FixedClock(sampleNow)),
      );
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
}
