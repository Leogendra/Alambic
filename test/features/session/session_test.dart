import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/application/cards/card_draft.dart';
import 'package:alambic/application/cards/draft_image.dart';
import 'package:alambic/application/reviews/session_item.dart';
import 'package:alambic/data/database/alambic_database.dart';
import 'package:alambic/data/repositories/card_repository.dart';
import 'package:alambic/data/repositories/review_repository.dart';
import 'package:alambic/domain/cards/direction_sense.dart';
import 'package:alambic/features/session/session_screen.dart';

import '../../support/fixed_clock.dart';
import '../../support/golden_harness.dart';
import '../../support/sample_data.dart';
import '../../support/test_database.dart';
import '../../support/test_images.dart';

void main() {
  late AlambicDatabase database;
  late List<SessionItem> items;

  setUp(() => database = openTestDatabase());
  tearDown(() => database.close());

  Future<void> pumpSession(WidgetTester tester) async {
    await tester.runAsync(() async {
      final capitals = await seedSampleData(
        SampleServices(database, FixedClock(sampleNow)),
      );
      final cards = await CardRepository(database)
          .watchCardsOfGroup(capitals)
          .first;
      items = [
        for (final card in cards.take(2))
          SessionItem(
            cardId: card.card.id,
            directionId: card.direction(DirectionSense.frontToBack)!.id,
          ),
      ];
    });
    await pumpGolden(
      tester,
      SessionScreen(items: items),
      overrides: screenOverrides(database, sampleNow),
    );
  }

  testWidgets('shows the image of a face above its text', (tester) async {
    final images = openTestImageStore();
    late List<SessionItem> flagItems;
    late String flagPath;
    await tester.runAsync(() async {
      final services = SampleServices(
        database,
        FixedClock(sampleNow),
        images: images,
      );
      final cardId = await services.cards.create(
        const CardDraft(
          frontText: 'Quel pays a ce drapeau ?',
          backText: 'Pérou',
          frontImage: PickedImage('test/support/fixtures/flag.png'),
          groupId: null,
          presetId: null,
          alsoReverse: false,
        ),
      );
      await services.cards.startGroup(null);
      final front = (await CardRepository(database).getDirections(cardId))
          .firstWhere(
            (direction) => direction.sense == DirectionSense.frontToBack,
          );
      flagItems = [SessionItem(cardId: cardId, directionId: front.id)];
      flagPath = images.pathOf(
        (await CardRepository(database).getCard(cardId)).frontImagePath!,
      );
    });
    await precacheImageFile(tester, flagPath);
    await pumpGolden(
      tester,
      SessionScreen(items: flagItems),
      overrides: screenOverrides(database, sampleNow, images: images),
    );
    await expectLater(
      find.byType(SessionScreen),
      matchesGoldenFile('goldens/session_image.png'),
    );
  });

  Future<void> answer(WidgetTester tester, String button) async {
    await tester.tap(find.text('Afficher la réponse'));
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      await tester.tap(find.text(button));
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();
  }

  testWidgets('shows the prompt, then the answer and the next intervals', (
    tester,
  ) async {
    await pumpSession(tester);
    await expectLater(
      find.byType(SessionScreen),
      matchesGoldenFile('goldens/session_front.png'),
    );
    await tester.tap(find.text('Afficher la réponse'));
    await tester.pumpAndSettle();
    expect(find.text('Oulan-Bator'), findsOneWidget);
    expect(find.text('demain'), findsNWidgets(2));
    await expectLater(
      find.byType(SessionScreen),
      matchesGoldenFile('goldens/session_back.png'),
    );
  });

  testWidgets('ends on a summary and reviews the missed card as a bonus', (
    tester,
  ) async {
    await pumpSession(tester);
    await answer(tester, 'Correct');
    await answer(tester, 'À revoir');
    expect(find.text('Session terminée'), findsOneWidget);
    await expectLater(
      find.byType(SessionScreen),
      matchesGoldenFile('goldens/session_end.png'),
    );
    await tester.tap(find.text('Revoir la ratée maintenant'));
    await tester.pumpAndSettle();
    await answer(tester, 'Correct');
    final history = await tester.runAsync(
      () => ReviewRepository(database).watchHistory(items[1].directionId).first,
    );
    expect(history!.map((review) => review.isBonus), [true, false]);
  });
}
