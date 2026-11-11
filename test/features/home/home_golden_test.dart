import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remanence/data/database/remanence_database.dart';
import 'package:remanence/data/repositories/card_repository.dart';
import 'package:remanence/domain/cards/direction_sense.dart';
import 'package:remanence/domain/reviews/review_outcome.dart';
import 'package:remanence/domain/reviews/review_source.dart';
import 'package:remanence/domain/scheduling/clock_time.dart';
import 'package:remanence/features/home/home_screen.dart';

import '../../support/fixed_clock.dart';
import '../../support/golden_harness.dart';
import '../../support/sample_data.dart';
import '../../support/test_database.dart';

void main() {
  late RemanenceDatabase database;
  final renderAt = DateTime(2026, 11, 10, 12, 30);

  setUp(() => database = openTestDatabase());
  tearDown(() => database.close());

  /// Sample data answered in part at 12:05, a "Review soon" reminder at 18:00
  /// and a "Japonais" group whose cards are not started yet.
  Future<void> seed(WidgetTester tester) async {
    await tester.runAsync(() async {
      final samples = SampleServices(database, FixedClock(sampleNow));
      final capitals = await seedSampleData(samples);
      final japanese = await samples.groups.create('Japonais');
      await samples.card('猫', 'chat', groupId: japanese);
      await samples.card('犬', 'chien', groupId: japanese);
      final cards = await CardRepository(database).getCardsOfGroup(capitals);
      samples.clock.now = DateTime(2026, 11, 10, 12, 5);
      for (final card in cards.take(2)) {
        await samples.reviews.answer(
          card.direction(DirectionSense.frontToBack)!.id,
          ReviewOutcome.correct,
          source: ReviewSource.notification,
        );
      }
      await samples.reminders.add(
        cards.last.direction(DirectionSense.frontToBack)!.id,
        DateTime(2026, 11, 10),
        const ClockTime(18, 0),
      );
    });
  }

  for (final brightness in Brightness.values) {
    testWidgets('home in ${brightness.name} theme', (tester) async {
      await seed(tester);
      await pumpGolden(
        tester,
        const Scaffold(body: SafeArea(child: HomeScreen())),
        brightness: brightness,
        overrides: screenOverrides(database, renderAt),
      );
      expect(find.text('Tout réviser maintenant'), findsOneWidget);
      await expectLater(
        find.byType(HomeScreen),
        matchesGoldenFile('goldens/home_${brightness.name}.png'),
      );
    });
  }
}
