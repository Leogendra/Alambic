import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/application/notifications/group_reminder.dart';
import 'package:alambic/application/notifications/group_reminder_key.dart';
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
    lookupAppLocalizations(const Locale('fr')),
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
    prompt: 'Pérou',
    image: null,
    answer: 'Lima',
    answerImage: null,
    groupName: 'Capitales',
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
    prompt: 'Pérou',
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
    expect(texts.promptDetail(prompt()), 'Capitales');
    expect(
      texts.promptDetail(prompt(askedSide: CardSide.back)),
      'verso → recto · Capitales',
    );
    expect(
      texts.promptDetail(
        prompt(key: const ReviewNotificationKey(cardId: 7, extraReminderId: 1)),
      ),
      'Réviser bientôt · sans effet sur le planning · Capitales',
    );
  });

  test('a face that is an image alone is named as such', () {
    expect(texts.promptTitle('Pérou'), 'Pérou');
    expect(texts.promptTitle(''), 'Que montre cette image ?');
    expect(texts.answerLine('Lima'), 'Réponse : Lima');
    expect(texts.answerLine(''), 'Réponse en image');
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
      '« lma » accepté, 1 faute · prochain rappel dans 3 j',
    );
    expect(
      texts.verdict(
        verdict(
          isBonus: false,
          typed: 'Lima',
          match: TypedAnswerMatch.exact,
          schedule: const CardSchedule(
            state: CardState.acquired,
            step: null,
            dueAt: null,
          ),
        ),
      ),
      '« Lima » accepté · carte acquise',
    );
    expect(
      texts.verdict(
        verdict(isBonus: false, typed: 'Quito', match: TypedAnswerMatch.wrong),
      ),
      '« Quito » refusé · Compté raté · revue demain',
    );
    expect(
      texts.verdict(
        verdict(isBonus: true, typed: 'Lima', match: TypedAnswerMatch.exact),
      ),
      '« Lima » accepté · Révision bonus · sans effet',
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

  test('the payload of a grouped reminder leads to its group', () {
    const capitals = GroupReminderKey(4);
    const spanish = GroupReminderKey(5);
    final summary = NotificationPayload.encodeGroup(
      const GroupReminder(
        key: spanish,
        groupName: 'Espagnol',
        count: 5,
        chain: true,
        alert: true,
      ),
    );
    expect(NotificationPayload.decodeGroup(summary), spanish);
    expect(NotificationPayload.decodeGroupCount(summary), 5);
    expect(NotificationPayload.decode(summary), isNull);
    expect(NotificationPayload.target(summary)!.groupId, 5);
    const chained = ReviewNotificationKey(cardId: 7, chain: capitals);
    final card = NotificationPayload.encode(
      chained,
      isPrompt: true,
      askedSide: CardSide.front,
    );
    expect(NotificationPayload.decodePrompt(card), chained);
    expect(NotificationPayload.decodeGroup(card), isNull);
    expect(NotificationPayload.target(card)!.groupId, 4);
    expect(
      NotificationPayload.target(
        NotificationPayload.encode(
          key,
          isPrompt: true,
          askedSide: CardSide.front,
        ),
      ),
      isNull,
    );
  });

  test('a grouped reminder tells its count and the cards left', () {
    const reminder = GroupReminder(
      key: GroupReminderKey(4),
      groupName: 'Capitales',
      count: 5,
      chain: false,
      alert: true,
    );
    expect(
      texts.groupReminderTitle(reminder),
      'Capitales : 5 cartes à réviser',
    );
    expect(texts.groupReminderDetail(reminder), 'Environ 3 min');
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
      'Capitales · 3 à réviser',
    );
  });
}
