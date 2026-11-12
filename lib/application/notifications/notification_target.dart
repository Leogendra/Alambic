/// Where the app opens when the user touches a notification or its "Open"
/// button: the page of a group (`null` for "No group").
class NotificationTarget {
  const NotificationTarget.group(this.groupId);

  final int? groupId;
}
