import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/application/notifications/answer_confirmation.dart';
import 'package:alambic/application/notifications/group_reminder.dart';
import 'package:alambic/application/notifications/group_reminder_key.dart';
import 'package:alambic/application/notifications/notification_digest.dart';
import 'package:alambic/application/notifications/notification_target.dart';
import 'package:alambic/application/notifications/review_notification_key.dart';
import 'package:alambic/application/notifications/review_prompt.dart';
import 'package:alambic/application/notifications/typed_answer_verdict.dart';
import 'package:alambic/application/reviews/review_result.dart';
import 'package:alambic/domain/cards/card_side.dart';
import 'package:alambic/domain/cards/card_state.dart';
import 'package:alambic/domain/reviews/review_outcome.dart';
import 'package:alambic/domain/reviews/typed_answer_match.dart';
import 'package:alambic/domain/scheduling/card_schedule.dart';
import 'package:alambic/domain/scheduling/scheduling_calendar.dart';
import 'package:alambic/l10n/generated/app_localizations.dart';
import 'package:alambic/notifications/android/notification_payload.dart';
import 'package:alambic/notifications/review_texts.dart';

void main() {
  final texts = ReviewTexts(
    lookupAppLocalizations(const Locale('en')),
    const SchedulingCalendar(),
  );
  const key = ReviewNotificationKey(cardId: 7);

  ReviewPrompt prompt({
    ReviewNotificationKey key = key,
    CardSide askedSide = CardSide.front,
    int? chainRemaining,
  }) => ReviewPrompt(
    key: key,
    askedSide: askedSide,
    prompt: 'Peru',
    image: null,
    answer: 'Lima',
    answerImage: null,
    groupName: 'Capitals',
    typedAnswer: false,
    chainRemaining: chainRemaining,
  );

  TypedAnswerVerdict verdict({
    required bool isBonus,
    required TypedAnswerMatch match,
    CardSchedule? schedule,
  }) => TypedAnswerVerdict(
    key: key,
    groupName: 'Capitals',
    answer: 'Lima',
    answerImage: null,
    match: match,
    result: ReviewResult(
      isBonus: isBonus,
      schedule: isBonus
          ? null
          : schedule ??
                CardSchedule(
                  state: CardState.active,
                  step: 0,
                  dueAt: DateTime(2026, 11, 11, 12),
                ),
    ),
    answeredAt: DateTime(2026, 11, 10, 12, 5),
  );

  test('names the group of the asked card in the header, and nothing else', () {
    expect(texts.promptHeader(prompt()), 'Capitals');
    expect(
      texts.promptHeader(prompt(askedSide: CardSide.back)),
      'Capitals',
      reason: 'the asked side is not named',
    );
  });

  test('the test notification asks the capital of Peru, of the sample '
      'group', () {
    expect(texts.testGroupName, 'Capitals');
    expect(texts.testQuestion, 'What is the capital of Peru?');
    expect(texts.testAnswer, 'Lima');
    expect(
      texts.answered(
        ReviewOutcome.correct,
        dueAt: DateTime(2026, 11, 12, 12),
        answeredAt: DateTime(2026, 11, 10, 12),
      ),
      'Correct, next in 2\u00a0d',
    );
  });

  test('after an answer, tells the answer and when the card comes back', () {
    AnswerConfirmation confirmation(
      DateTime? dueAt, {
      ReviewOutcome outcome = ReviewOutcome.correct,
    }) => AnswerConfirmation(
      key: key,
      outcome: outcome,
      schedule: CardSchedule(
        state: dueAt == null ? CardState.completed : CardState.active,
        step: dueAt == null ? null : 2,
        dueAt: dueAt,
      ),
      answeredAt: DateTime(2026, 11, 10, 12, 5),
      groupName: 'Capitals',
      answer: 'Lima',
      answerImage: null,
    );
    expect(
      texts.confirmation(confirmation(DateTime(2026, 11, 13, 12))),
      'Correct, next in 3\u00a0d',
    );
    expect(
      texts.confirmation(
        confirmation(DateTime(2026, 11, 11, 12), outcome: ReviewOutcome.again),
      ),
      'To review, next in 1\u00a0d',
    );
    expect(
      texts.confirmation(
        confirmation(
          DateTime(2026, 11, 10, 12, 15),
          outcome: ReviewOutcome.again,
        ),
      ),
      'To review, next in 10\u00a0min',
    );
    expect(
      texts.confirmation(confirmation(DateTime(2026, 11, 10, 14, 35))),
      'Correct, next in 3\u00a0h',
    );
    expect(texts.confirmation(confirmation(null)), 'Correct, card learned');
  });

  test('counts the delay in scheduling days, past midnight included', () {
    expect(
      texts.answered(
        ReviewOutcome.again,
        dueAt: DateTime(2026, 11, 11, 0, 20),
        answeredAt: DateTime(2026, 11, 10, 23, 50),
      ),
      'To review, next in 30\u00a0min',
    );
  });

  test('a typed answer tells whether it was accepted, then what it did, '
      'with the expected answer when refused', () {
    final next = CardSchedule(
      state: CardState.active,
      step: 2,
      dueAt: DateTime(2026, 11, 13, 12),
    );
    expect(
      texts.verdict(
        verdict(
          isBonus: false,
          match: TypedAnswerMatch.oneTypo,
          schedule: next,
        ),
      ),
      'Correct, next in 3\u00a0d',
    );
    expect(
      texts.verdict(
        verdict(
          isBonus: false,
          match: TypedAnswerMatch.exact,
          schedule: CardSchedule.acquired,
        ),
      ),
      'Correct, card learned',
    );
    expect(
      texts.verdict(verdict(isBonus: false, match: TypedAnswerMatch.wrong)),
      'To review (Lima), next in 1\u00a0d',
    );
    expect(
      texts.verdict(verdict(isBonus: true, match: TypedAnswerMatch.exact)),
      'Correct',
    );
  });

  test('reads in French when the interface is French', () {
    final french = ReviewTexts(
      lookupAppLocalizations(const Locale('fr')),
      const SchedulingCalendar(),
    );
    expect(
      french.verdict(verdict(isBonus: false, match: TypedAnswerMatch.wrong)),
      'À\u00a0revoir (Lima), prochaine dans 1\u00a0j',
    );
    expect(
      french.groupReminderTitle(
        const GroupReminder(
          key: GroupReminderKey(4),
          groupName: 'Capitals',
          count: 5,
          chain: false,
          alert: true,
        ),
      ),
      'Capitals : 5 cartes à réviser',
    );
  });

  test('the payload carries the key, and tells prompts from answers', () {
    const extra = ReviewNotificationKey(cardId: 7);
    final prompt = NotificationPayload.encode(
      extra,
      isPrompt: true,
      askedSide: CardSide.front,
    );
    final answer = NotificationPayload.encode(
      extra,
      isPrompt: false,
      askedSide: CardSide.front,
    );
    expect(NotificationPayload.decode(prompt), extra);
    expect(NotificationPayload.decodePrompt(prompt), extra);
    expect(NotificationPayload.decode(answer), extra);
    expect(NotificationPayload.decodePrompt(answer), isNull);
    expect(NotificationPayload.decode('not json'), isNull);
    expect(NotificationPayload.decode(null), isNull);
  });

  test('the payload carries the asked face, the front by default', () {
    final back = NotificationPayload.encode(
      key,
      isPrompt: true,
      askedSide: CardSide.back,
    );
    expect(NotificationPayload.askedSide(back), CardSide.back);
    expect(NotificationPayload.askedSide('{"card": 7}'), CardSide.front);
  });

  test('the payload of the test notification is told apart, and opens no '
      'session', () {
    final test = NotificationPayload.encodeTest();
    expect(NotificationPayload.isTest(test), isTrue);
    expect(NotificationPayload.decode(test), isNull);
    expect(NotificationPayload.decodeGroup(test), isNull);
    expect(NotificationPayload.target(test), isNull);
    expect(
      NotificationPayload.isTest(
        NotificationPayload.encodeDigest(
          const NotificationDigest(count: 2, groupNames: [], alert: true),
        ),
      ),
      isFalse,
    );
  });

  test('the payload of a grouped reminder carries its group and count', () {
    final summary = NotificationPayload.encodeGroup(
      const GroupReminder(
        key: GroupReminderKey(5),
        groupName: 'Spanish',
        count: 5,
        chain: true,
        alert: true,
      ),
    );
    expect(NotificationPayload.decodeGroup(summary), const GroupReminderKey(5));
    expect(NotificationPayload.decodeGroupCount(summary), 5);
    expect(NotificationPayload.decode(summary), isNull);
    const chained = ReviewNotificationKey(
      cardId: 7,
      chain: GroupReminderKey(4),
    );
    final card = NotificationPayload.encode(
      chained,
      isPrompt: true,
      askedSide: CardSide.front,
    );
    expect(NotificationPayload.decodePrompt(card), chained);
    expect(NotificationPayload.decodeGroup(card), isNull);
  });

  group('a touched notification opens a session on', () {
    NotificationTarget? targetOf(
      ReviewNotificationKey key, {
      bool isPrompt = true,
    }) => NotificationPayload.target(
      NotificationPayload.encode(
        key,
        isPrompt: isPrompt,
        askedSide: CardSide.back,
      ),
    );

    test('its card, asking the same face', () {
      final target = targetOf(key)!;
      expect(target.cardId, 7);
      expect(target.askedSide, CardSide.back);
      expect(target.groupId, isNull);
    });

    test('its card then its group, chained in a grouped reminder', () {
      final target = targetOf(
        const ReviewNotificationKey(cardId: 7, chain: GroupReminderKey(4)),
      )!;
      expect(target.cardId, 7);
      expect(target.groupId, 4);
    });

    test('its group, for a grouped reminder', () {
      final target = NotificationPayload.target(
        NotificationPayload.encodeGroup(
          const GroupReminder(
            key: GroupReminderKey(4),
            groupName: 'Capitals',
            count: 5,
            chain: false,
            alert: true,
          ),
        ),
      )!;
      expect(target.cardId, isNull);
      expect(target.groupId, 4);
    });

    test('every due card, for the digest or an answered card', () {
      for (final target in [
        NotificationPayload.target(
          NotificationPayload.encodeDigest(
            const NotificationDigest(count: 12, groupNames: [], alert: true),
          ),
        ),
        targetOf(key, isPrompt: false),
      ]) {
        expect(target!.cardId, isNull);
        expect(target.groupId, isNull);
      }
    });

    test('nothing, for a payload of another app', () {
      expect(NotificationPayload.target('not json'), isNull);
      expect(NotificationPayload.target('{"other": 1}'), isNull);
    });
  });

  test('a grouped reminder tells its count and the cards left', () {
    const reminder = GroupReminder(
      key: GroupReminderKey(4),
      groupName: 'Capitals',
      count: 5,
      chain: false,
      alert: true,
    );
    expect(texts.groupReminderTitle(reminder), 'Capitals: 5 cards to review');
    expect(texts.groupReminderDetail(reminder), 'About 3 min');
    expect(
      texts.promptHeader(
        prompt(
          key: const ReviewNotificationKey(
            cardId: 7,
            chain: GroupReminderKey(4),
          ),
          chainRemaining: 3,
        ),
      ),
      'Capitals · 3 to review',
    );
  });
}
