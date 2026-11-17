import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/application/randomness.dart';
import 'package:alambic/data/database/alambic_database.dart';
import 'package:alambic/data/repositories/card_repository.dart';
import 'package:alambic/domain/cards/flashcard.dart';
import 'package:alambic/domain/cards/bulk/bulk_order.dart';
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

  /// The bulk add of a group that already has [waiting] cards in its queue;
  /// [seed] drives the shuffle draws.
  Future<void> pumpBulkAdd(
    WidgetTester tester, {
    int waiting = 0,
    int seed = 0,
  }) async {
    await tester.runAsync(() async {
      final services = SampleServices(database, FixedClock(sampleNow));
      groupId = await services.groups.create('Capitales');
      for (var index = 0; index < waiting; index++) {
        await services.card('Capitale du Pérou', 'Lima', groupId: groupId);
      }
    });
    await pumpGolden(
      tester,
      BulkAddScreen(initialGroupId: groupId),
      overrides: [
        ...screenOverrides(database, sampleNow),
        randomProvider.overrideWithValue(Random(seed)),
      ],
    );
    await tester.enterText(find.byType(TextField).last, pastedLines);
    await tester.pumpAndSettle();
  }

  Future<List<String?>> storedBacks(WidgetTester tester) async {
    final cards = await tester.runAsync(
      () => CardRepository(database).getCardsOfGroup(groupId),
    );
    return [
      for (final card in cards!..sort(byQueue))
        if (card.backText != 'Lima') card.backText,
    ];
  }

  testWidgets('reports ignored lines and the first card before adding', (
    tester,
  ) async {
    await pumpBulkAdd(tester, waiting: 2);
    expect(find.text('3 cartes prêtes'.toUpperCase()), findsOneWidget);
    expect(find.text('Ligne 3 ignorée : pas de « ; »'), findsOneWidget);
    expect(find.text('Capitale du Chili → Santiago'), findsOneWidget);
    expect(find.text('après les 2 cartes déjà en attente'), findsOneWidget);
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
    expect(find.text('EN PREMIER'), findsNothing);
  });

  testWidgets('adds the valid lines at the end of the queue, in order', (
    tester,
  ) async {
    await pumpBulkAdd(tester, waiting: 1);
    await tester.tap(find.text('Ajouter 3 cartes'));
    await tester.pumpAndSettle();
    final cards = await tester.runAsync(
      () => CardRepository(database).getCardsOfGroup(groupId),
    );
    expect(cards!.map((card) => card.isPending), everyElement(isTrue));
    expect(
      [for (final card in cards..sort(byQueue)) card.backText],
      ['Lima', 'Santiago', 'Nairobi', 'Hanoï'],
    );
  });

  testWidgets('"Shuffle" draws an order, shown and stored as drawn', (
    tester,
  ) async {
    const seed = 4;
    final draws = Random(seed);
    final backs = ['Santiago', 'Nairobi', 'Hanoï'];
    final fronts = {
      'Santiago': 'Capitale du Chili',
      'Nairobi': 'Capitale du Kenya',
      'Hanoï': 'Capitale du Vietnam',
    };
    await pumpBulkAdd(tester, seed: seed);
    await tester.tap(find.text('Mélanger'));
    await tester.pumpAndSettle();
    final first = BulkOrder.shuffled(draws.nextInt(1 << 32)).apply(backs);
    expect(find.text('${fronts[first.first]} → ${first.first}'), findsOne);
    await tester.tap(find.text('Mélanger'));
    await tester.pumpAndSettle();
    final second = BulkOrder.shuffled(draws.nextInt(1 << 32)).apply(backs);
    expect(find.text('${fronts[second.first]} → ${second.first}'), findsOne);
    await tester.tap(find.text('Ajouter 3 cartes'));
    await tester.pumpAndSettle();
    expect(await storedBacks(tester), second);
  });
}

int byQueue(Flashcard first, Flashcard second) =>
    first.queuePosition!.compareTo(second.queuePosition!);
