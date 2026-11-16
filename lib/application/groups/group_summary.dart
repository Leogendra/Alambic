import '../../domain/groups/card_group.dart';
import '../../domain/presets/preset.dart';

/// One line of the groups tab, and the counts of a group page.
class GroupSummary {
  const GroupSummary({
    required this.group,
    required this.preset,
    required this.cardCount,
    required this.dueCount,
    required this.introducedCount,
    required this.pendingCount,
  });

  final CardGroup group;

  /// Preset inherited by the cards that have no choice of their own.
  final Preset preset;
  final int cardCount;
  final int dueCount;

  /// Cards the distillation has introduced.
  final int introducedCount;

  /// Cards waiting in the queue of the group.
  final int pendingCount;

  int get groupId => group.id;
}
