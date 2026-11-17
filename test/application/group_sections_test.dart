import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/application/groups/group_sections.dart';
import 'package:alambic/domain/cards/card_state.dart';
import 'package:alambic/domain/cards/flashcard.dart';

import '../domain/test_cards.dart';

void main() {
  List<int> ids(List<Flashcard> cards) => [for (final card in cards) card.id];

  test('in progress: soonest first, remanent ones included, suspended ones '
      'at the end', () {
    final sections = GroupSections.of([
      testCard(id: 1, dueAt: DateTime(2026, 11, 14, 12)),
      testCard(id: 2, dueAt: DateTime(2026, 11, 9, 12), suspended: true),
      testCard(
        id: 3,
        state: CardState.remanent,
        dueAt: DateTime(2027, 5, 10, 12),
      ),
      testCard(id: 4, dueAt: DateTime(2026, 11, 10, 12)),
      testCard(id: 5, dueAt: DateTime(2026, 11, 10, 12)),
    ]);
    expect(ids(sections.ongoing), [4, 5, 1, 3, 2]);
  });

  test('waiting: the queue in its order, suspended ones in their place', () {
    final sections = GroupSections.of([
      testCard(id: 1, state: CardState.pending, queuePosition: 2),
      testCard(id: 2, state: CardState.pending, queuePosition: -1),
      testCard(
        id: 3,
        state: CardState.pending,
        queuePosition: 0,
        suspended: true,
      ),
      testCard(id: 4, dueAt: DateTime(2026, 11, 10, 12)),
    ]);
    expect(ids(sections.waiting), [2, 3, 1]);
    expect(sections.nextId, 2);
  });

  test('"next" is the first waiting card that is not suspended', () {
    final sections = GroupSections.of([
      testCard(
        id: 1,
        state: CardState.pending,
        queuePosition: 0,
        suspended: true,
      ),
      testCard(id: 2, state: CardState.pending, queuePosition: 1),
    ]);
    expect(sections.nextId, 2);
  });

  test('learned cards apart; no section, no next card', () {
    final sections = GroupSections.of([
      testCard(id: 1, state: CardState.acquired),
      testCard(id: 2, state: CardState.acquired, suspended: true),
    ]);
    expect(ids(sections.acquired), [1, 2]);
    expect(sections.ongoing, isEmpty);
    expect(sections.waiting, isEmpty);
    expect(sections.nextId, isNull);
    expect(GroupSections.of(const []).isEmpty, isTrue);
  });
}
