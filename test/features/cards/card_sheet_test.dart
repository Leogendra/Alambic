import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:alambic/data/database/alambic_database.dart';
import 'package:alambic/data/repositories/card_repository.dart';
import 'package:alambic/data/repositories/group_repository.dart';
import 'package:alambic/data/repositories/preset_repository.dart';
import 'package:alambic/domain/cards/card_state.dart';
import 'package:alambic/domain/distillation/distillation_settings.dart';
import 'package:alambic/domain/groups/after_last_step.dart';
import 'package:alambic/domain/presets/failure_behavior.dart';
import 'package:alambic/domain/presets/interval_unit.dart';
import 'package:alambic/domain/presets/preset.dart';
import 'package:alambic/domain/presets/preset_interval.dart';
import 'package:alambic/domain/reviews/review_outcome.dart';
import 'package:alambic/domain/reviews/review_source.dart';
import 'package:alambic/domain/scheduling/card_schedule.dart';
import 'package:alambic/domain/scheduling/step_target.dart';
import 'package:alambic/features/cards/card_sheet_screen.dart';
import 'package:alambic/features/session/session_screen.dart';

import '../../support/fixed_clock.dart';
import '../../support/screen_harness.dart';
import '../../support/sample_data.dart';
import '../../support/test_database.dart';
import '../../support/test_screen.dart';

