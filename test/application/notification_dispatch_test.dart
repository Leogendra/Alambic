import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/application/notifications/notification_action.dart';
import 'package:alambic/application/notifications/notification_providers.dart';
import 'package:alambic/application/notifications/review_notification_key.dart';
import 'package:alambic/application/reviews/review_providers.dart';
import 'package:alambic/data/database/alambic_database.dart';
import 'package:alambic/data/repositories/card_repository.dart';
import 'package:alambic/data/repositories/group_repository.dart';
import 'package:alambic/data/repositories/notification_settings_repository.dart';
import 'package:alambic/data/repositories/review_repository.dart';
import 'package:alambic/domain/cards/card_side.dart';
import 'package:alambic/domain/notifications/notification_guards.dart';
import 'package:alambic/domain/notifications/schedule_kind.dart';
import 'package:alambic/domain/reviews/review_outcome.dart';
import 'package:alambic/domain/reviews/review_record.dart';
import 'package:alambic/domain/reviews/review_source.dart';
import 'package:alambic/domain/reviews/typed_answer_match.dart';
import 'package:alambic/domain/scheduling/clock_time.dart';

import '../support/fake_notifications.dart';
import '../support/fixed_clock.dart';
import '../support/fixed_random.dart';
import '../support/sample_data.dart';
import '../support/test_database.dart';

