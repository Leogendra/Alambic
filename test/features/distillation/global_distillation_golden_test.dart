import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/data/database/alambic_database.dart';
import 'package:alambic/data/repositories/distillation_repository.dart';
import 'package:alambic/domain/cards/direction_sense.dart';
import 'package:alambic/domain/distillation/distillation_settings.dart';
import 'package:alambic/features/distillation/distillation_launch_screen.dart';
import 'package:alambic/features/distillation/global_distillation_screen.dart';

import '../../support/fixed_clock.dart';
import '../../support/golden_harness.dart';
import '../../support/sample_data.dart';
import '../../support/test_database.dart';

void main() {
  late AlambicDatabase database;
  late SampleServices samples;
  late int japaneseId;

  setUp(() => database = openTestDatabase());
  tearDown(() => database.close());

  /// Sample data, a "Japonais" group of four new cards distilled front →
  /// back, and two new cards outside any group, one of them both ways.
  Future<void> seed(WidgetTester tester) async {
    await tester.runAsync(() async {
      samples = SampleServices(database, FixedClock(sampleNow));
      await seedSampleData(samples);
      japaneseId = await samples.groups.create('Japonais');
      for (final (word, meaning) in [
        ('neko', 'chat'),
        ('inu', 'chien'),
        ('tori', 'oiseau'),
        ('sakana', 'poisson'),
      ]) {
        await samples.card(word, meaning, groupId: japaneseId);
      }
      await samples.distillations.launchForGroup(
        japaneseId,
        DirectionSense.frontToBack,
        const DistillationSettings(),
      );
      await samples.card('Ribosome', 'synthèse des protéines');
      await samples.card('ADN', 'acide désoxyribonucléique', alsoReverse: true);
    });
  }

  Future<void> launchGlobal(WidgetTester tester) => tester.runAsync(
    () => samples.distillations.launchGlobal(const DistillationSettings()),
  );

  testWidgets('global distillation, before launching', (tester) async {
    await seed(tester);
    await pumpGolden(
      tester,
      const GlobalDistillationScreen(),
      overrides: screenOverrides(database, sampleNow),
    );
    expect(find.text('6 à introduire · environ 6 jours à ce rythme'), findsOne);
    await expectLater(
      find.byType(GlobalDistillationScreen),
      matchesGoldenFile('goldens/global_distillation_launch.png'),
    );
  });

  testWidgets('global distillation in progress', (tester) async {
    await seed(tester);
    await launchGlobal(tester);
    await pumpGolden(
      tester,
      const GlobalDistillationScreen(),
      overrides: screenOverrides(database, sampleNow),
    );
    await expectLater(
      find.byType(GlobalDistillationScreen),
      matchesGoldenFile('goldens/global_distillation_running.png'),
    );
  });

  testWidgets('a group cannot be distilled during the global distillation', (
    tester,
  ) async {
    await seed(tester);
    await launchGlobal(tester);
    await pumpGolden(
      tester,
      DistillationLaunchScreen(groupId: japaneseId),
      overrides: screenOverrides(database, sampleNow),
    );
    expect(find.text('Lancer la distillation'), findsNothing);
    await expectLater(
      find.byType(DistillationLaunchScreen),
      matchesGoldenFile('goldens/distillation_blocked.png'),
    );
  });

  testWidgets('launching from the screen replaces the group distillation', (
    tester,
  ) async {
    await seed(tester);
    await pumpGolden(
      tester,
      const GlobalDistillationScreen(),
      overrides: screenOverrides(database, sampleNow),
    );
    await tester.tap(find.text('Lancer la distillation globale'));
    await tester.pumpAndSettle();
    final distillations = await tester.runAsync(
      () => DistillationRepository(database).getAll(),
    );
    expect(distillations!.single.isGlobal, isTrue);
  });
}
