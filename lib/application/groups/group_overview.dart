import '../../domain/cards/flashcard.dart';
import '../../domain/distillation/distillation.dart';
import '../../domain/groups/card_group.dart';
import '../../domain/presets/preset_catalog.dart';
import '../../domain/scheduling/due_policy.dart';
import 'group_summary.dart';

/// Builds the summaries shown in the groups tab and on a group page.
class GroupOverview {
  const GroupOverview(this._duePolicy);

  final DuePolicy _duePolicy;

  /// The groups in the given order.
  List<GroupSummary> summarize({
    required List<CardGroup> groups,
    required List<Flashcard> cards,
    required List<Distillation> distillations,
    required PresetCatalog catalog,
    required DateTime now,
  }) {
    final distilled = {
      for (final distillation in distillations) distillation.groupId,
    };
    final cardsByGroup = <int, List<Flashcard>>{};
    for (final card in cards) {
      cardsByGroup.putIfAbsent(card.groupId, () => []).add(card);
    }
    return [
      for (final group in groups)
        summarizeOne(
          group,
          cardsByGroup[group.id] ?? const [],
          catalog,
          now,
          isDistilling: distilled.contains(group.id),
        ),
    ];
  }

  GroupSummary summarizeOne(
    CardGroup group,
    List<Flashcard> cards,
    PresetCatalog catalog,
    DateTime now, {
    required bool isDistilling,
  }) => GroupSummary(
    group: group,
    preset: catalog.presetForGroup(group.id),
    cardCount: cards.length,
    dueCount: cards
        .where((card) => _duePolicy.isDueToday(card, now: now))
        .length,
    isDistilling: isDistilling,
  );
}
