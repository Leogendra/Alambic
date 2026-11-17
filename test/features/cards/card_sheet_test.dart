import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/data/database/alambic_database.dart';
import 'package:alambic/data/repositories/card_repository.dart';
import 'package:alambic/domain/reviews/review_outcome.dart';
import 'package:alambic/domain/reviews/review_source.dart';
import 'package:alambic/domain/scheduling/clock_time.dart';
import 'package:alambic/features/cards/card_sheet_screen.dart';

import '../../support/fixed_clock.dart';
import '../../support/golden_harness.dart';
import '../../support/sample_data.dart';
import '../../support/test_database.dart';

void main() {
  late AlambicDatabase database;

  setUp(() => database = openTestDatabase());
  tearDown(() => database.close());

  /// "Pérou" answered over three days, with a bonus review and a reminder.
  /// Returns its id.
  Future<int> seedReviewedCard(WidgetTester tester, DateTime renderAt) async {
    late int cardId;
    await tester.runAsync(() async {
      final clock = FixedClock(sampleNow);
      final samples = SampleServices(database, clock);
      final capitals = await samples.groups.create('Capitales');
      cardId = await samples.card('Pérou', 'Lima', groupId: capitals);
      await samples.introduceAll(capitals);
      Future<void> answer(DateTime at, ReviewOutcome outcome) async {
        clock.now = at;
        await samples.reviews.answer(
          cardId,
          outcome,
          source: ReviewSource.notification,
        );
      }

      await answer(DateTime(2026, 11, 10, 12, 2), ReviewOutcome.correct);
      await answer(DateTime(2026, 11, 10, 18), ReviewOutcome.correct);
      await answer(DateTime(2026, 11, 11, 12, 1), ReviewOutcome.correct);
      await answer(DateTime(2026, 11, 12, 8), ReviewOutcome.again);
      clock.now = renderAt;
      await samples.reminders.add(
        cardId,
        DateTime(2026, 11, 15),
        const ClockTime(18, 0),
      );
    });
    return cardId;
  }

  for (final (brightness, suffix) in [
    (Brightness.light, ''),
    (Brightness.dark, '_dark'),
  ]) {
    testWidgets('card sheet, ${brightness.name} theme', (tester) async {
      final renderAt = DateTime(2026, 11, 12, 9);
      final cardId = await seedReviewedCard(tester, renderAt);
      await pumpGolden(
        tester,
        CardSheetScreen(cardId: cardId),
        brightness: brightness,
        overrides: screenOverrides(database, renderAt),
      );
      // No reminder label; the remanence follows the last step of Standard.
      expect(find.text('J2'), findsNothing);
      expect(find.text('6 mois'), findsNWidgets(2));
      expect(find.text('bonus'), findsNWidgets(2));
      await expectLater(
        find.byType(CardSheetScreen),
        matchesGoldenFile('goldens/card_sheet$suffix.png'),
      );
    });
  }

  testWidgets('a pending card waits for its distillation', (tester) async {
    late int cardId;
    await tester.runAsync(() async {
      final samples = SampleServices(database, FixedClock(sampleNow));
      cardId = await samples.card(
        'Laos',
        'Vientiane',
        groupId: await samples.groups.create('Capitales'),
      );
    });
    await pumpGolden(
      tester,
      CardSheetScreen(cardId: cardId),
      overrides: screenOverrides(database, sampleNow),
    );
    expect(
      find.text('En attente : la distillation du groupe la fera sortir.'),
      findsOneWidget,
    );
    final card = await tester.runAsync(
      () => CardRepository(database).getCard(cardId),
    );
    expect(card!.isPending, isTrue);
  });
}
