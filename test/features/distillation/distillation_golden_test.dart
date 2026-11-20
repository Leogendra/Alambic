import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/data/database/alambic_database.dart';
import 'package:alambic/data/repositories/distillation_repository.dart';
import 'package:alambic/domain/distillation/distillation_settings.dart';
import 'package:alambic/features/distillation/distill_screen.dart';
import 'package:alambic/features/groups/group_detail_screen.dart';
import 'package:alambic/features/home/home_screen.dart';

import '../../support/fixed_clock.dart';
import '../../support/golden_harness.dart';
import '../../support/sample_data.dart';
import '../../support/test_database.dart';

void main() {
  late AlambicDatabase database;
  late int japaneseId;

  setUp(() => database = openTestDatabase());
  tearDown(() => database.close());

  /// Sample data, and a "Japonais" group of six cards distilled one card a
  /// day, activated at 9am unless [activate] is false.
  Future<void> seed(WidgetTester tester, {bool activate = true}) async {
    await tester.runAsync(() async {
      final samples = SampleServices(database, FixedClock(sampleNow));
      await seedSampleData(samples);
      japaneseId = await samples.groups.create('Japonais');
      for (final (word, meaning) in [
        ('neko', 'chat'),
        ('inu', 'chien'),
        ('tori', 'oiseau'),
        ('sakana', 'poisson'),
        ('uma', 'cheval'),
        ('ushi', 'vache'),
      ]) {
        await samples.card(word, meaning, groupId: japaneseId);
      }
      if (activate) {
        await samples.distillations.activate(
          japaneseId,
          const DistillationSettings(),
        );
      }
    });
  }

  testWidgets('activating a distillation', (tester) async {
    await seed(tester, activate: false);
    await pumpGolden(
      tester,
      DistillScreen(groupId: japaneseId),
      overrides: screenOverrides(database, sampleNow),
      locale: const Locale('fr'),
    );
    expect(
      find.text('6 cartes · dernière arrivée vers le 15 novembre'),
      findsOne,
    );
    await expectLater(
      find.byType(DistillScreen),
      matchesGoldenFile('goldens/distill_activate.png'),
    );
  });

  testWidgets('during the global pause, the waiting cards instead of an '
      'estimate', (tester) async {
    await seed(tester, activate: false);
    await tester.runAsync(
      () => SampleServices(
        database,
        FixedClock(sampleNow),
      ).distillations.pauseAll(),
    );
    await pumpGolden(
      tester,
      DistillScreen(groupId: japaneseId),
      overrides: screenOverrides(database, sampleNow),
      locale: const Locale('fr'),
    );
    expect(
      find.text('6 cartes en attente · en pause', findRichText: true),
      findsOne,
    );
  });

  testWidgets('distillation followed on the group page', (tester) async {
    await seed(tester);
    await pumpGolden(
      tester,
      GroupDetailScreen(groupId: japaneseId),
      overrides: screenOverrides(database, sampleNow),
      locale: const Locale('fr'),
    );
    expect(find.text('5 cartes en attente'), findsOneWidget);
    await expectLater(
      find.byType(GroupDetailScreen),
      matchesGoldenFile('goldens/group_distillation.png'),
    );
  });

  testWidgets('new cards on the home timeline', (tester) async {
    await seed(tester);
    await pumpGolden(
      tester,
      const Scaffold(body: SafeArea(child: HomeScreen())),
      overrides: screenOverrides(database, sampleNow),
      locale: const Locale('fr'),
    );
    expect(find.text('Japonais : 1 nouvelle carte'), findsNWidgets(6));
    await expectLater(
      find.byType(HomeScreen),
      matchesGoldenFile('goldens/home_distillation.png'),
    );
  });

  testWidgets('activates the distillation from the screen', (tester) async {
    await seed(tester, activate: false);
    await pumpGolden(
      tester,
      DistillScreen(groupId: japaneseId),
      overrides: screenOverrides(database, sampleNow),
      locale: const Locale('fr'),
    );
    await tester.tap(find.byTooltip('Plus de cartes'));
    await tester.pumpAndSettle();
    expect(
      find.text('6 cartes · dernière arrivée vers le 12 novembre'),
      findsOne,
    );
    await tester.tap(find.text('Activer la distillation'));
    await tester.pumpAndSettle();
    final distillations = await tester.runAsync(
      () => DistillationRepository(database).getAll(),
    );
    expect(distillations!.single.groupId, japaneseId);
    expect(distillations.single.cardsPerBatch, 2);
    expect(find.byType(DistillScreen), findsNothing);
  });

  testWidgets('"Adjust" opens the current settings and saves new ones', (
    tester,
  ) async {
    await seed(tester);
    await pumpGolden(
      tester,
      GroupDetailScreen(groupId: japaneseId),
      overrides: screenOverrides(database, sampleNow),
      locale: const Locale('fr'),
    );
    await tester.tap(find.byTooltip('Régler la distillation'));
    await tester.pumpAndSettle();
    expect(find.text('Régler la distillation'), findsOneWidget);
    expect(find.text('1'), findsOneWidget, reason: 'one card per batch');
    await tester.tap(find.byTooltip('Plus de jours'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Enregistrer'));
    await tester.tap(find.text('Enregistrer'));
    // The save runs on the database, then the screen closes.
    for (
      var wait = 0;
      wait < 100 && find.byType(DistillScreen).evaluate().isNotEmpty;
      wait++
    ) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 10)),
      );
      await tester.pump();
    }
    await tester.pumpAndSettle();
    final distillation = await tester.runAsync(
      () => DistillationRepository(database).find(japaneseId),
    );
    expect(distillation!.everyDays, 2);
    expect(find.text('1 carte tous les 2 jours'), findsOne);
  });

  /// Pauses the distillation of Japonais, at 9am on the sample day.
  Future<void> pause(WidgetTester tester) => tester.runAsync(
    () => SampleServices(
      database,
      FixedClock(sampleNow),
    ).distillations.pause(japaneseId),
  );

  testWidgets('paused distillation on the group page', (tester) async {
    await seed(tester);
    await pause(tester);
    await pumpGolden(
      tester,
      GroupDetailScreen(groupId: japaneseId),
      overrides: screenOverrides(database, sampleNow),
      locale: const Locale('fr'),
    );
    expect(find.text('En pause depuis le 10 nov.'), findsOne);
    expect(find.text('aucune arrivée prévue'), findsOne);
    await expectLater(
      find.byType(GroupDetailScreen),
      matchesGoldenFile('goldens/group_distillation_paused.png'),
    );
  });

  testWidgets('a paused distillation resumes from its screen, at once', (
    tester,
  ) async {
    await seed(tester);
    await pause(tester);
    await pumpGolden(
      tester,
      DistillScreen(
        groupId: japaneseId,
        currentSettings: const DistillationSettings(),
      ),
      overrides: screenOverrides(database, sampleNow),
      locale: const Locale('fr'),
    );
    expect(
      find.text(
        'En pause depuis le 10 novembre : aucune nouvelle carte ne sort, '
        'les rappels continuent.',
      ),
      findsOne,
    );
    await expectLater(
      find.byType(DistillScreen),
      matchesGoldenFile('goldens/distill_adjust_paused.png'),
    );
    await tester.ensureVisible(find.text('Reprendre'));
    await tester.tap(find.text('Reprendre'));
    // The resume runs on the database, then the screen follows it.
    for (
      var wait = 0;
      wait < 100 && find.text('Mettre en pause').evaluate().isEmpty;
      wait++
    ) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 10)),
      );
      await tester.pump();
    }
    expect(find.text('Mettre en pause'), findsOne);
    expect(find.byType(DistillScreen), findsOne);
    final distillation = await tester.runAsync(
      () => DistillationRepository(database).find(japaneseId),
    );
    expect(distillation!.pausedAt, isNull);
  });
}
