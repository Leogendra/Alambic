import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/application/cards/card_draft.dart';
import 'package:alambic/application/cards/card_service.dart';
import 'package:alambic/application/cards/draft_image.dart';
import 'package:alambic/data/database/alambic_database.dart';
import 'package:alambic/data/images/image_store.dart';
import 'package:alambic/data/repositories/card_repository.dart';
import 'package:alambic/data/repositories/group_repository.dart';
import 'package:alambic/domain/cards/card_state.dart';
import 'package:alambic/domain/scheduling/card_schedule.dart';

import '../support/fixed_clock.dart';
import '../support/recording_schedule_listener.dart';
import '../support/test_database.dart';
import '../support/test_images.dart';

void main() {
  late AlambicDatabase database;
  late CardRepository cards;
  late CardService service;
  late FixedClock clock;
  late RecordingScheduleListener listener;
  late ImageStore images;
  late int groupId;
  late int otherGroupId;

  setUp(() async {
    database = openTestDatabase();
    cards = CardRepository(database);
    clock = FixedClock(DateTime(2026, 11, 10, 9));
    listener = RecordingScheduleListener();
    images = openTestImageStore();
    service = CardService(
      cards: cards,
      images: images,
      clock: clock.call,
      scheduleChangeListener: listener,
    );
    final groups = GroupRepository(database);
    groupId = await groups.create('Capitals', clock());
    otherGroupId = await groups.create('Geography', clock());
  });

  tearDown(() => database.close());

  CardDraft draft({String front = ' Mongolia ', int? inGroup}) => CardDraft(
    frontText: front,
    backText: 'Ulaanbaatar',
    groupId: inGroup ?? groupId,
  );

  /// Gives a card a progression, as if its distillation had introduced it
  /// and it had been answered.
  Future<void> introduce(int cardId) => cards.applySchedule(
    cardId,
    CardSchedule(
      state: CardState.active,
      step: 3,
      dueAt: DateTime(2026, 12, 10, 12),
    ),
  );

  test('a new card waits at the end of the queue of its group', () async {
    final first = await service.create(draft());
    final second = await service.create(draft(front: 'Laos'));
    final card = await cards.getCard(second);
    expect(card.state, CardState.pending);
    expect(card.dueAt, isNull);
    expect(card.step, isNull);
    expect((await cards.getCard(first)).frontText, 'Mongolia');
    expect((await cards.getCard(first)).queuePosition, 0);
    expect(card.queuePosition, 1);
    expect(listener.changeCount, 2);
  });

  test('a bulk add joins the queue in its order', () async {
    await service.create(draft());
    await service.createAll([draft(front: 'Laos'), draft(front: 'Peru')]);
    final positions = [
      for (final card in await cards.getCardsOfGroup(groupId))
        card.queuePosition,
    ];
    expect(positions, [0, 1, 2]);
  });

  group('moving a card to another group', () {
    test('puts a pending card at the end of the new queue', () async {
      await service.create(draft(inGroup: otherGroupId));
      final cardId = await service.create(draft());
      await service.update(cardId, draft(inGroup: otherGroupId));
      final card = await cards.getCard(cardId);
      expect(card.groupId, otherGroupId);
      expect(card.isPending, isTrue);
      expect(card.queuePosition, 1);
    });

    test('keeps the progression of an introduced card', () async {
      final cardId = await service.create(draft());
      await introduce(cardId);
      await service.update(cardId, draft(inGroup: otherGroupId));
      final card = await cards.getCard(cardId);
      expect(card.state, CardState.active);
      expect(card.step, 3);
      expect(card.dueAt, DateTime(2026, 12, 10, 12));
    });
  });

  test('a card without back cannot be stored', () async {
    final incomplete = CardDraft(
      frontText: 'Mongolia',
      backText: '  ',
      groupId: groupId,
    );
    expect(() => service.create(incomplete), throwsArgumentError);
  });

  group('images', () {
    const flag = 'test/support/fixtures/flag.png';

    CardDraft imageCard({DraftImage? front, String frontText = ''}) =>
        CardDraft(
          frontText: frontText,
          backText: 'Peru',
          frontImage: front,
          groupId: groupId,
        );

    bool stored(String? name) =>
        name != null && File(images.pathOf(name)).existsSync();

    test('a face can be an image alone, copied into the store', () async {
      final cardId = await service.create(
        imageCard(front: const PickedImage(flag)),
      );
      final card = await cards.getCard(cardId);
      expect(card.frontText, isNull);
      expect(card.front.hasImage, isTrue);
      expect(stored(card.frontImagePath), isTrue);
      expect(
        File(images.pathOf(card.frontImagePath!)).lengthSync(),
        File(flag).lengthSync(),
      );
    });

    test('replacing or removing an image deletes its file', () async {
      final cardId = await service.create(
        imageCard(front: const PickedImage(flag)),
      );
      final first = (await cards.getCard(cardId)).frontImagePath!;
      await service.update(
        cardId,
        imageCard(front: StoredImage(first), frontText: 'Drapeau'),
      );
      expect(stored(first), isTrue, reason: 'kept when unchanged');
      await service.update(cardId, imageCard(front: const PickedImage(flag)));
      final second = (await cards.getCard(cardId)).frontImagePath!;
      expect(second, isNot(first));
      expect(stored(first), isFalse);
      await service.update(cardId, imageCard(frontText: 'Drapeau'));
      expect((await cards.getCard(cardId)).frontImagePath, isNull);
      expect(stored(second), isFalse);
    });

    test('deleting a card deletes its images', () async {
      final cardId = await service.create(
        imageCard(front: const PickedImage(flag)),
      );
      final name = (await cards.getCard(cardId)).frontImagePath;
      await service.delete(cardId);
      expect(stored(name), isFalse);
    });

    test('a face needs a text or an image', () {
      expect(imageCard().isComplete, isFalse);
      expect(imageCard(front: const PickedImage(flag)).isComplete, isTrue);
    });
  });

  test('resetting sends the card back to the end of its queue', () async {
    final cardId = await service.create(draft());
    await service.create(draft(front: 'Laos'));
    await introduce(cardId);
    await service.resetProgress(cardId);
    final card = await cards.getCard(cardId);
    expect(card.state, CardState.pending);
    expect(card.step, isNull);
    expect(card.dueAt, isNull);
    expect(card.queuePosition, 2);
  });
}
