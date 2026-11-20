import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:alambic/application/cards/card_draft.dart';
import 'package:alambic/application/cards/draft_image.dart';
import 'package:alambic/application/reviews/session_item.dart';
import 'package:alambic/data/database/alambic_database.dart';
import 'package:alambic/data/repositories/card_repository.dart';
import 'package:alambic/data/repositories/review_repository.dart';
import 'package:alambic/domain/cards/card_side.dart';
import 'package:alambic/domain/reviews/review_outcome.dart';
import 'package:alambic/features/session/session_card_view.dart';
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
      final flags = await services.groups.create('Flags');
      final cardId = await services.cards.create(
        CardDraft(
          frontText: 'Which country has this flag?',
          backText: 'Peru',
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
    await tester.tap(find.text(l10n.sessionShowAnswer));
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
      final prompt = find.text('Mongolia');
      final before = (
        tester.getRect(prompt),
        tester.widget<Text>(prompt).style,
      );
      await tester.tap(find.text(l10n.sessionShowAnswer));
      await tester.pumpAndSettle();
      expect(find.text('Ulaanbaatar'), findsOneWidget);
      expect((
        tester.getRect(prompt),
        tester.widget<Text>(prompt).style,
      ), before);
      expect(find.text('tomorrow'), findsNWidgets(2));
      await expectLater(
        find.byType(SessionScreen),
        matchesGoldenFile('goldens/session_back$suffix.png'),
      );
    });
  }

  group('reveal', () {
    double answerOpacity(WidgetTester tester) => tester
        .widget<Opacity>(
          find
              .ancestor(
                of: find.text('Ulaanbaatar'),
                matching: find.byType(Opacity),
              )
              .first,
        )
        .opacity;

    testWidgets('fades the answer in over 250 ms with a light haptic tap, '
        'the card in place of the buttons', (tester) async {
      final haptics = <Object?>[];
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'HapticFeedback.vibrate') {
            haptics.add(call.arguments);
          }
          return null;
        },
      );
      await pumpSession(tester);
      final card = tester.getRect(find.byType(SessionCardView));
      expect(find.text('Tap to flip'), findsNothing);
      expect(find.text('Ulaanbaatar'), findsNothing);
      await tester.tap(find.text(l10n.sessionShowAnswer));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(answerOpacity(tester), inExclusiveRange(0, 1));
      expect(find.text(l10n.sessionShowAnswer), findsOneWidget);
      await tester.pumpAndSettle();
      expect(answerOpacity(tester), 1);
      expect(find.text(l10n.sessionShowAnswer), findsNothing);
      expect(tester.getRect(find.byType(SessionCardView)), card);
      expect(haptics, ['HapticFeedbackType.lightImpact']);
    });

    testWidgets('shows the answer at once when the system reduces motion', (
      tester,
    ) async {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      await pumpSession(tester);
      await tester.tap(find.text(l10n.sessionShowAnswer));
      await tester.pump();
      expect(answerOpacity(tester), 1);
      expect(find.text(l10n.sessionShowAnswer), findsNothing);
    });

    testWidgets('a tap on the card reveals too; the next card shows '
        'unrevealed', (tester) async {
      await pumpSession(tester);
      await tester.tap(find.byType(SessionCardView));
      await tester.pumpAndSettle();
      expect(find.text('Ulaanbaatar'), findsOneWidget);
      await tester.runAsync(() async {
        await tester.tap(find.text('Correct'));
        await Future<void>.delayed(const Duration(milliseconds: 100));
      });
      await tester.pumpAndSettle();
      expect(find.text('Peru'), findsOneWidget);
      expect(find.text('Lima'), findsNothing);
      final show = find.ancestor(
        of: find.text(l10n.sessionShowAnswer),
        matching: find.byType(Opacity),
      );
      expect(tester.widget<Opacity>(show).opacity, 1);
    });

    testWidgets('a bonus review shows the answer buttons without effect', (
      tester,
    ) async {
      await tester.runAsync(() async {
        final capitals = await seedSampleData(
          SampleServices(database, FixedClock(sampleNow)),
        );
        final card = (await CardRepository(database).getCardsOfGroup(capitals))
            .first;
        items = [SessionItem(cardId: card.id, askedSide: CardSide.front)];
      });
      await pumpGolden(
        tester,
        SessionScreen(items: items, isBonus: true),
        overrides: screenOverrides(database, sampleNow),
      );
      await tester.tap(find.text(l10n.sessionShowAnswer));
      await tester.pumpAndSettle();
      expect(find.text('Correct'), findsOneWidget);
      expect(find.text('no effect'), findsNothing);
      expect(find.text('tomorrow'), findsNothing);
    });
  });

  group('typed answer', () {
    /// A session on Mongolia, then Peru, in a group with the typed answer.
    Future<void> pumpTyped(WidgetTester tester) async {
      await tester.runAsync(() async {
        final services = SampleServices(database, FixedClock(sampleNow));
        final capitals = await seedSampleData(services);
        await services.groups.setTypedAnswer(capitals, enabled: true);
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
        overrides: screenOverrides(database, sampleNow),
      );
    }

    Future<void> submit(WidgetTester tester, String typed) async {
      await tester.enterText(find.byType(TextField), typed);
      await tester.runAsync(() async {
        await tester.tap(find.byTooltip(l10n.sessionSubmitAnswer));
        await Future<void>.delayed(const Duration(milliseconds: 100));
      });
      await tester.pumpAndSettle();
    }

    Future<List<(ReviewOutcome, bool)>> history(WidgetTester tester) async {
      final records = await tester.runAsync(
        () => ReviewRepository(database).watchHistory(items[0].cardId).first,
      );
      return [for (final record in records!) (record.outcome, record.isBonus)];
    }

    testWidgets('a field takes the place of "Show answer", then the answer '
        'shows with its verdict, recorded at once', (tester) async {
      await pumpTyped(tester);
      expect(find.text(l10n.sessionShowAnswer), findsNothing);
      expect(find.text(l10n.sessionReveal), findsOneWidget);
      await expectLater(
        find.byType(SessionScreen),
        matchesGoldenFile('goldens/session_typed.png'),
      );
      await submit(tester, 'ulaanbatar');
      expect(find.text('Ulaanbaatar'), findsOneWidget);
      expect(find.text('"ulaanbatar" accepted, 1 typo'), findsOneWidget);
      expect(find.textContaining('next reminder'), findsOneWidget);
      expect(find.text('Correct'), findsNothing);
      expect(await history(tester), [(ReviewOutcome.correct, false)]);
      await expectLater(
        find.byType(SessionScreen),
        matchesGoldenFile('goldens/session_typed_verdict.png'),
      );
      await tester.tap(find.text(l10n.sessionNext));
      await tester.pumpAndSettle();
      expect(find.text('Peru'), findsOneWidget);
      expect(find.text('Lima'), findsNothing);
      expect(find.text('2 / 2'), findsOneWidget);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        isEmpty,
      );
    });

    testWidgets('a refused answer counts as Again', (tester) async {
      await pumpTyped(tester);
      await submit(tester, 'Beijing');
      expect(find.text('"Beijing" refused'), findsOneWidget);
      expect(find.textContaining('Counted as missed'), findsOneWidget);
      expect(await history(tester), [(ReviewOutcome.again, false)]);
      await tester.tap(find.text(l10n.sessionNext));
      await tester.pumpAndSettle();
      await submit(tester, 'Lima');
      await tester.tap(find.text(l10n.sessionNext));
      await tester.pumpAndSettle();
      expect(find.text(l10n.sessionFinished), findsOneWidget);
      expect(find.text(l10n.sessionReviewMissed(1)), findsOneWidget);
    });

    testWidgets('"Reveal" shows the answer with "Again" and "Correct", '
        'recording nothing', (tester) async {
      await pumpTyped(tester);
      await tester.tap(find.text(l10n.sessionReveal));
      await tester.pumpAndSettle();
      expect(find.text('Ulaanbaatar'), findsOneWidget);
      expect(find.text('Correct'), findsOneWidget);
      expect(find.text(l10n.reviewAgain), findsOneWidget);
      expect(find.textContaining('accepted'), findsNothing);
      expect(await history(tester), isEmpty);
    });

    testWidgets('a blank answer is not submitted', (tester) async {
      await pumpTyped(tester);
      await submit(tester, '   ');
      expect(find.text('Ulaanbaatar'), findsNothing);
      expect(find.byType(TextField), findsOneWidget);
      expect(await history(tester), isEmpty);
    });
  });

  testWidgets('ends on a summary and reviews the missed card as a bonus', (
    tester,
  ) async {
    await pumpSession(tester);
    await answer(tester, 'Correct');
    await answer(tester, l10n.reviewAgain);
    expect(find.text(l10n.sessionFinished), findsOneWidget);
    await expectLater(
      find.byType(SessionScreen),
      matchesGoldenFile('goldens/session_end.png'),
    );
    await tester.runAsync(() async {
      await tester.tap(find.text(l10n.sessionReviewMissed(1)));
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
    expect(find.text('Ulaanbaatar'), findsOneWidget);
    expect(find.textContaining('back → front'), findsOneWidget);
    await tester.tap(find.text(l10n.sessionShowAnswer));
    await tester.pumpAndSettle();
    expect(find.text('Mongolia'), findsOneWidget);
  });

  testWidgets('"Review all" raises a missed pending card at once, even when '
      'the session is left', (tester) async {
    late int capitals;
    late List<SessionItem> pendingItems;
    await tester.runAsync(() async {
      final services = SampleServices(database, FixedClock(sampleNow));
      capitals = await services.groups.create('Capitals');
      final ids = [
        for (final country in ['Kenya', 'Chile', 'Morocco'])
          await services.card(country, 'capital', groupId: capitals),
      ];
      pendingItems = [
        for (final cardId in ids.reversed)
          SessionItem(cardId: cardId, askedSide: CardSide.front),
      ];
    });
    await pumpGolden(
      tester,
      SessionScreen(items: pendingItems, raisesMissedPending: true),
      overrides: screenOverrides(database, sampleNow),
    );
    await answer(tester, l10n.reviewAgain);
    await tester.tap(find.byTooltip(l10n.sessionQuit));
    await tester.pumpAndSettle();
    final cards = await tester.runAsync(
      () => CardRepository(database).getCardsOfGroup(capitals),
    );
    final queue = cards!
      ..sort(
        (first, second) =>
            first.queuePosition!.compareTo(second.queuePosition!),
      );
    expect(queue.map((card) => card.frontText), ['Morocco', 'Kenya', 'Chile']);
  });
}
