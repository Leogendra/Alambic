import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:alambic/application/randomness.dart';
import 'package:alambic/data/database/alambic_database.dart';
import 'package:alambic/data/repositories/card_repository.dart';
import 'package:alambic/domain/cards/flashcard.dart';
import 'package:alambic/domain/cards/bulk/bulk_order.dart';
import 'package:alambic/features/cards/bulk_add_screen.dart';

import '../../support/fixed_clock.dart';
import '../../support/screen_harness.dart';
import '../../support/sample_data.dart';
import '../../support/test_database.dart';
import '../../support/test_screen.dart';

const String pastedLines =
    'Capital of Chile ; Santiago\n'
    'Capital of Kenya ; Nairobi\n'
    'Capital of Morocco Rabat\n'
    'Capital of Vietnam ; Hanoi';

void main() {
  late AlambicDatabase database;
  late int groupId;

  setUp(() => database = openTestDatabase());
  tearDown(() => closeTestDatabase(database));

  /// The bulk add of a group that already has [waiting] cards in its queue;
  /// [seed] drives the shuffle draws.
  Future<void> pumpBulkAdd(
    WidgetTester tester, {
    int waiting = 0,
    int seed = 0,
  }) async {
    await tester.runAsync(() async {
      final services = SampleServices(database, FixedClock(sampleNow));
      groupId = await services.groups.create('Capitals');
      for (var index = 0; index < waiting; index++) {
        await services.card('Capital of Peru', 'Lima', groupId: groupId);
      }
    });
    await pumpScreen(
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

  testScreen('reports ignored lines and the first card before adding', (
    tester,
  ) async {
    await pumpBulkAdd(tester, waiting: 2);
    expect(find.text('3 cards ready'.toUpperCase()), findsOneWidget);
    expect(find.text('Line 3 skipped: no ";"'), findsOneWidget);
    expect(find.text('Capital of Chile → Santiago'), findsOneWidget);
    expect(find.text('after the 2 cards already waiting'), findsOneWidget);
    await captureShot(tester, find.byType(BulkAddScreen), 'bulk_add');
    await expectNoOverflow(tester);
  });

  testScreen('a custom separator rereads every line', (tester) async {
    await pumpBulkAdd(tester);
    await tester.enterText(find.byType(TextField).first, ',');
    await tester.pumpAndSettle();
    expect(find.text('No card ready'.toUpperCase()), findsOneWidget);
    expect(find.text(l10n.bulkFirst.toUpperCase()), findsNothing);
  });

  testScreen('adds the valid lines at the end of the queue, in order', (
    tester,
  ) async {
    await pumpBulkAdd(tester, waiting: 1);
    await tester.tap(find.text(l10n.bulkAddButton(3)));
    await tester.pumpAndSettle();
    final cards = await tester.runAsync(
      () => CardRepository(database).getCardsOfGroup(groupId),
    );
    expect(cards!.map((card) => card.isPending), everyElement(isTrue));
    expect(
      [for (final card in cards..sort(byQueue)) card.backText],
      ['Lima', 'Santiago', 'Nairobi', 'Hanoi'],
    );
  });

  testScreen('"Shuffle" draws an order, shown and stored as drawn', (
    tester,
  ) async {
    const seed = 4;
    final draws = Random(seed);
    final backs = ['Santiago', 'Nairobi', 'Hanoi'];
    final fronts = {
      'Santiago': 'Capital of Chile',
      'Nairobi': 'Capital of Kenya',
      'Hanoi': 'Capital of Vietnam',
    };
    await pumpBulkAdd(tester, seed: seed);
    await tester.tap(find.text(l10n.bulkOrderShuffled));
    await tester.pumpAndSettle();
    final first = BulkOrder.shuffled(draws.nextInt(1 << 32)).apply(backs);
    expect(find.text('${fronts[first.first]} → ${first.first}'), findsOne);
    await tester.tap(find.text(l10n.bulkOrderShuffled));
    await tester.pumpAndSettle();
    final second = BulkOrder.shuffled(draws.nextInt(1 << 32)).apply(backs);
    expect(find.text('${fronts[second.first]} → ${second.first}'), findsOne);
    await tester.tap(find.text(l10n.bulkAddButton(3)));
    await tester.pumpAndSettle();
    expect(await storedBacks(tester), second);
  });
}

int byQueue(Flashcard first, Flashcard second) =>
    first.queuePosition!.compareTo(second.queuePosition!);
