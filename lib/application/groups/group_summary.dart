import '../../domain/groups/card_group.dart';
import '../../domain/presets/preset.dart';

/// One line of the groups tab: a group, or "No group" when [group] is null.
class GroupSummary {
  const GroupSummary({
    required this.group,
    required this.preset,
    required this.cardCount,
    required this.dueCount,
    required this.activeCount,
    required this.newCount,
    required this.unstartedCount,
  });

  final CardGroup? group;

  /// Preset inherited by the cards that have no choice of their own.
  final Preset preset;
  final int cardCount;
  final int dueCount;

  /// Cards with at least one studied (active or acquired) direction.
  final int activeCount;

  /// Cards not fully introduced: a direction waits to be started or waits in
  /// a distillation queue.
  final int newCount;

  /// Cards with a direction waiting to be started by hand.
  final int unstartedCount;

  int? get groupId => group?.id;
}
