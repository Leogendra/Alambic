/// Where the app opens when the user touches a notification or its "Open"
/// button: the page of a group, or Home.
class NotificationTarget {
  const NotificationTarget.group(this.groupId) : isHome = false;

  const NotificationTarget.home() : groupId = null, isHome = true;

  /// `null` for "No group", or for Home.
  final int? groupId;
  final bool isHome;
}
