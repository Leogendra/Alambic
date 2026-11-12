/// The pauses in progress: the global one ("holidays") and those of groups.
/// A paused card is never notified and its distillation introduces nothing;
/// at the end of the pause, its due dates are shifted by the pause length.
class Pauses {
  const Pauses({this.globalSince, this.groupsSince = const {}});

  static const Pauses none = Pauses();

  /// Start of the global pause, `null` when it is off.
  final DateTime? globalSince;

  /// Start of the pause of each paused group.
  final Map<int, DateTime> groupsSince;

  bool get isGlobal => globalSince != null;

  /// Whether the cards of [groupId] (`null` for "No group") are paused.
  bool covers(int? groupId) =>
      isGlobal || (groupId != null && groupsSince.containsKey(groupId));
}
