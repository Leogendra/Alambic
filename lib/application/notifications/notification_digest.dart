/// The single notification replacing the notifications of a moment beyond
/// the auto grouping threshold: "12 cards to review".
class NotificationDigest {
  const NotificationDigest({
    required this.count,
    required this.groups,
    required this.alert,
  });

  /// Gathers the cards of the groups [groupIds], one entry per card.
  factory NotificationDigest.of(
    Iterable<int> groupIds,
    Map<int, String> groupNames, {
    required bool alert,
  }) {
    final counts = <int, int>{};
    for (final groupId in groupIds) {
      counts.update(groupId, (count) => count + 1, ifAbsent: () => 1);
    }
    return NotificationDigest(
      count: groupIds.length,
      groups: [
        for (final MapEntry(key: groupId, value: count) in counts.entries)
          (name: groupNames[groupId] ?? '', count: count),
      ],
      alert: alert,
    );
  }

  final int count;

  /// Groups of the cards with their number of cards, in the order they
  /// come.
  final List<({String name, int count})> groups;

  /// Rings and vibrates; `false` when only the count is refreshed.
  final bool alert;
}
