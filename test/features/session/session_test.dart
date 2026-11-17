import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/application/cards/card_draft.dart';
import 'package:alambic/application/cards/draft_image.dart';
import 'package:alambic/application/reviews/session_item.dart';
import 'package:alambic/data/database/alambic_database.dart';
import 'package:alambic/data/repositories/card_repository.dart';
import 'package:alambic/data/repositories/review_repository.dart';
import 'package:alambic/domain/cards/card_side.dart';
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

  Future<void> pumpSession(
    WidgetTester tester, {
    Brightness brightness = Brightness.light,
  }) async {
    await tester.runAsync(() async {
      final capitals = await seedSampleData(
        SampleServices(database, FixedClock(sampleNow)),
      );
      final cards = await CardRepository(database)
          .watchCardsOfGroup(capitals)
          .first;
      items = [
        for (final card in cards.take(2))
          SessionItem(cardId: card.id, askedSide: CardSide.front),
      ];
    });
    await pumpGolden(
      tester,
      SessionScreen(items: items),
      brightness: brightness,
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
      final flags = await services.groups.create('Drapeaux');
      final cardId = await services.cards.create(
        CardDraft(
          frontText: 'Quel pays a ce drapeau ?',
          backText: 'Pérou',
          frontImage: const PickedImage('test/support/fixtures/flag.png'),
          groupId: flags,
        ),
      );
      await services.introduceAll(flags);
      flagItems = [SessionItem(cardId: cardId, askedSide: CardSide.front)];
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

  for (final (brightness, suffix) in [
    (Brightness.light, ''),
    (Brightness.dark, '_dark'),
  ]) {
    testWidgets('shows the prompt, then the answer and the next intervals, '
        '${brightness.name} theme', (tester) async {
      await pumpSession(tester, brightness: brightness);
      await expectLater(
        find.byType(SessionScreen),
        matchesGoldenFile('goldens/session_front$suffix.png'),
      );
      await tester.tap(find.text('Afficher la réponse'));
      await tester.pumpAndSettle();
      expect(find.text('Oulan-Bator'), findsOneWidget);
      expect(find.text('demain'), findsNWidgets(2));
      await expectLater(
        find.byType(SessionScreen),
        matchesGoldenFile('goldens/session_back$suffix.png'),
      );
    });
  }

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
    await tester.runAsync(() async {
      await tester.tap(find.text('Revoir la ratée maintenant'));
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();
    await answer(tester, 'Correct');
    final history = await tester.runAsync(
      () => ReviewRepository(database).watchHistory(items[1].cardId).first,
    );
    expect(history!.map((review) => review.isBonus), [true, false]);
  });

  testWidgets('a card drawn on its back asks the back', (tester) async {
    late List<SessionItem> backItems;
    await tester.runAsync(() async {
      final capitals = await seedSampleData(
        SampleServices(database, FixedClock(sampleNow)),
      );
      final card = (await CardRepository(database).getCardsOfGroup(capitals))
          .first;
      backItems = [SessionItem(cardId: card.id, askedSide: CardSide.back)];
    });
    await pumpGolden(
      tester,
      SessionScreen(items: backItems),
      overrides: screenOverrides(database, sampleNow),
    );
    expect(find.text('Oulan-Bator'), findsOneWidget);
    expect(find.textContaining('verso → recto'), findsOneWidget);
    await tester.tap(find.text('Afficher la réponse'));
    await tester.pumpAndSettle();
    expect(find.text('Mongolie'), findsOneWidget);
  });
}
