import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/data/database/alambic_database.dart';
import 'package:alambic/data/repositories/card_repository.dart';
import 'package:alambic/data/repositories/group_repository.dart';
import 'package:alambic/features/cards/card_editor_screen.dart';

import '../../support/golden_harness.dart';
import '../../support/sample_data.dart';
import '../../support/test_database.dart';

void main() {
  late AlambicDatabase database;

  setUp(() => database = openTestDatabase());
  tearDown(() => database.close());

  Future<void> pumpEditor(WidgetTester tester) async {
    await pumpGolden(
      tester,
      const CardEditorScreen(),
      overrides: screenOverrides(database, sampleNow),
    );
    await tester.enterText(find.byType(TextField).first, 'Mongolie');
    await tester.enterText(find.byType(TextField).last, 'Oulan-Bator');
  }

  Future<void> nameGroup(WidgetTester tester, String name) async {
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, name);
    await tester.runAsync(() async {
      await tester.tap(find.text('OK'));
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pumpAndSettle();
  }

  Future<void> create(WidgetTester tester) async {
    await tester.runAsync(() async {
      await tester.tap(find.text('Créer'));
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pumpAndSettle();
  }

  testWidgets('a card without group is not created', (tester) async {
    await pumpEditor(tester);
    await create(tester);
    expect(find.text('Choisis un groupe pour cette carte.'), findsOneWidget);
    final cards = await tester.runAsync(
      () => CardRepository(database).getAll(),
    );
    expect(cards, isEmpty);
  });

  testWidgets('"+" creates a group and puts the card in it', (tester) async {
    await pumpEditor(tester);
    await tester.tap(find.byTooltip('Nouveau groupe'));
    await nameGroup(tester, 'Capitales');
    expect(find.text('Capitales'), findsOneWidget);
    await create(tester);
    final groups = await tester.runAsync(
      () => GroupRepository(database).watchAll().first,
    );
    final card = (await tester.runAsync(
      () => CardRepository(database).getAll(),
    ))!.single;
    expect(groups!.single.name, 'Capitales');
    expect(card.groupId, groups.single.id);
  });

  testWidgets('with no group yet, the group row asks for a name', (
    tester,
  ) async {
    await pumpEditor(tester);
    await tester.tap(find.text('Choisir'));
    await nameGroup(tester, 'Espagnol');
    expect(find.text('Espagnol'), findsOneWidget);
  });
}