void main() {
  late AlambicDatabase database;
  late NotificationHarness harness;
  late int capitals;

  setUp(() async {
    database = openTestDatabase();
    // Groups with the back enabled always ask it.
    harness = NotificationHarness(
      database,
      FixedClock(sampleNow),
      random: FixedRandom(),
    );
    capitals = await seedSampleData(SampleServices(database, harness.clock));
    // The seven cards due at noon are notified one by one.
    await NotificationSettingsRepository(
      database,
    ).saveGuards(NotificationGuards.defaults.copyWith(autoGroupEnabled: false));
  });

  tearDown(() async {
    harness.dispose();
    await database.close();
  });

  Future<int> mongoliaId() async =>
      (await CardRepository(database).getCardsOfGroup(capitals)).first.id;

  Future<void> dispatchAt(DateTime now) async {
    harness.clock.now = now;
    await harness.read(notificationDispatcherProvider).dispatchDue();
  }

  group('at the slot', () {
    test('shows each due card once, with its group', () async {
      await dispatchAt(DateTime(2026, 11, 10, 12));
      final prompts = harness.presenter.prompts.values;
      expect(prompts, hasLength(7));
      final mongolia = harness
          .presenter
          .prompts[ReviewNotificationKey(cardId: await mongoliaId())]!;
      expect(mongolia.prompt, 'Mongolia');
      expect(mongolia.groupName, 'Capitals');
      expect(mongolia.image, isNull);
      harness.presenter.prompts.clear();
      await dispatchAt(DateTime(2026, 11, 10, 12, 1));
      expect(harness.presenter.prompts, isEmpty);
    });

    test('shows a late notification however late, once', () async {
      // The phone was off from 11:00 to 21:30.
      await dispatchAt(DateTime(2026, 11, 10, 21, 30));
      expect(harness.presenter.prompts, hasLength(7));
      harness.presenter.prompts.clear();
      await dispatchAt(DateTime(2026, 11, 10, 21, 31));
      expect(harness.presenter.prompts, isEmpty);
    });

    test('holds a late notification during the quiet hours', () async {
      await dispatchAt(DateTime(2026, 11, 10, 23));
      expect(harness.presenter.prompts, isEmpty);
      expect(
        harness.alarms.scheduled.values,
        contains(DateTime(2026, 11, 11, 8)),
      );
      // Its day is over: it comes back at the slot, like an ignored card.
      await dispatchAt(DateTime(2026, 11, 11, 12));
      expect(
        harness.presenter.prompts.keys,
        contains(ReviewNotificationKey(cardId: await mongoliaId())),
      );
    });

    test('notifies an ignored card again the next day, at the slot', () async {
      await dispatchAt(DateTime(2026, 11, 10, 12));
      final mongolia = ReviewNotificationKey(cardId: await mongoliaId());
      expect(harness.presenter.prompts.keys, contains(mongolia));
      harness.presenter.prompts.clear();
      await dispatchAt(DateTime(2026, 11, 10, 18));
      expect(harness.presenter.prompts, isEmpty);
      expect(
        harness.alarms.scheduled.values,
        contains(DateTime(2026, 11, 11, 12)),
      );
      await dispatchAt(DateTime(2026, 11, 11, 12));
      expect(harness.presenter.prompts.keys, contains(mongolia));
      harness.presenter.prompts.clear();
      await dispatchAt(DateTime(2026, 11, 11, 12, 30));
      expect(harness.presenter.prompts.keys, isNot(contains(mongolia)));
    });
  });

  group('answering from the notification', () {
    late ReviewNotificationKey key;

    setUp(() async {
      key = ReviewNotificationKey(cardId: await mongoliaId());
      await dispatchAt(DateTime(2026, 11, 10, 12));
    });

    Future<void> press(NotificationAction action) =>
        harness.read(notificationActionHandlerProvider).handle(key, action);

    Future<List<ReviewRecord>> history() =>
        ReviewRepository(database).watchHistory(key.cardId).first;

    test('"Correct" records the answer and replaces the notification with '
        'its next review', () async {
      await press(NotificationAction.correct);
      final record = (await history()).single;
      expect(record.source, ReviewSource.notification);
      expect(record.outcome, ReviewOutcome.correct);
      expect(record.isBonus, isFalse);
      expect(harness.presenter.prompts.containsKey(key), isFalse);
      expect(harness.presenter.verdicts, isEmpty);
      final confirmation = harness.presenter.confirmations[key]!;
      expect(confirmation.outcome, ReviewOutcome.correct);
      expect(confirmation.schedule.dueAt, record.dueAtAfter);
      expect(
        confirmation.answer,
        'Ulaanbaatar',
        reason: 'the answer is shown even when "Reveal" was not pressed',
      );
      expect(confirmation.groupName, 'Capitals');
      expect(
        await harness.presenter.shownPrompts(),
        isNot(contains(key)),
        reason: 'the planner leaves the confirmation alone',
      );
    });

    test('"Again" records the failure and replaces the notification with '
        'its next review', () async {
      await press(NotificationAction.again);
      expect((await history()).single.outcome, ReviewOutcome.again);
      final card = await CardRepository(database).getCard(key.cardId);
      expect(card.dueAt, DateTime(2026, 11, 11, 12));
      expect(harness.presenter.prompts.containsKey(key), isFalse);
      expect(harness.presenter.verdicts, isEmpty);
      final confirmation = harness.presenter.confirmations[key]!;
      expect(confirmation.outcome, ReviewOutcome.again);
      expect(confirmation.schedule.dueAt, DateTime(2026, 11, 11, 12));
      expect(confirmation.answer, 'Ulaanbaatar');
    });

    test('"Reveal" shows the answer in place and records nothing', () async {
      await press(NotificationAction.reveal);
      final revealed = harness.presenter.prompts[key]!;
      expect(revealed.isRevealed, isTrue);
      expect(revealed.alert, isFalse);
      expect(revealed.prompt, 'Mongolia');
      expect(revealed.answer, 'Ulaanbaatar');
      expect(revealed.groupName, 'Capitals');
      expect(await history(), isEmpty);
      // Still on screen, the revealed card is withdrawn like any other once
      // answered in the app.
      expect(await harness.presenter.shownPrompts(), contains(key));
    });

    test('"Hide" asks the card again in place and records nothing', () async {
      await press(NotificationAction.reveal);
      await press(NotificationAction.hide);
      final hidden = harness.presenter.prompts[key]!;
      expect(hidden.isRevealed, isFalse);
      expect(hidden.alert, isFalse, reason: 'it changes in place, silently');
      expect(hidden.prompt, 'Mongolia');
      expect(await history(), isEmpty);
    });

    test('a revealed card is answered with "Correct" or "Again"', () async {
      await press(NotificationAction.reveal);
      await press(NotificationAction.again);
      expect((await history()).single.outcome, ReviewOutcome.again);
      expect(harness.presenter.prompts.containsKey(key), isFalse);
      expect(harness.presenter.verdicts, isEmpty);
      expect(harness.presenter.confirmations[key]!.answer, 'Ulaanbaatar');
    });

    test('a card deleted meanwhile only closes the notification', () async {
      await CardRepository(database).deleteCard(key.cardId);
      await press(NotificationAction.correct);
      expect(harness.presenter.prompts.containsKey(key), isFalse);
      expect(harness.presenter.confirmations, isEmpty);
    });
  });

  group('typed answer', () {
    late ReviewNotificationKey key;

    setUp(() async {
      await GroupRepository(database).setTypedAnswer(capitals, enabled: true);
      key = ReviewNotificationKey(cardId: await mongoliaId());
      await dispatchAt(DateTime(2026, 11, 10, 12));
    });

    test('asks for an answer when the answer face has text', () {
      expect(harness.presenter.prompts[key]!.typedAnswer, isTrue);
    });

    test('is read on the group: the other groups keep "Correct"', () {
      final prompts = harness.presenter.prompts.values;
      expect(
        {
          for (final prompt in prompts.where((p) => p.typedAnswer))
            prompt.groupName,
        },
        {'Capitals'},
      );
      expect(prompts.where((prompt) => !prompt.typedAnswer), isNotEmpty);
    });

    test('an answer with one typo counts as correct', () async {
      await harness
          .read(notificationActionHandlerProvider)
          .handle(key, NotificationAction.answer, input: 'ulaanbatar');
      final verdict = harness.presenter.verdicts[key]!;
      expect(verdict.match, TypedAnswerMatch.oneTypo);
      expect(
        verdict.answer,
        'Ulaanbaatar',
        reason: 'the expected answer is shown when accepted too',
      );
      expect(verdict.groupName, 'Capitals');
      final history = await ReviewRepository(database)
          .watchHistory(key.cardId)
          .first;
      expect(history.single.outcome, ReviewOutcome.correct);
      expect(verdict.result.schedule!.dueAt, DateTime(2026, 11, 11, 12));
    });

    test('a wrong answer counts as a failure', () async {
      await harness
          .read(notificationActionHandlerProvider)
          .handle(key, NotificationAction.answer, input: 'Beijing');
      final verdict = harness.presenter.verdicts[key]!;
      expect(verdict.match, TypedAnswerMatch.wrong);
      expect(verdict.answer, 'Ulaanbaatar');
      final history = await ReviewRepository(database)
          .watchHistory(key.cardId)
          .first;
      expect(history.single.outcome, ReviewOutcome.again);
    });

    test('"Again" closes the notification without a verdict', () async {
      await harness
          .read(notificationActionHandlerProvider)
          .handle(key, NotificationAction.again);
      expect(harness.presenter.prompts.containsKey(key), isFalse);
      expect(harness.presenter.verdicts, isEmpty);
    });

    test('"Hide" asks for a typed answer again', () async {
      final handler = harness.read(notificationActionHandlerProvider);
      await handler.handle(key, NotificationAction.reveal);
      await handler.handle(key, NotificationAction.hide);
      final hidden = harness.presenter.prompts[key]!;
      expect(hidden.isRevealed, isFalse);
      expect(hidden.typedAnswer, isTrue);
    });

    test('"Reveal" shows the answer, to answer with "Correct"', () async {
      await harness
          .read(notificationActionHandlerProvider)
          .handle(key, NotificationAction.reveal);
      expect(harness.presenter.prompts[key]!.isRevealed, isTrue);
      await harness
          .read(notificationActionHandlerProvider)
          .handle(key, NotificationAction.correct);
      final history = await ReviewRepository(database)
          .watchHistory(key.cardId)
          .first;
      expect(history.single.outcome, ReviewOutcome.correct);
      expect(harness.presenter.verdicts, isEmpty);
    });
  });

  group('with the back enabled on the group', () {
    late ReviewNotificationKey key;

    setUp(() async {
      await GroupRepository(database)
          .setReverseEnabled(capitals, enabled: true);
      key = ReviewNotificationKey(cardId: await mongoliaId());
    });

    test('asks the drawn face and reveals the other one', () async {
      await dispatchAt(DateTime(2026, 11, 10, 12));
      final prompt = harness.presenter.prompts[key]!;
      expect(prompt.askedSide, CardSide.back);
      expect(prompt.prompt, 'Ulaanbaatar');
      await harness
          .read(notificationActionHandlerProvider)
          .handle(key, NotificationAction.reveal, askedSide: CardSide.back);
      final revealed = harness.presenter.prompts[key]!;
      expect(revealed.answer, 'Mongolia');
      expect(revealed.askedSide, CardSide.back);
    });

    test('a typed answer is compared with the front', () async {
      await GroupRepository(database).setTypedAnswer(capitals, enabled: true);
      await dispatchAt(DateTime(2026, 11, 10, 12));
      expect(harness.presenter.prompts[key]!.typedAnswer, isTrue);
      await harness
          .read(notificationActionHandlerProvider)
          .handle(
            key,
            NotificationAction.answer,
            input: 'mongolia',
            askedSide: CardSide.back,
          );
      expect(harness.presenter.verdicts[key]!.match, TypedAnswerMatch.exact);
    });

    test('the draw changes nothing to the progression', () async {
      await dispatchAt(DateTime(2026, 11, 10, 12));
      await harness
          .read(notificationActionHandlerProvider)
          .handle(key, NotificationAction.correct, askedSide: CardSide.back);
      final card = await CardRepository(database).getCard(key.cardId);
      expect(card.step, 0);
      expect(card.dueAt, DateTime(2026, 11, 11, 12));
    });
  });

  test('spreads the cards of a time range over the range', () async {
    final services = SampleServices(database, harness.clock);
    // The cards of the sample, due at 12:00, stay outside the range start.
    final settings = NotificationSettingsRepository(database);
    await settings.saveReminderSettings(
      (await settings.loadReminderSettings()).copyWith(
        scheduleKind: ScheduleKind.timeRange,
        rangeStart: const ClockTime(9, 0),
        rangeEnd: const ClockTime(17, 0),
      ),
    );
    final verbs = await services.groups.create('Verbs');
    for (final verb in ['be', 'have', 'go', 'do']) {
      await services.card(verb, verb, groupId: verbs);
    }
    harness.clock.now = DateTime(2026, 11, 10, 8);
    await services.introduceAll(verbs);
    await harness.read(notificationPlannerProvider).replan();
    expect(
      harness.alarms.scheduled.values.where(
        (wakeUp) => wakeUp.day == 10 && wakeUp.hour < 17,
      ),
      containsAll([
        DateTime(2026, 11, 10, 9),
        DateTime(2026, 11, 10, 11),
        DateTime(2026, 11, 10, 13),
        DateTime(2026, 11, 10, 15),
      ]),
    );
    await dispatchAt(DateTime(2026, 11, 10, 9));
    await dispatchAt(DateTime(2026, 11, 10, 11));
    expect(
      harness.presenter.prompts.values
          .where((prompt) => prompt.groupName == 'Verbs')
          .map((prompt) => prompt.prompt),
      ['be', 'have'],
    );
  });

  group('safeguards', () {
    Future<void> setGuards(NotificationGuards guards) =>
        NotificationSettingsRepository(database).saveGuards(guards);

    test(
      'gathers the notifications of a moment beyond the threshold',
      () async {
        await setGuards(NotificationGuards.defaults);
        await dispatchAt(DateTime(2026, 11, 10, 12));
        expect(harness.presenter.prompts, isEmpty);
        final digest = harness.presenter.digest!;
        expect(digest.count, 7);
        expect(digest.groupNames, ['Capitals', 'Spanish', 'Biology']);
        // Answered in the app, the cards leave the digest.
        await harness
            .read(reviewServiceProvider)
            .answer(
              await mongoliaId(),
              ReviewOutcome.correct,
              source: ReviewSource.session,
            );
        expect(harness.presenter.digest!.count, 6);
        expect(harness.presenter.digest!.alert, isFalse);
      },
    );

    test('moves a notification out of the quiet hours', () async {
      await setGuards(
        NotificationGuards.defaults.copyWith(
          quietStart: const ClockTime(11, 0),
          quietEnd: const ClockTime(13, 0),
          autoGroupEnabled: false,
        ),
      );
      await dispatchAt(DateTime(2026, 11, 10, 12));
      expect(harness.presenter.prompts, isEmpty);
      await dispatchAt(DateTime(2026, 11, 10, 13));
      expect(harness.presenter.prompts, hasLength(7));
    });
  });

  group('the test notification of the onboarding', () {
    Future<void> press(NotificationAction action) =>
        harness.read(notificationActionHandlerProvider).handleTest(action);

    Future<int> reviewCount() async =>
        (await database.select(database.reviewRecords).get()).length;

    test('"Reveal" and "Hide" show and hide its answer, silently', () async {
      await harness.presenter.showTestPrompt();
      await press(NotificationAction.reveal);
      expect(harness.presenter.testPrompt, (isRevealed: true, alert: false));
      await press(NotificationAction.hide);
      expect(harness.presenter.testPrompt, (isRevealed: false, alert: false));
    });

    test('"Correct" and "Again" show what they would do, and record '
        'nothing', () async {
      final before = await reviewCount();
      await press(NotificationAction.correct);
      final correct = harness.presenter.testConfirmation!;
      expect(correct.outcome, ReviewOutcome.correct);
      expect(correct.dueAt.difference(correct.answeredAt).inDays, 2);
      expect(harness.presenter.testPrompt, isNull);
      await harness.presenter.showTestPrompt();
      await press(NotificationAction.again);
      final again = harness.presenter.testConfirmation!;
      expect(again.outcome, ReviewOutcome.again);
      expect(again.dueAt.difference(again.answeredAt).inDays, 1);
      expect(await reviewCount(), before);
    });
  });
}
