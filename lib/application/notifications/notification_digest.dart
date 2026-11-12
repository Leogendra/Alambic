/// The single notification replacing the notifications of a moment beyond
/// the auto grouping threshold: "12 cartes à réviser".
class NotificationDigest {
  const NotificationDigest({
    required this.count,
    required this.groupNames,
    required this.alert,
  });

  /// Gathers the cards of the groups [groupIds], one entry per card, `null`
  /// standing for "No group".
  factory NotificationDigest.of(
    Iterable<int?> groupIds,
    Map<int, String> groupNames, {
    required bool alert,
  }) => NotificationDigest(
    count: groupIds.length,
    groupNames: [
      for (final groupId in groupIds.toSet())
        groupId == null ? null : groupNames[groupId],
    ],
    alert: alert,
  );

  final int count;

  /// Groups of the cards, in the order they come; `null` for "No group".
  final List<String?> groupNames;

  /// Rings and vibrates; `false` when only the count is refreshed.
  final bool alert;
}
