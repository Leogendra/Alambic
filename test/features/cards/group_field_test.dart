import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:alambic/data/database/alambic_database.dart';
import 'package:alambic/data/repositories/card_repository.dart';
import 'package:alambic/data/repositories/group_repository.dart';
import 'package:alambic/features/cards/card_editor_screen.dart';

import '../../support/golden_harness.dart';
import '../../support/sample_data.dart';
import '../../support/test_database.dart';
import '../../support/test_screen.dart';

void main() {
  late AlambicDatabase database;

  setUp(() => database = openTestDatabase());
  tearDown(() => closeTestDatabase(database));

  Future<void> pumpEditor(WidgetTester tester) async {
    await pumpGolden(
      tester,
      const CardEditorScreen(),
      overrides: screenOverrides(database, sampleNow),
    );
    await tester.enterText(find.byType(TextField).first, 'Mongolia');
    await tester.enterText(find.byType(TextField).last, 'Ulaanbaatar');
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
      await tester.tap(find.text(l10n.cardEditorCreate));
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pumpAndSettle();
  }

  testScreen('a card without group is not created', (tester) async {
    await pumpEditor(tester);
    await create(tester);
    expect(find.text('Choose a group for this card.'), findsOneWidget);
    final cards = await tester.runAsync(
      () => CardRepository(database).getAll(),
    );
    expect(cards, isEmpty);
  });

  testScreen('"+" creates a group and puts the card in it', (tester) async {
    await pumpEditor(tester);
    await tester.tap(find.byTooltip(l10n.newGroupTitle));
    await nameGroup(tester, 'Capitals');
    expect(find.text('Capitals'), findsOneWidget);
    await create(tester);
    final groups = await tester.runAsync(
      () => GroupRepository(database).watchAll().first,
    );
    final card = (await tester.runAsync(
      () => CardRepository(database).getAll(),
    ))!.single;
    expect(groups!.single.name, 'Capitals');
    expect(card.groupId, groups.single.id);
  });

  testScreen('with no group yet, the group row asks for a name', (
    tester,
  ) async {
    await pumpEditor(tester);
    await tester.tap(find.text(l10n.cardGroupNone));
    await nameGroup(tester, 'Spanish');
    expect(find.text('Spanish'), findsOneWidget);
  });
}
