/// The single notification replacing the notifications of a moment beyond
/// the auto grouping threshold: "12 cards to review".
class NotificationDigest {
  const NotificationDigest({
    required this.count,
    required this.groupNames,
    required this.alert,
  });

  /// Gathers the cards of the groups [groupIds], one entry per card.
  factory NotificationDigest.of(
    Iterable<int> groupIds,
    Map<int, String> groupNames, {
    required bool alert,
  }) => NotificationDigest(
    count: groupIds.length,
    groupNames: [
      for (final groupId in groupIds.toSet()) groupNames[groupId] ?? '',
    ],
    alert: alert,
  );

  final int count;

  /// Groups of the cards, in the order they come.
  final List<String> groupNames;

  /// Rings and vibrates; `false` when only the count is refreshed.
  final bool alert;
}
