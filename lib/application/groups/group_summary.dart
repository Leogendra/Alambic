import '../../domain/groups/card_group.dart';
import '../../domain/presets/preset.dart';

/// One line of the groups tab, and the header of a group page.
class GroupSummary {
  const GroupSummary({
    required this.group,
    required this.preset,
    required this.cardCount,
    required this.dueCount,
    required this.isDistilling,
  });

  final CardGroup group;

  /// Preset inherited by the cards that have no choice of their own.
  final Preset preset;
  final int cardCount;
  final int dueCount;

  /// Whether the distillation of the group was activated, paused or not.
  final bool isDistilling;

  int get groupId => group.id;
}
