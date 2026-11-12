/// Identifies the grouped reminder of a group, or of "No group" when
/// [groupId] is `null`.
class GroupReminderKey {
  const GroupReminderKey(this.groupId);

  final int? groupId;

  @override
  bool operator ==(Object other) =>
      other is GroupReminderKey && other.groupId == groupId;

  @override
  int get hashCode => groupId.hashCode;
}
