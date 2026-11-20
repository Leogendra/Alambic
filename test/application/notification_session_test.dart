import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/application/notifications/notification_session.dart';
import 'package:alambic/application/notifications/notification_target.dart';
import 'package:alambic/application/reviews/session_item.dart';
import 'package:alambic/application/reviews/session_item_factory.dart';
import 'package:alambic/data/database/alambic_database.dart';
import 'package:alambic/data/repositories/card_repository.dart';
import 'package:alambic/data/repositories/group_repository.dart';
import 'package:alambic/domain/cards/card_side.dart';
import 'package:alambic/domain/cards/card_state.dart';
import 'package:alambic/domain/scheduling/card_schedule.dart';
import 'package:alambic/domain/scheduling/due_policy.dart';
import 'package:alambic/domain/scheduling/scheduling_calendar.dart';

import '../support/fixed_clock.dart';
import '../support/fixed_random.dart';
import '../support/sample_data.dart';
import '../support/test_database.dart';

void main() {
  late AlambicDatabase database;
  late SampleServices samples;
  late CardRepository cards;
  late NotificationSession session;
  late int capitals;

  setUp(() {
    database = openTestDatabase();
    samples = SampleServices(database, FixedClock(sampleNow));
    cards = CardRepository(database);
    session = NotificationSession(
      cards: cards,
      duePolicy: const DuePolicy(SchedulingCalendar()),
      sessionItems: SessionItemFactory(
        cards: cards,
        groups: GroupRepository(database),
        random: FixedRandom(),
      ),
      clock: () => sampleNow,
    );
  });

  tearDown(() => database.close());

  /// A card of [groupId] due at [dueAt].
  Future<int> cardDueAt(String front, int groupId, DateTime dueAt) async {
    final cardId = await samples.card(front, 'x', groupId: groupId);
    await cards.applySchedule(
      cardId,
      CardSchedule(state: CardState.active, step: 0, dueAt: dueAt),
    );
    return cardId;
  }

  List<int> idsOf(List<SessionItem> items) => [
    for (final item in items) item.cardId,
  ];

  group('opened from', () {
    late int lima;
    late int vientiane;
    late int santiago;
    late int comer;
    late int beber;

    // Today is 10/11 at 9:00. Santiago is not due; the others are, earliest
    // first: comer, lima, beber, vientiane.
    setUp(() async {
      capitals = await samples.groups.create('Capitals');
      final spanish = await samples.groups.create('Spanish');
      lima = await cardDueAt('Peru', capitals, DateTime(2026, 11, 9, 12));
      vientiane = await cardDueAt('Laos', capitals, DateTime(2026, 11, 10, 12));
      santiago = await cardDueAt('Chile', capitals, DateTime(2026, 11, 12));
      comer = await cardDueAt('eat', spanish, DateTime(2026, 11, 8, 12));
      beber = await cardDueAt('drink', spanish, DateTime(2026, 11, 10, 8));
    });

    test('the digest: every due card, earliest due first', () async {
      final items = await session.itemsFor(const NotificationTarget.allDue());
      expect(idsOf(items), [comer, lima, beber, vientiane]);
    });

    test('a card: this card with its face, then every due card', () async {
      final items = await session.itemsFor(
        NotificationTarget.card(santiago, CardSide.back),
      );
      expect(idsOf(items), [santiago, comer, lima, beber, vientiane]);
      expect(items.first.askedSide, CardSide.back);
    });

    test('a due card is not asked twice', () async {
      final items = await session.itemsFor(
        NotificationTarget.card(vientiane, CardSide.front),
      );
      expect(idsOf(items), [vientiane, comer, lima, beber]);
    });

    test('a grouped reminder: its due cards, then the others', () async {
      final items = await session.itemsFor(NotificationTarget.group(capitals));
      expect(idsOf(items), [lima, vientiane, comer, beber]);
    });

    test('a chained card: this card, its group, then the others', () async {
      final items = await session.itemsFor(
        NotificationTarget.card(vientiane, CardSide.front, groupId: capitals),
      );
      expect(idsOf(items), [vientiane, lima, comer, beber]);
    });

    test('a card deleted meanwhile: every due card', () async {
      await samples.cards.delete(santiago);
      final items = await session.itemsFor(
        NotificationTarget.card(santiago, CardSide.front),
      );
      expect(idsOf(items), [comer, lima, beber, vientiane]);
    });
  });

  test('nothing left to review: an empty session', () async {
    capitals = await samples.groups.create('Capitals');
    await cardDueAt('Chile', capitals, DateTime(2026, 11, 12));
    expect(await session.itemsFor(const NotificationTarget.allDue()), isEmpty);
  });
}
