import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:alambic/data/database/alambic_database.dart';
import 'package:alambic/data/repositories/card_repository.dart';
import 'package:alambic/domain/reviews/review_outcome.dart';
import 'package:alambic/domain/reviews/review_source.dart';
import 'package:alambic/features/cards/card_sheet_screen.dart';

import '../../support/fixed_clock.dart';
import '../../support/screen_harness.dart';
import '../../support/sample_data.dart';
import '../../support/test_database.dart';
import '../../support/test_screen.dart';

void main() {
  late AlambicDatabase database;

  setUp(() => database = openTestDatabase());
  tearDown(() => closeTestDatabase(database));

  /// "Peru" answered over three days, with a bonus review and a reminder.
  /// Returns its id.
  Future<int> seedReviewedCard(WidgetTester tester, DateTime renderAt) async {
    late int cardId;
    await tester.runAsync(() async {
      final clock = FixedClock(sampleNow);
      final samples = SampleServices(database, clock);
      final capitals = await samples.groups.create('Capitals');
      cardId = await samples.card('Peru', 'Lima', groupId: capitals);
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
    });
    return cardId;
  }

  for (final (brightness, suffix) in [
    (Brightness.light, ''),
    (Brightness.dark, '_dark'),
  ]) {
    testScreen('card sheet, ${brightness.name} theme', (tester) async {
      final renderAt = DateTime(2026, 11, 12, 9);
      final cardId = await seedReviewedCard(tester, renderAt);
      await pumpScreen(
        tester,
        CardSheetScreen(cardId: cardId),
        brightness: brightness,
        overrides: screenOverrides(database, renderAt),
      );
      // No reminder label; the remanence follows the last step of Standard.
      expect(find.text('D2'), findsNothing);
      expect(find.text('6\u00A0mo'), findsNWidgets(2));
      expect(find.text('bonus'), findsNWidgets(2));
      await captureShot(
        tester,
        find.byType(CardSheetScreen),
        'card_sheet$suffix',
      );
      await expectNoOverflow(tester);
    });
  }

  testScreen('a pending card waits for its distillation', (tester) async {
    late int cardId;
    await tester.runAsync(() async {
      final samples = SampleServices(database, FixedClock(sampleNow));
      cardId = await samples.card(
        'Laos',
        'Vientiane',
        groupId: await samples.groups.create('Capitals'),
      );
    });
    await pumpScreen(
      tester,
      CardSheetScreen(cardId: cardId),
      overrides: screenOverrides(database, sampleNow),
    );
    expect(
      find.text('Waiting: the distillation of the group will bring it in.'),
      findsOneWidget,
    );
    final card = await tester.runAsync(
      () => CardRepository(database).getCard(cardId),
    );
    expect(card!.isPending, isTrue);
  });
}
