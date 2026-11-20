import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
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
    required String typed,
    required TypedAnswerMatch match,
    CardSchedule? schedule,
  }) => TypedAnswerVerdict(
    key: key,
    askedSide: CardSide.front,
    prompt: 'Peru',
    answer: 'Lima',
    answerImage: null,
    typed: typed,
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

  test('names the group of the asked card, and nothing of its step', () {
    expect(texts.promptDetail(prompt()), 'Capitals');
    expect(
      texts.promptDetail(prompt(askedSide: CardSide.back)),
      'back → front · Capitals',
    );
    expect(
      texts.promptDetail(
        prompt(key: const ReviewNotificationKey(cardId: 7, extraReminderId: 1)),
      ),
      'Review soon · no effect on the schedule · Capitals',
    );
  });

  test('a face that is an image alone is named as such', () {
    expect(texts.promptTitle('Peru'), 'Peru');
    expect(texts.promptTitle(''), 'What does this image show?');
    expect(texts.answerLine('Lima'), 'Answer: Lima');
    expect(texts.answerLine(''), 'Answer in the image');
  });

  test('tells how a typed answer compared, then what it did', () {
    final next = CardSchedule(
      state: CardState.active,
      step: 2,
      dueAt: DateTime(2026, 11, 13, 12),
    );
    expect(
      texts.verdict(
        verdict(
          isBonus: false,
          typed: 'lma',
          match: TypedAnswerMatch.oneTypo,
          schedule: next,
        ),
      ),
      '"lma" accepted, 1 typo · next reminder in 3 d',
    );
    expect(
      texts.verdict(
        verdict(
          isBonus: false,
          typed: 'Lima',
          match: TypedAnswerMatch.exact,
          schedule: CardSchedule.acquired,
        ),
      ),
      '"Lima" accepted · card learned',
    );
    expect(
      texts.verdict(
        verdict(isBonus: false, typed: 'Quito', match: TypedAnswerMatch.wrong),
      ),
      '"Quito" refused · Counted as missed · review tomorrow',
    );
    expect(
      texts.verdict(
        verdict(isBonus: true, typed: 'Lima', match: TypedAnswerMatch.exact),
      ),
      '"Lima" accepted · Bonus review · no effect',
    );
  });

  test('reads in French when the interface is French', () {
    final french = ReviewTexts(
      lookupAppLocalizations(const Locale('fr')),
      const SchedulingCalendar(),
    );
    expect(
      french.verdict(
        verdict(
          isBonus: false,
          typed: 'lma',
          match: TypedAnswerMatch.oneTypo,
          schedule: CardSchedule(
            state: CardState.active,
            step: 2,
            dueAt: DateTime(2026, 11, 13, 12),
          ),
        ),
      ),
      '« lma » accepté, 1 faute · prochain rappel dans 3 j',
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
    const extra = ReviewNotificationKey(cardId: 7, extraReminderId: 3);
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
      texts.promptDetail(
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
