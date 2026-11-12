import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/application/cards/card_draft.dart';
import 'package:alambic/application/cards/card_service.dart';
import 'package:alambic/application/distillation/distillation_service.dart';
import 'package:alambic/application/scheduling/ignored_schedule_changes.dart';
import 'package:alambic/data/database/alambic_database.dart';
import 'package:alambic/data/repositories/card_repository.dart';
import 'package:alambic/data/repositories/distillation_repository.dart';
import 'package:alambic/data/repositories/pause_repository.dart';
import 'package:alambic/data/repositories/preset_repository.dart';
import 'package:alambic/domain/cards/card_direction.dart';
import 'package:alambic/domain/cards/direction_sense.dart';
import 'package:alambic/domain/cards/direction_state.dart';
import 'package:alambic/domain/scheduling/direction_schedule.dart';
import 'package:alambic/domain/scheduling/review_scheduler.dart';
import 'package:alambic/domain/scheduling/scheduling_calendar.dart';

import '../support/fixed_clock.dart';
import '../support/recording_schedule_listener.dart';
import '../support/test_database.dart';

void main() {
  late AlambicDatabase database;
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
      distillations: DistillationService(
        distillations: DistillationRepository(database),
        cards: cards,
        presets: PresetRepository(database),
        pauses: PauseRepository(database),
        scheduler: const ReviewScheduler(SchedulingCalendar()),
        calendar: const SchedulingCalendar(),
        clock: clock.call,
        scheduleChangeListener: const IgnoredScheduleChanges(),
      ),
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

  test('a new card waits to be started, front only', () async {
    final cardId = await service.create(draft());
    final front = await direction(cardId, DirectionSense.frontToBack);
    final reverse = await direction(cardId, DirectionSense.backToFront);
    expect(front.state, DirectionState.unstarted);
    expect(front.dueAt, isNull);
    expect(front.step, isNull);
    expect(reverse.state, DirectionState.inactive);
    expect((await cards.getCard(cardId)).frontText, 'Mongolie');
    expect(listener.changeCount, 1);
  });

  test('"also reverse" makes the reverse direction wait too', () async {
    final cardId = await service.create(draft(alsoReverse: true));
    final reverse = await direction(cardId, DirectionSense.backToFront);
    expect(reverse.state, DirectionState.unstarted);
    expect(reverse.dueAt, isNull);
  });

  test('starting a group makes its new cards due today', () async {
    clock.now = DateTime(2026, 11, 10, 15);
    final cardId = await service.create(draft(alsoReverse: true));
    final started = await service.startGroup(null);
    final front = await direction(cardId, DirectionSense.frontToBack);
    final reverse = await direction(cardId, DirectionSense.backToFront);
    expect(started, 1);
    expect(front.state, DirectionState.active);
    expect(front.dueAt, DateTime(2026, 11, 10, 12));
    expect(reverse.dueAt, DateTime(2026, 11, 11, 12));
    expect(await service.startGroup(null), 0);
  });

  test('starting one direction leaves the other waiting', () async {
    final cardId = await service.create(draft(alsoReverse: true));
    final reverse = await direction(cardId, DirectionSense.backToFront);
    await service.startDirection(reverse.id);
    final front = await direction(cardId, DirectionSense.frontToBack);
    expect(front.state, DirectionState.unstarted);
    expect(
      (await direction(cardId, DirectionSense.backToFront)).dueAt,
      DateTime(2026, 11, 10, 12),
    );
  });

  test('checking "also reverse" when editing adds a waiting reverse', () async {
    final cardId = await service.create(draft());
    await service.update(cardId, draft(alsoReverse: true));
    final reverse = await direction(cardId, DirectionSense.backToFront);
    expect(reverse.state, DirectionState.unstarted);
  });

  test('unchecking "also reverse" stops the reverse direction', () async {
    final cardId = await service.create(draft(alsoReverse: true));
    await service.startGroup(null);
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

  test('resetting forgets the step and makes the card due today', () async {
    final cardId = await service.create(draft(alsoReverse: true));
    await service.startGroup(null);
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
    expect(resetFront.dueAt, DateTime(2026, 11, 20, 12));
    expect(resetReverse.dueAt, DateTime(2026, 11, 21, 12));
  });
}
