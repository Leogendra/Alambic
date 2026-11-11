import '../../data/repositories/card_with_directions.dart';
import '../../domain/cards/direction_state.dart';
import '../../domain/groups/card_group.dart';
import '../../domain/presets/preset_catalog.dart';
import '../../domain/scheduling/due_policy.dart';
import 'group_summary.dart';

/// Builds the summaries shown in the groups tab and on a group page.
class GroupOverview {
  const GroupOverview(this._duePolicy);

  final DuePolicy _duePolicy;

  /// "Sans groupe" first, then the groups in the given order.
  List<GroupSummary> summarize({
    required List<CardGroup> groups,
    required List<CardWithDirections> cards,
    required PresetCatalog catalog,
    required DateTime now,
  }) {
    final cardsByGroup = <int?, List<CardWithDirections>>{};
    for (final card in cards) {
      cardsByGroup.putIfAbsent(card.card.groupId, () => []).add(card);
    }
    return [
      summarizeOne(null, cardsByGroup[null] ?? const [], catalog, now),
      for (final group in groups)
        summarizeOne(group, cardsByGroup[group.id] ?? const [], catalog, now),
    ];
  }

  GroupSummary summarizeOne(
    CardGroup? group,
    List<CardWithDirections> cards,
    PresetCatalog catalog,
    DateTime now,
  ) => GroupSummary(
    group: group,
    preset: catalog.presetForGroup(group?.id),
    cardCount: cards.length,
    dueCount: cards.where((card) => isCardDue(card, now)).length,
    activeCount: cards.where(_isStudied).length,
    pendingCount: cards.where(_isPending).length,
  );

  /// A card is due when one of its directions is.
  bool isCardDue(CardWithDirections card, DateTime now) => card.directions.any(
    (direction) => _duePolicy.isDueToday(
      direction,
      cardSuspended: card.card.suspended,
      now: now,
    ),
  );

  bool _isStudied(CardWithDirections card) => card.directions.any(
    (direction) =>
        direction.state == DirectionState.active ||
        direction.state == DirectionState.acquired,
  );

  bool _isPending(CardWithDirections card) => card.directions.any(
    (direction) => direction.state == DirectionState.pending,
  );
}
