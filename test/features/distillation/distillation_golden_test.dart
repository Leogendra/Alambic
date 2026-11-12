import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remanence/data/database/remanence_database.dart';
import 'package:remanence/data/repositories/distillation_repository.dart';
import 'package:remanence/domain/cards/direction_sense.dart';
import 'package:remanence/domain/distillation/distillation_settings.dart';
import 'package:remanence/features/distillation/distillation_launch_screen.dart';
import 'package:remanence/features/groups/group_detail_screen.dart';
import 'package:remanence/features/home/home_screen.dart';

import '../../support/fixed_clock.dart';
import '../../support/golden_harness.dart';
import '../../support/sample_data.dart';
import '../../support/test_database.dart';

void main() {
  late RemanenceDatabase database;
  late int japaneseId;

  setUp(() => database = openTestDatabase());
  tearDown(() => database.close());

  /// Sample data, and a "Japonais" group of six cards whose front → back
  /// direction is distilled one card a day, launched at 9am.
  Future<void> seed(WidgetTester tester) async {
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
      await samples.distillations.launchForGroup(
        japaneseId,
        DirectionSense.frontToBack,
        const DistillationSettings(),
      );
    });
  }

  testWidgets('launching a distillation', (tester) async {
    await seed(tester);
    await pumpGolden(
      tester,
      DistillationLaunchScreen(groupId: japaneseId),
      overrides: screenOverrides(database, sampleNow),
    );
    expect(find.text('6 cartes à introduire'), findsOneWidget);
    await expectLater(
      find.byType(DistillationLaunchScreen),
      matchesGoldenFile('goldens/distillation_launch.png'),
    );
  });

  testWidgets('distillation followed on the group page', (tester) async {
    await seed(tester);
    await pumpGolden(
      tester,
      GroupDetailScreen(groupId: japaneseId),
      overrides: screenOverrides(database, sampleNow),
    );
    expect(find.text('1 sur 6 introduites'), findsOneWidget);
    await expectLater(
      find.byType(GroupDetailScreen),
      matchesGoldenFile('goldens/group_distillation.png'),
    );
  });

  testWidgets('new knowledge on the home timeline', (tester) async {
    await seed(tester);
    await pumpGolden(
      tester,
      const Scaffold(body: SafeArea(child: HomeScreen())),
      overrides: screenOverrides(database, sampleNow),
    );
    expect(find.text('Nouvelle connaissance'), findsOneWidget);
    expect(find.text('Japonais · distillation, carte 1 sur 6'), findsOneWidget);
    await expectLater(
      find.byType(HomeScreen),
      matchesGoldenFile('goldens/home_distillation.png'),
    );
  });

  testWidgets('launching the reverse direction from the screen', (
    tester,
  ) async {
    await seed(tester);
    await pumpGolden(
      tester,
      DistillationLaunchScreen(groupId: japaneseId),
      overrides: screenOverrides(database, sampleNow),
    );
    await tester.tap(find.byTooltip('Plus de cartes'));
    await tester.pumpAndSettle();
    expect(find.text('6 cartes · dernière arrivée le 12 novembre'), findsOne);
    await tester.tap(find.text('Lancer la distillation'));
    await tester.pumpAndSettle();
    final distillations = await tester.runAsync(
      () => DistillationRepository(database).getAll(),
    );
    final reverse = distillations!.last;
    expect(reverse.sense, DirectionSense.backToFront);
    expect(reverse.cardsPerBatch, 2);
    expect(find.byType(DistillationLaunchScreen), findsNothing);
  });
}
