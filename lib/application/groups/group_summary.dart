import '../../domain/distillation/distillation.dart';
import '../../domain/groups/card_group.dart';
import '../../domain/presets/preset.dart';

/// One line of the groups tab, and the header of a group page.
class GroupSummary {
  const GroupSummary({
    required this.group,
    required this.preset,
    required this.cardCount,
    required this.dueCount,
    required this.distillation,
  });

  final CardGroup group;

  /// Preset inherited by the cards that have no choice of their own.
  final Preset preset;
  final int cardCount;
  final int dueCount;

  /// The distillation of the group, `null` until it is activated.
  final Distillation? distillation;

  /// Whether the distillation of the group was activated, paused or not.
  bool get isDistilling => distillation != null;

  bool get isDistillationPaused => distillation?.isPaused ?? false;

  int get groupId => group.id;
}
