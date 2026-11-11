import 'package:flutter_test/flutter_test.dart';
import 'package:remanence/application/cards/card_draft.dart';
import 'package:remanence/application/cards/card_service.dart';
import 'package:remanence/data/database/remanence_database.dart';
import 'package:remanence/data/repositories/card_repository.dart';
import 'package:remanence/data/repositories/preset_repository.dart';
import 'package:remanence/domain/cards/card_direction.dart';
import 'package:remanence/domain/cards/direction_sense.dart';
import 'package:remanence/domain/cards/direction_state.dart';
import 'package:remanence/domain/scheduling/direction_schedule.dart';
import 'package:remanence/domain/scheduling/review_scheduler.dart';
import 'package:remanence/domain/scheduling/scheduling_calendar.dart';

import '../support/fixed_clock.dart';
import '../support/recording_schedule_listener.dart';
import '../support/test_database.dart';

void main() {
  late RemanenceDatabase database;
  late CardRepository cards;
  late CardService service;
  late FixedClock clock;
  late RecordingScheduleListener listener;

  setUp(() {
    database = openTestDatabase();
    cards = CardRepository(database);
    clock = FixedClock(DateTime(2026, 11, 10, 9));
    listener = RecordingScheduleListener();
    service = CardService(
      cards: cards,
      presets: PresetRepository(database),
      scheduler: const ReviewScheduler(SchedulingCalendar()),
      clock: clock.call,
      scheduleChangeListener: listener,
    );
  });

  tearDown(() => database.close());

  CardDraft draft({bool alsoReverse = false}) => CardDraft(
    frontText: ' Mongolie ',
    backText: 'Oulan-Bator',
    groupId: null,
    presetId: null,
    alsoReverse: alsoReverse,
  );

  Future<CardDirection> direction(int cardId, DirectionSense sense) async =>
      (await cards.getDirections(cardId))
          .firstWhere((direction) => direction.sense == sense);

  test('a new card is due at the next preset slot, front only', () async {
    final cardId = await service.create(draft());
    final front = await direction(cardId, DirectionSense.frontToBack);
    final reverse = await direction(cardId, DirectionSense.backToFront);
    expect(front.state, DirectionState.active);
    expect(front.dueAt, DateTime(2026, 11, 10, 12));
    expect(front.step, isNull);
    expect(reverse.state, DirectionState.inactive);
    expect(reverse.dueAt, isNull);
    expect((await cards.getCard(cardId)).frontText, 'Mongolie');
    expect(listener.changeCount, 1);
  });

  test('"also reverse" starts the reverse direction the next day', () async {
    final cardId = await service.create(draft(alsoReverse: true));
    final reverse = await direction(cardId, DirectionSense.backToFront);
    expect(reverse.state, DirectionState.active);
    expect(reverse.dueAt, DateTime(2026, 11, 11, 12));
  });

  test('checking "also reverse" when editing starts the reverse', () async {
    final cardId = await service.create(draft());
    await service.update(cardId, draft(alsoReverse: true));
    final reverse = await direction(cardId, DirectionSense.backToFront);
    expect(reverse.state, DirectionState.active);
    expect(reverse.dueAt, DateTime(2026, 11, 11, 12));
  });

  test('unchecking "also reverse" stops the reverse direction', () async {
    final cardId = await service.create(draft(alsoReverse: true));
    await service.update(cardId, draft());
    final reverse = await direction(cardId, DirectionSense.backToFront);
    expect(reverse.state, DirectionState.inactive);
    expect(reverse.dueAt, isNull);
  });

  test('a card without back cannot be stored', () async {
    final incomplete = CardDraft(
      frontText: 'Mongolie',
      backText: '  ',
      groupId: null,
      presetId: null,
      alsoReverse: false,
    );
    expect(() => service.create(incomplete), throwsArgumentError);
  });

  test('resetting forgets the step and schedules again', () async {
    final cardId = await service.create(draft(alsoReverse: true));
    final front = await direction(cardId, DirectionSense.frontToBack);
    await cards.applySchedule(
      front.id,
      DirectionSchedule(
        state: DirectionState.active,
        step: 3,
        dueAt: DateTime(2026, 12, 10, 12),
      ),
    );
    clock.now = DateTime(2026, 11, 20, 15);
    await service.resetProgress(cardId);
    final resetFront = await direction(cardId, DirectionSense.frontToBack);
    final resetReverse = await direction(cardId, DirectionSense.backToFront);
    expect(resetFront.step, isNull);
    expect(resetFront.dueAt, DateTime(2026, 11, 21, 12));
    expect(resetReverse.dueAt, DateTime(2026, 11, 22, 12));
  });
}
