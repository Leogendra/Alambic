import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/application/notifications/answer_reveal.dart';
import 'package:alambic/application/notifications/group_reminder.dart';
import 'package:alambic/application/notifications/group_reminder_key.dart';
import 'package:alambic/application/notifications/review_notification_key.dart';
import 'package:alambic/application/notifications/review_prompt.dart';
import 'package:alambic/application/reviews/review_result.dart';
import 'package:alambic/domain/cards/card_side.dart';
import 'package:alambic/domain/cards/card_state.dart';
import 'package:alambic/domain/presets/built_in_presets.dart';
import 'package:alambic/domain/presets/interval_unit.dart';
import 'package:alambic/domain/presets/preset_interval.dart';
import 'package:alambic/domain/reviews/typed_answer_match.dart';
import 'package:alambic/domain/scheduling/card_progress.dart';
import 'package:alambic/domain/scheduling/card_schedule.dart';
import 'package:alambic/domain/scheduling/fsrs/fsrs_memory.dart';
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
    int? step = 1,
    CardSide askedSide = CardSide.front,
  }) => ReviewPrompt(
    key: key,
    askedSide: askedSide,
    prompt: 'Pérou',
    image: null,
    groupName: 'Capitales',
    progress: step == null
        ? const NewProgress()
        : SequenceProgress(
            step: step,
            sequenceLength: 6,
            interval: const PresetInterval(2, IntervalUnit.day),
          ),
    typedAnswer: false,
  );

  AnswerReveal reveal({
    required bool isBonus,
    String? typed,
    TypedAnswerMatch? match,
    CardSchedule? schedule,
  }) => AnswerReveal(
    key: key,
    askedSide: CardSide.front,
    prompt: 'Pérou',
    answer: 'Lima',
    answerImage: null,
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
      preset: BuiltInPresets.standard,
    ),
    answeredAt: DateTime(2026, 11, 10, 12, 5),
    typed: typed,
    match: match,
  );

  test('describes where the asked card stands', () {
    expect(texts.promptDetail(prompt()), 'Cran 2 sur 6');
    expect(texts.promptDetail(prompt(step: null)), 'Nouvelle carte');
    expect(
      texts.promptDetail(prompt(askedSide: CardSide.back)),
      'verso → recto · Cran 2 sur 6',
    );
    expect(
      texts.promptDetail(
        prompt(key: const ReviewNotificationKey(cardId: 7, extraReminderId: 1)),
      ),
      'Réviser bientôt · sans effet sur le planning',
    );
    expect(texts.groupLabel(prompt()), 'Capitales');
  });

  test('tells what a failed answer did', () {
    expect(texts.answerLine(reveal(isBonus: false)), 'Réponse : Lima');
    expect(
      texts.verdict(reveal(isBonus: false)),
      'Compté raté · retour au cran 1, revue demain',
    );
    expect(texts.verdict(reveal(isBonus: true)), 'Révision bonus · sans effet');
  });

  test('a face that is an image alone is named as such', () {
    expect(texts.promptTitle('Pérou'), 'Pérou');
    expect(texts.promptTitle(''), 'Que montre cette image ?');
    expect(
      texts.answerLine(
        AnswerReveal(
          key: key,
          askedSide: CardSide.front,
          prompt: 'Drapeau',
          answer: '',
          answerImage: 'flag.png',
          result: ReviewResult(
            isBonus: true,
            schedule: null,
            preset: BuiltInPresets.standard,
          ),
          answeredAt: DateTime(2026, 11, 10, 12, 5),
        ),
      ),
      'Réponse en image',
    );
  });

  test('an adaptive card tells its interval instead of a step', () {
    expect(
      texts.promptDetail(
        ReviewPrompt(
          key: key,
          askedSide: CardSide.front,
          prompt: 'Pérou',
          image: null,
          groupName: 'Capitales',
          progress: const AdaptiveProgress(
            memory: FsrsMemory(stability: 11.7, difficulty: 5.3),
            intervalDays: 12,
          ),
          typedAnswer: false,
        ),
      ),
      'Intervalle 12 j',
    );
    expect(
      texts.verdict(
        reveal(
          isBonus: false,
          schedule: CardSchedule(
            state: CardState.active,
            step: null,
            memory: const FsrsMemory(stability: 2.2, difficulty: 6.8),
            dueAt: DateTime(2026, 11, 12, 12),
          ),
        ),
      ),
      'Compté raté · revue dans 2 j',
    );
  });

  test('tells how a typed answer compared, then what it did', () {
    final next = CardSchedule(
      state: CardState.active,
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
      texts.groupLabel(
        ReviewPrompt(
          key: const ReviewNotificationKey(
            cardId: 7,
            chain: GroupReminderKey(4),
          ),
          askedSide: CardSide.front,
          prompt: 'Pérou',
          image: null,
          groupName: 'Capitales',
          progress: const NewProgress(),
          typedAnswer: false,
          chainRemaining: 3,
        ),
      ),
      'Capitales · 3 à réviser',
    );
  });
}
