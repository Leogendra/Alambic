import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/data/database/alambic_database.dart';
import 'package:alambic/data/repositories/distillation_repository.dart';
import 'package:alambic/domain/distillation/distillation_settings.dart';
import 'package:alambic/features/distillation/distillation_launch_screen.dart';
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
      DistillationLaunchScreen(groupId: japaneseId),
      overrides: screenOverrides(database, sampleNow),
    );
    expect(find.text('6 cartes · dernière arrivée le 15 novembre'), findsOne);
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

  testWidgets('activates the distillation from the screen', (tester) async {
    await seed(tester, activate: false);
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
    expect(distillations!.single.groupId, japaneseId);
    expect(distillations.single.cardsPerBatch, 2);
    expect(find.byType(DistillationLaunchScreen), findsNothing);
  });
}
