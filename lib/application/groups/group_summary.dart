import '../../domain/groups/card_group.dart';
import '../../domain/presets/preset.dart';

/// One line of the groups tab: a group, or "Sans groupe" when [group] is null.
class GroupSummary {
  const GroupSummary({
    required this.group,
    required this.preset,
    required this.cardCount,
    required this.dueCount,
    required this.activeCount,
    required this.pendingCount,
  });

  final CardGroup? group;

  /// Preset inherited by the cards that have no choice of their own.
  final Preset preset;
  final int cardCount;
  final int dueCount;

  /// Cards with at least one studied (active or acquired) direction.
  final int activeCount;

  /// Cards with a direction waiting in a distillation queue.
  final int pendingCount;

  int? get groupId => group?.id;
}
