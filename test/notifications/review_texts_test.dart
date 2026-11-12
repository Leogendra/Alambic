import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/application/notifications/answer_reveal.dart';
import 'package:alambic/application/notifications/group_reminder.dart';
import 'package:alambic/application/notifications/group_reminder_key.dart';
import 'package:alambic/application/notifications/review_notification_key.dart';
import 'package:alambic/application/notifications/review_prompt.dart';
import 'package:alambic/application/reviews/review_result.dart';
import 'package:alambic/domain/cards/direction_state.dart';
import 'package:alambic/domain/presets/built_in_presets.dart';
import 'package:alambic/domain/reviews/typed_answer_match.dart';
import 'package:alambic/domain/scheduling/direction_schedule.dart';
import 'package:alambic/domain/scheduling/scheduling_calendar.dart';
import 'package:alambic/l10n/generated/app_localizations.dart';
import 'package:alambic/notifications/android/notification_payload.dart';
import 'package:alambic/notifications/review_texts.dart';

void main() {
  final texts = ReviewTexts(
    lookupAppLocalizations(const Locale('fr')),
    const SchedulingCalendar(),
  );
  const key = ReviewNotificationKey(directionId: 7);

  ReviewPrompt prompt({
    ReviewNotificationKey key = key,
    int? step = 1,
    bool isReverse = false,
  }) => ReviewPrompt(
    key: key,
    prompt: 'Pérou',
    groupName: null,
    step: step,
    sequenceLength: 6,
    isReverse: isReverse,
    typedAnswer: false,
  );

  AnswerReveal reveal({
    required bool isBonus,
    String? typed,
    TypedAnswerMatch? match,
    DirectionSchedule? schedule,
  }) => AnswerReveal(
    key: key,
    prompt: 'Pérou',
    answer: 'Lima',
    result: ReviewResult(
      isBonus: isBonus,
      schedule: isBonus
          ? null
          : schedule ??
                DirectionSchedule(
                  state: DirectionState.active,
                  step: 0,
                  dueAt: DateTime(2026, 11, 11, 12),
                ),
      preset: BuiltInPresets.standard,
    ),
    answeredAt: DateTime(2026, 11, 10, 12, 5),
    typed: typed,
    match: match,
  );

  test('describes where the asked direction stands', () {
    expect(texts.promptDetail(prompt()), 'Cran 2 sur 6');
    expect(texts.promptDetail(prompt(step: null)), 'Nouvelle carte');
    expect(
      texts.promptDetail(prompt(isReverse: true)),
      'verso → recto · Cran 2 sur 6',
    );
    expect(
      texts.promptDetail(
        prompt(
          key: const ReviewNotificationKey(directionId: 7, extraReminderId: 1),
        ),
      ),
      'Réviser bientôt · sans effet sur le planning',
    );
    expect(texts.groupLabel(prompt()), 'Sans groupe');
  });

  test('tells what a failed answer did', () {
    expect(texts.answerLine(reveal(isBonus: false)), 'Réponse : Lima');
    expect(
      texts.verdict(reveal(isBonus: false)),
      'Compté raté · retour au cran 1, revue demain',
    );
    expect(texts.verdict(reveal(isBonus: true)), 'Révision bonus · sans effet');
  });

  test('tells how a typed answer compared, then what it did', () {
    final next = DirectionSchedule(
      state: DirectionState.active,
      step: 2,
      dueAt: DateTime(2026, 11, 13, 12),
    );
    expect(
      texts.verdict(
        reveal(
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
        reveal(
          isBonus: false,
          typed: 'Lima',
          match: TypedAnswerMatch.exact,
          schedule: const DirectionSchedule(
            state: DirectionState.acquired,
            step: null,
            dueAt: null,
          ),
        ),
      ),
      '« Lima » accepté · carte acquise',
    );
    expect(
      texts.verdict(
        reveal(isBonus: false, typed: 'Quito', match: TypedAnswerMatch.wrong),
      ),
      '« Quito » refusé · Compté raté · retour au cran 1, revue demain',
    );
    expect(
      texts.verdict(
        reveal(isBonus: true, typed: 'Lima', match: TypedAnswerMatch.exact),
      ),
      '« Lima » accepté · Révision bonus · sans effet',
    );
  });

  test('the payload carries the key, and tells prompts from answers', () {
    const extra = ReviewNotificationKey(directionId: 7, extraReminderId: 3);
    final prompt = NotificationPayload.encode(extra, isPrompt: true);
    final answer = NotificationPayload.encode(extra, isPrompt: false);
    expect(NotificationPayload.decode(prompt), extra);
    expect(NotificationPayload.decodePrompt(prompt), extra);
    expect(NotificationPayload.decode(answer), extra);
    expect(NotificationPayload.decodePrompt(answer), isNull);
    expect(NotificationPayload.decode('not json'), isNull);
    expect(NotificationPayload.decode(null), isNull);
  });

  test('the payload of a grouped reminder leads to its group', () {
    const capitals = GroupReminderKey(4);
    const noGroup = GroupReminderKey(null);
    final summary = NotificationPayload.encodeGroup(
      const GroupReminder(
        key: noGroup,
        groupName: null,
        count: 5,
        chain: true,
        alert: true,
      ),
    );
    expect(NotificationPayload.decodeGroup(summary), noGroup);
    expect(NotificationPayload.decodeGroupCount(summary), 5);
    expect(NotificationPayload.decode(summary), isNull);
    expect(NotificationPayload.target(summary)!.groupId, isNull);
    const chained = ReviewNotificationKey(directionId: 7, chain: capitals);
    final card = NotificationPayload.encode(chained, isPrompt: true);
    expect(NotificationPayload.decodePrompt(card), chained);
    expect(NotificationPayload.decodeGroup(card), isNull);
    expect(NotificationPayload.target(card)!.groupId, 4);
    expect(
      NotificationPayload.target(
        NotificationPayload.encode(key, isPrompt: true),
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
      texts.groupLabel(
        ReviewPrompt(
          key: const ReviewNotificationKey(
            directionId: 7,
            chain: GroupReminderKey(4),
          ),
          prompt: 'Pérou',
          groupName: 'Capitales',
          step: null,
          sequenceLength: 6,
          isReverse: false,
          typedAnswer: false,
          chainRemaining: 3,
        ),
      ),
      'Capitales · 3 à réviser',
    );
  });
}
