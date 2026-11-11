import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:remanence/application/notifications/answer_reveal.dart';
import 'package:remanence/application/notifications/review_notification_key.dart';
import 'package:remanence/application/notifications/review_prompt.dart';
import 'package:remanence/application/reviews/review_result.dart';
import 'package:remanence/domain/cards/direction_state.dart';
import 'package:remanence/domain/presets/built_in_presets.dart';
import 'package:remanence/domain/scheduling/direction_schedule.dart';
import 'package:remanence/domain/scheduling/scheduling_calendar.dart';
import 'package:remanence/l10n/generated/app_localizations.dart';
import 'package:remanence/notifications/android/notification_payload.dart';
import 'package:remanence/notifications/review_texts.dart';

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
  );

  AnswerReveal reveal({required bool isBonus}) => AnswerReveal(
    key: key,
    prompt: 'Pérou',
    answer: 'Lima',
    result: ReviewResult(
      isBonus: isBonus,
      schedule: isBonus
          ? null
          : DirectionSchedule(
              state: DirectionState.active,
              step: 0,
              dueAt: DateTime(2026, 11, 11, 12),
            ),
      preset: BuiltInPresets.standard,
    ),
    answeredAt: DateTime(2026, 11, 10, 12, 5),
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
}
