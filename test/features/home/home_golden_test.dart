import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/data/database/alambic_database.dart';
import 'package:alambic/data/repositories/card_repository.dart';
import 'package:alambic/data/repositories/pause_repository.dart';
import 'package:alambic/domain/distillation/distillation_settings.dart';
import 'package:alambic/domain/reviews/review_outcome.dart';
import 'package:alambic/domain/reviews/review_source.dart';
import 'package:alambic/domain/scheduling/clock_time.dart';
import 'package:alambic/features/home/home_screen.dart';

import '../../support/fixed_clock.dart';
import '../../support/golden_harness.dart';
import '../../support/sample_data.dart';
import '../../support/test_database.dart';

void main() {
  late AlambicDatabase database;
  final renderAt = DateTime(2026, 11, 10, 12, 30);

  setUp(() => database = openTestDatabase());
  tearDown(() => database.close());

  /// Sample data answered in part at 12:05, a "Review soon" reminder at 18:00
  /// and a "Japonais" group distilling one card a day.
  Future<void> seed(WidgetTester tester) async {
    await tester.runAsync(() async {
      final samples = SampleServices(database, FixedClock(sampleNow));
      final capitals = await seedSampleData(samples);
      final japanese = await samples.groups.create('Japonais');
      await samples.card('猫', 'chat', groupId: japanese);
      await samples.card('犬', 'chien', groupId: japanese);
      await samples.distillations.activate(
        japanese,
        const DistillationSettings(),
      );
      final cards = await CardRepository(database).getCardsOfGroup(capitals);
      samples.clock.now = DateTime(2026, 11, 10, 12, 5);
      for (final card in cards.take(2)) {
        await samples.reviews.answer(
          card.id,
          ReviewOutcome.correct,
          source: ReviewSource.notification,
        );
      }
      await samples.reminders.add(
        cards.last.id,
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
        locale: const Locale('fr'),
      );
      expect(find.text('Japonais : 1 nouvelle carte'), findsNWidgets(2));
      expect(find.text('Capitals : 2 nouvelles cartes'), findsOneWidget);
      expect(find.text('DEMAIN'), findsOneWidget);
      await expectLater(
        find.byType(HomeScreen),
        matchesGoldenFile('goldens/home_${brightness.name}.png'),
      );
    });
  }

  testWidgets('home in English', (tester) async {
    await seed(tester);
    await pumpGolden(
      tester,
      const Scaffold(body: SafeArea(child: HomeScreen())),
      locale: const Locale('en'),
      overrides: screenOverrides(database, renderAt),
    );
    expect(find.text('TOMORROW'), findsOneWidget);
    await expectLater(
      find.byType(HomeScreen),
      matchesGoldenFile('goldens/home_english.png'),
    );
  });

  testWidgets('home during the global pause', (tester) async {
    await seed(tester);
    await tester.runAsync(
      () => PauseRepository(database).setGlobalPausedAt(sampleNow),
    );
    await pumpGolden(
      tester,
      const Scaffold(body: SafeArea(child: HomeScreen())),
      overrides: screenOverrides(database, renderAt),
      locale: const Locale('fr'),
    );
    expect(find.text('Reprendre'), findsOneWidget);
    await expectLater(
      find.byType(HomeScreen),
      matchesGoldenFile('goldens/home_paused.png'),
    );
  });

  testWidgets('the coming month and year, at the end of the timeline', (
    tester,
  ) async {
    await seed(tester);
    await tester.runAsync(() async {
      final samples = SampleServices(database, FixedClock(sampleNow));
      final vocabulary = await samples.groups.create('Vocabulaire');
      for (var word = 1; word <= 40; word++) {
        await samples.card('mot $word', 'word $word', groupId: vocabulary);
      }
      await samples.distillations.activate(
        vocabulary,
        const DistillationSettings(cardsPerBatch: 2, everyDays: 7),
      );
    });
    await pumpGolden(
      tester,
      const Scaffold(body: SafeArea(child: HomeScreen())),
      overrides: screenOverrides(database, renderAt),
      locale: const Locale('fr'),
    );
    await tester.drag(find.byType(ListView), const Offset(0, -800));
    await tester.pumpAndSettle();
    expect(find.text('8 cartes'), findsOneWidget);
    expect(find.text('30 cartes'), findsOneWidget);
    await expectLater(
      find.byType(HomeScreen),
      matchesGoldenFile('goldens/home_coming.png'),
    );
  });
}
