/// A reminder due today from a distillation, competing for its budget.
class BudgetedReminder {
  const BudgetedReminder({
    required this.directionId,
    required this.interval,
    required this.dueAt,
  });

  final int directionId;

  /// Interval that led to this reminder; zero for a card introduced and not
  /// answered yet.
  final Duration interval;
  final DateTime dueAt;
}

/// How a day's budget of a distillation is spent.
class BudgetSplit {
  const BudgetSplit({required this.postponed, required this.newCardRoom});

  /// Reminders over the budget, moved to the next day.
  final List<int> postponed;

  /// Budget left for new cards.
  final int newCardRoom;
}

/// "Avoid collisions": each day, a distillation has a budget of as many
/// notifications as cards per batch. Its due reminders come first, the
/// shortest interval first (D+1 before D+2); those over the budget are moved
/// to the next day without penalty, and new cards only get what is left.
abstract final class CollisionBudget {
  static BudgetSplit split(
    List<BudgetedReminder> dueReminders, {
    required int budget,
  }) {
    final ranked = [...dueReminders]
      ..sort((first, second) {
        final byInterval = first.interval.compareTo(second.interval);
        if (byInterval != 0) {
          return byInterval;
        }
        final byDue = first.dueAt.compareTo(second.dueAt);
        return byDue != 0
            ? byDue
            : first.directionId.compareTo(second.directionId);
      });
    final kept = ranked.length < budget ? ranked.length : budget;
    return BudgetSplit(
      postponed: [
        for (final reminder in ranked.skip(kept)) reminder.directionId,
      ],
      newCardRoom: budget - kept,
    );
  }
}
