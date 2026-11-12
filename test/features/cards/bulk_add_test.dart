import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/data/database/alambic_database.dart';
import 'package:alambic/data/repositories/card_repository.dart';
import 'package:alambic/domain/cards/direction_sense.dart';
import 'package:alambic/domain/cards/direction_state.dart';
import 'package:alambic/features/cards/bulk_add_screen.dart';

import '../../support/fixed_clock.dart';
import '../../support/golden_harness.dart';
import '../../support/sample_data.dart';
import '../../support/test_database.dart';

const String pastedLines =
    'Capitale du Chili ; Santiago\n'
    'Capitale du Kenya ; Nairobi\n'
    'Capitale du Maroc Rabat\n'
    'Capitale du Vietnam ; Hanoï';

void main() {
  late AlambicDatabase database;
  late int groupId;

  setUp(() => database = openTestDatabase());
  tearDown(() => database.close());

  Future<void> pumpBulkAdd(WidgetTester tester) async {
    await tester.runAsync(() async {
      groupId = await SampleServices(
        database,
        FixedClock(sampleNow),
      ).groups.create('Capitales');
    });
    await pumpGolden(
      tester,
      BulkAddScreen(groupId: groupId),
      overrides: screenOverrides(database, sampleNow),
    );
    await tester.enterText(find.byType(TextField).last, pastedLines);
    await tester.pumpAndSettle();
  }

  testWidgets('reports ignored lines before adding', (tester) async {
    await pumpBulkAdd(tester);
    expect(find.text('3 cartes prêtes'.toUpperCase()), findsOneWidget);
    expect(find.text('Ligne 3 ignorée : pas de « ; »'), findsOneWidget);
    await expectLater(
      find.byType(BulkAddScreen),
      matchesGoldenFile('goldens/bulk_add.png'),
    );
  });

  testWidgets('a custom separator rereads every line', (tester) async {
    await pumpBulkAdd(tester);
    await tester.enterText(find.byType(TextField).first, ',');
    await tester.pumpAndSettle();
    expect(find.text('Aucune carte prête'.toUpperCase()), findsOneWidget);
  });

  testWidgets('adds the valid lines to the group, both ways', (tester) async {
    await pumpBulkAdd(tester);
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Ajouter 3 cartes'));
    await tester.tap(find.text('Ajouter 3 cartes'));
    await tester.pumpAndSettle();
    final cards = await tester.runAsync(
      () => CardRepository(database).watchCardsOfGroup(groupId).first,
    );
    expect(cards!.map((card) => card.card.backText), [
      'Santiago',
      'Nairobi',
      'Hanoï',
    ]);
    expect(
      cards.first.direction(DirectionSense.backToFront)!.state,
      DirectionState.unstarted,
    );
  });
}