void main() {
  late AlambicDatabase database;

  setUp(() => database = openTestDatabase());
  tearDown(() => closeTestDatabase(database));

  /// "Peru" answered over three days, the last answers being bonus reviews:
  /// at step 1 (2 d), due on Friday 13 at noon. Returns its id.
  Future<int> seedReviewedCard(WidgetTester tester, DateTime renderAt) async {
    late int cardId;
    await tester.runAsync(() async {
      final clock = FixedClock(sampleNow);
      final samples = SampleServices(database, clock);
      final capitals = await samples.groups.create('Capitals');
      cardId = await samples.card('Peru', 'Lima', groupId: capitals);
      await samples.introduceAll(capitals);
      Future<void> answer(DateTime at, ReviewOutcome outcome) async {
        clock.now = at;
        await samples.reviews.answer(
          cardId,
          outcome,
          source: ReviewSource.notification,
        );
      }

      await answer(DateTime(2026, 11, 10, 12, 2), ReviewOutcome.correct);
      await answer(DateTime(2026, 11, 10, 18), ReviewOutcome.correct);
      await answer(DateTime(2026, 11, 11, 12, 1), ReviewOutcome.correct);
      await answer(DateTime(2026, 11, 12, 8), ReviewOutcome.again);
      clock.now = renderAt;
    });
    return cardId;
  }

  /// A Capitals group of [count] waiting cards; returns their ids, in
  /// queue order. With [distilling], one card a day comes out, the first
  /// one at once.
  Future<List<int>> seedQueue(
    WidgetTester tester, {
    int count = 3,
    bool distilling = false,
  }) async {
    late List<int> ids;
    await tester.runAsync(() async {
      final samples = SampleServices(database, FixedClock(sampleNow));
      final capitals = await samples.groups.create('Capitals');
      ids = [
        for (final country in ['Laos', 'Chile', 'Kenya', 'Peru'].take(count))
          await samples.card(country, 'capital', groupId: capitals),
      ];
      if (distilling) {
        await samples.distillations.activate(
          capitals,
          const DistillationSettings(prioritizeReviews: false),
        );
      }
    });
    return ids;
  }

  Future<void> pumpSheet(
    WidgetTester tester,
    int cardId, {
    DateTime? at,
    Brightness brightness = Brightness.light,
  }) => pumpScreen(
    tester,
    CardSheetScreen(cardId: cardId),
    brightness: brightness,
    overrides: screenOverrides(database, at ?? sampleNow),
  );

  /// Taps [finder] and lets the database answer before settling.
  Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
    await tester.runAsync(() async {
      await tester.tap(finder);
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();
  }

  Future<void> chooseStep(WidgetTester tester, String label) async {
    await tester.tap(find.byIcon(Icons.tune));
    await tester.pumpAndSettle();
    await tapAndSettle(tester, find.text(label));
  }

  for (final (brightness, suffix) in [
    (Brightness.light, ''),
    (Brightness.dark, '_dark'),
  ]) {
    testScreen('card sheet, ${brightness.name} theme', (tester) async {
      final renderAt = DateTime(2026, 11, 12, 9);
      final cardId = await seedReviewedCard(tester, renderAt);
      await pumpScreen(
        tester,
        CardSheetScreen(cardId: cardId),
        brightness: brightness,
        overrides: screenOverrides(database, renderAt),
      );
      expect(find.text('Next review tomorrow'), findsOneWidget);
      expect(find.text('Fri, Nov 13, 12:00'), findsOneWidget);
      // The remanence dot follows the last step of Standard, both 6 months.
      expect(find.text('6\u00A0mo'), findsNWidgets(2));
      expect(find.text('1\u00A0d ago'), findsOneWidget);
      expect(find.text('today'), findsOneWidget);
      expect(find.text('Lima'), findsNothing);
      await captureShot(
        tester,
        find.byType(CardSheetScreen),
        'card_sheet$suffix',
      );
      await tester.tap(find.text('Show the answer'));
      await tester.pumpAndSettle();
      expect(find.text('Lima'), findsOneWidget);
      await captureShot(
        tester,
        find.byType(CardSheetScreen),
        'card_sheet_back$suffix',
      );
      await expectNoOverflow(tester);
    });
  }

  for (final (brightness, suffix) in [
    (Brightness.light, ''),
    (Brightness.dark, '_dark'),
  ]) {
    testScreen('a due card says so, ${brightness.name} theme', (tester) async {
      final renderAt = DateTime(2026, 11, 13, 12, 30);
      final cardId = await seedReviewedCard(tester, renderAt);
      await pumpSheet(tester, cardId, at: renderAt, brightness: brightness);
      expect(find.text('Due now'), findsOneWidget);
      await captureShot(
        tester,
        find.byType(CardSheetScreen),
        'card_sheet_due$suffix',
      );
    });

    testScreen('a learned card says it does not come back, '
        '${brightness.name} theme', (tester) async {
      final ids = await seedQueue(tester, count: 1);
      await tester.runAsync(() async {
        final cards = CardRepository(database);
        final card = await cards.getCard(ids.single);
        await GroupRepository(database)
            .setAfterLastStep(card.groupId, AfterLastStep.acquired);
        await cards.applySchedule(card.id, CardSchedule.acquired);
      });
      await pumpSheet(tester, ids.single, brightness: brightness);
      expect(find.text('Learned'), findsWidgets);
      expect(find.text('This card does not come back.'), findsOneWidget);
      await captureShot(
        tester,
        find.byType(CardSheetScreen),
        'card_sheet_learned$suffix',
      );
    });

    testScreen('a waiting card, ${brightness.name} theme', (tester) async {
      final ids = await seedQueue(tester, count: 4, distilling: true);
      await pumpSheet(tester, ids[2], brightness: brightness);
      expect(find.text('Waiting · 2 of 3'), findsOneWidget);
      await captureShot(
        tester,
        find.byType(CardSheetScreen),
        'card_sheet_pending$suffix',
      );
    });

    testScreen('a card in remanence, ${brightness.name} theme', (tester) async {
      final renderAt = DateTime(2026, 11, 12, 9);
      final cardId = await seedReviewedCard(tester, renderAt);
      await tester.runAsync(
        () => SampleServices(
          database,
          FixedClock(renderAt),
        ).cards.setStep(cardId, const SequenceEndTarget()),
      );
      await pumpSheet(tester, cardId, at: renderAt, brightness: brightness);
      expect(find.text('Next review in 6\u00A0mo'), findsOneWidget);
      await captureShot(
        tester,
        find.byType(CardSheetScreen),
        'card_sheet_remanence$suffix',
      );
    });
  }

  testScreen('a waiting card tells its rank and when it comes out, and '
      'moves in its queue', (tester) async {
    final ids = await seedQueue(tester, count: 4, distilling: true);
    await pumpSheet(tester, ids[2]);
    // Laos came out on activation; Chile comes tomorrow, Kenya after.
    expect(find.text('Waiting · 2 of 3'), findsOneWidget);
    expect(find.text('Comes out around November 12'), findsOneWidget);
    await expectNoOverflow(tester);
    await tapAndSettle(tester, find.text('To the head'));
    expect(find.text('Waiting · 1 of 3'), findsOneWidget);
    expect(find.text('Comes out around November 11'), findsOneWidget);
    await tapAndSettle(tester, find.text('To the end'));
    expect(find.text('Waiting · 3 of 3'), findsOneWidget);
  });

  testScreen('a waiting card of a group that does not distill has no '
      'date', (tester) async {
    final ids = await seedQueue(tester, count: 1);
    await pumpSheet(tester, ids.single);
    expect(find.text('Waiting · 1 of 1'), findsOneWidget);
    expect(
      find.text('The group does not distill: nothing comes out.'),
      findsOneWidget,
    );
    for (final label in ['To the head', 'To the end']) {
      final button = tester.widget<ButtonStyleButton>(
        find.ancestor(
          of: find.text(label),
          matching: find.bySubtype<ButtonStyleButton>(),
        ),
      );
      expect(button.onPressed, isNull, reason: label);
    }
  });

  testScreen('the track opens the steps; a step applies at once and tells '
      'its date', (tester) async {
    final renderAt = DateTime(2026, 11, 12, 9);
    final cardId = await seedReviewedCard(tester, renderAt);
    await pumpSheet(tester, cardId, at: renderAt);
    await tester.tap(find.byIcon(Icons.tune));
    await tester.pumpAndSettle();
    expect(find.text('Change the step'), findsWidgets);
    expect(find.text('Waiting in the queue'), findsOneWidget);
    expect(find.text('Remanence · 6\u00A0mo'), findsOneWidget);
    // Each step gives its date, counted from now.
    expect(find.text('Thu, Nov 19, 12:00'), findsOneWidget);
    await captureShot(tester, find.byType(BottomSheet), 'step_sheet');
    await tapAndSettle(tester, find.text('Remanence · 6\u00A0mo'));
    expect(find.text('Next review Tue, May 11, 12:00'), findsOneWidget);
    expect(find.text('Next review in 6\u00A0mo'), findsOneWidget);
    final card = await tester.runAsync(
      () => CardRepository(database).getCard(cardId),
    );
    expect(card!.state, CardState.completed);
  });

  testScreen('a long preset keeps the intervals of its track apart', (
    tester,
  ) async {
    final ids = await seedQueue(tester, count: 1);
    await tester.runAsync(() async {
      final presetId = await PresetRepository(database).insert(
        Preset(
          id: 0,
          name: 'Long',
          builtInKey: null,
          intervals: [
            for (var days = 1; days <= 10; days++)
              PresetInterval(days, IntervalUnit.day),
          ],
          failureBehavior: FailureBehavior.stepBack,
        ),
      );
      final card = await CardRepository(database).getCard(ids.single);
      await GroupRepository(database).setPreset(card.groupId, presetId);
    });
    await pumpSheet(tester, ids.single);
    await chooseStep(tester, '4\u00A0d');
    // The first, the current and the last step keep their interval.
    for (final label in ['1\u00A0d', '4\u00A0d', '10\u00A0d']) {
      expect(find.text(label), findsOneWidget, reason: label);
    }
    expect(find.text('2\u00A0d'), findsNothing);
    await captureShot(tester, find.byType(CardSheetScreen), 'card_sheet_long');
    await expectNoOverflow(tester);
  });

  testScreen('back to the queue after a confirmation', (tester) async {
    final renderAt = DateTime(2026, 11, 12, 9);
    final cardId = await seedReviewedCard(tester, renderAt);
    await pumpSheet(tester, cardId, at: renderAt);
    await chooseStep(tester, 'Waiting in the queue');
    expect(find.text('Put the card back in the queue?'), findsOneWidget);
    await tapAndSettle(tester, find.text('Put back'));
    final card = await tester.runAsync(
      () => CardRepository(database).getCard(cardId),
    );
    expect(card!.isPending, isTrue);
    expect(find.text('Waiting · 1 of 1'), findsOneWidget);
  });

  testScreen('a waiting card is not offered the queue, and comes out at the '
      'step chosen', (tester) async {
    final ids = await seedQueue(tester, count: 1);
    await pumpSheet(tester, ids.single);
    await tester.tap(find.byIcon(Icons.tune));
    await tester.pumpAndSettle();
    expect(find.text('Waiting in the queue'), findsNothing);
    await tapAndSettle(
      tester,
      find.descendant(
        of: find.byType(BottomSheet),
        matching: find.text('1\u00A0wk'),
      ),
    );
    expect(find.text('Next review in 7\u00A0d'), findsOneWidget);
  });

  testScreen('"Review now" opens a session on a waiting card, which stays '
      'in its place', (tester) async {
    final ids = await seedQueue(tester);
    await pumpSheet(tester, ids[1]);
    await tapAndSettle(tester, find.text('Review now'));
    expect(find.byType(SessionScreen), findsOneWidget);
    await tester.tap(find.text('Show the answer'));
    await tester.pumpAndSettle();
    await tapAndSettle(tester, find.text('Again'));
    final card = await tester.runAsync(
      () => CardRepository(database).getCard(ids[1]),
    );
    expect(card!.isPending, isTrue);
    expect(card.queuePosition, 1);
  });
}
