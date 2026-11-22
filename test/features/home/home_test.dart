import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:alambic/data/database/alambic_database.dart';
import 'package:alambic/data/repositories/card_repository.dart';
import 'package:alambic/data/repositories/pause_repository.dart';
import 'package:alambic/domain/distillation/distillation_settings.dart';
import 'package:alambic/domain/reviews/review_outcome.dart';
import 'package:alambic/domain/reviews/review_source.dart';
import 'package:alambic/domain/scheduling/clock_time.dart';
import 'package:alambic/features/home/home_screen.dart';

import '../../support/fixed_clock.dart';
import '../../support/screen_harness.dart';
import '../../support/sample_data.dart';
import '../../support/test_database.dart';
import '../../support/test_screen.dart';

void main() {
  late AlambicDatabase database;
  final renderAt = DateTime(2026, 11, 10, 12, 30);

  setUp(() => database = openTestDatabase());
  tearDown(() => closeTestDatabase(database));

  /// Sample data answered in part at 12:05, a "Review soon" reminder at 18:00
  /// and a "Japanese" group distilling one card a day.
  Future<void> seed(WidgetTester tester) async {
    await tester.runAsync(() async {
      final samples = SampleServices(database, FixedClock(sampleNow));
      final capitals = await seedSampleData(samples);
      final japanese = await samples.groups.create('Japanese');
      await samples.card('猫', 'cat', groupId: japanese);
      await samples.card('犬', 'dog', groupId: japanese);
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
    testScreen('home in ${brightness.name} theme', (tester) async {
      await seed(tester);
      await pumpScreen(
        tester,
        const Scaffold(body: SafeArea(child: HomeScreen())),
        brightness: brightness,
        overrides: screenOverrides(database, renderAt),
      );
      expect(find.text('Japanese 1'), findsNWidgets(2));
      expect(find.text('Capitals 2'), findsOneWidget);
      expect(find.text('TOMORROW'), findsOneWidget);
      // The global pause is started from Settings, not from Home.
      expect(find.byIcon(Icons.pause), findsNothing);
      await captureShot(
        tester,
        find.byType(HomeScreen),
        'home_${brightness.name}',
      );
      await expectNoOverflow(tester);
    });
  }

  testScreen('home in French', (tester) async {
    await seed(tester);
    await pumpScreen(
      tester,
      const Scaffold(body: SafeArea(child: HomeScreen())),
      locale: const Locale('fr'),
      overrides: screenOverrides(database, renderAt),
    );
    expect(find.text('DEMAIN'), findsOneWidget);
    await captureShot(tester, find.byType(HomeScreen), 'home_french');
    await expectNoOverflow(tester);
  });

  testScreen('home during the global pause', (tester) async {
    await seed(tester);
    await tester.runAsync(
      () => PauseRepository(database).setGlobalPausedAt(sampleNow),
    );
    await pumpScreen(
      tester,
      const Scaffold(body: SafeArea(child: HomeScreen())),
      overrides: screenOverrides(database, renderAt),
    );
    expect(find.text('Resume'), findsOneWidget);
    await captureShot(tester, find.byType(HomeScreen), 'home_paused');
    await expectNoOverflow(tester);
  });

  testScreen('the coming month and year, at the end of the timeline', (
    tester,
  ) async {
    await seed(tester);
    await tester.runAsync(() async {
      final samples = SampleServices(database, FixedClock(sampleNow));
      final vocabulary = await samples.groups.create('Vocabulary');
      for (var word = 1; word <= 40; word++) {
        await samples.card('word $word', 'meaning $word', groupId: vocabulary);
      }
      await samples.distillations.activate(
        vocabulary,
        const DistillationSettings(),
      );
    });
    await pumpScreen(
      tester,
      const Scaffold(body: SafeArea(child: HomeScreen())),
      overrides: screenOverrides(database, renderAt),
    );
    await tester.drag(find.byType(ListView), const Offset(0, -800));
    await tester.pumpAndSettle();
    expect(find.text('8'), findsOneWidget);
    expect(find.text('cards next month'), findsOneWidget);
    expect(find.text('28'), findsOneWidget);
    expect(find.text('cards next year'), findsOneWidget);
    await captureShot(tester, find.byType(HomeScreen), 'home_coming');
    await expectNoOverflow(tester);
  });

  testScreen('pulling the timeline down uncovers the cards learned', (
    tester,
  ) async {
    await seed(tester);
    await pumpScreen(
      tester,
      const Scaffold(body: SafeArea(child: HomeScreen())),
      brightness: Brightness.dark,
      overrides: screenOverrides(database, renderAt),
    );
    expect(find.text('cards learned'), findsNothing);
    final pull = await tester.startGesture(const Offset(200, 300));
    await pull.moveBy(const Offset(0, 200));
    await tester.pump();
    expect(find.text('cards learned'), findsOneWidget);
    await captureShot(tester, find.byType(HomeScreen), 'home_learned');
    await pull.up();
    await tester.pumpAndSettle();
    expect(find.text('cards learned'), findsNothing);
  });
}
