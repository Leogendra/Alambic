import 'package:flutter_test/flutter_test.dart';
import 'package:remanence/data/database/remanence_database.dart';
import 'package:remanence/data/repositories/card_repository.dart';
import 'package:remanence/domain/cards/direction_sense.dart';
import 'package:remanence/domain/cards/direction_state.dart';
import 'package:remanence/domain/reviews/review_outcome.dart';
import 'package:remanence/domain/reviews/review_source.dart';
import 'package:remanence/domain/scheduling/clock_time.dart';
import 'package:remanence/features/cards/card_sheet_screen.dart';

import '../../support/fixed_clock.dart';
import '../../support/golden_harness.dart';
import '../../support/sample_data.dart';
import '../../support/test_database.dart';

void main() {
  late RemanenceDatabase database;

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
      cardId = await samples.card(
        'Pérou',
        'Lima',
        groupId: capitals,
        alsoReverse: true,
      );
      await samples.cards.startGroup(capitals);
      final front = (await CardRepository(database).getDirections(cardId))
          .firstWhere(
            (direction) => direction.sense == DirectionSense.frontToBack,
          );
      Future<void> answer(DateTime at, ReviewOutcome outcome) async {
        clock.now = at;
        await samples.reviews.answer(
          front.id,
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
        front.id,
        DateTime(2026, 11, 15),
        const ClockTime(18, 0),
      );
    });
    return cardId;
  }

  testWidgets('card sheet', (tester) async {
    final renderAt = DateTime(2026, 11, 12, 9);
    final cardId = await seedReviewedCard(tester, renderAt);
    await pumpGolden(
      tester,
      CardSheetScreen(cardId: cardId),
      overrides: screenOverrides(database, renderAt),
    );
    expect(find.text('Cran 1 sur 6'), findsOneWidget);
    expect(find.text('recule à 1 j'), findsOneWidget);
    expect(find.text('bonus'), findsNWidgets(2));
    await expectLater(
      find.byType(CardSheetScreen),
      matchesGoldenFile('goldens/card_sheet.png'),
    );
  });

  testWidgets('starts a direction that waits to be started', (tester) async {
    late int cardId;
    await tester.runAsync(() async {
      cardId = await SampleServices(
        database,
        FixedClock(sampleNow),
      ).card('Laos', 'Vientiane');
    });
    await pumpGolden(
      tester,
      CardSheetScreen(cardId: cardId),
      overrides: screenOverrides(database, sampleNow),
    );
    await tester.runAsync(() async {
      await tester.tap(find.text('Commencer ce sens'));
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();
    final front = await tester.runAsync(
      () async => (await CardRepository(database).getDirections(cardId))
          .firstWhere(
            (direction) => direction.sense == DirectionSense.frontToBack,
          ),
    );
    expect(front!.state, DirectionState.active);
    expect(find.text('À réviser maintenant'), findsOneWidget);
  });
}
