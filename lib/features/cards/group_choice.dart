/// Result of the group picker. A `null` [groupId] means "Sans groupe", which
/// differs from dismissing the picker (no result at all).
class GroupChoice {
  const GroupChoice(this.groupId);

  final int? groupId;
}
