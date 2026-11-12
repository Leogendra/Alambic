import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/domain/distillation/collision_budget.dart';

void main() {
  BudgetedReminder reminder(int id, int days, {int hour = 12}) =>
      BudgetedReminder(
        directionId: id,
        interval: Duration(days: days),
        dueAt: DateTime(2026, 11, 10, hour),
      );

  test('the shortest intervals pass first, the rest is postponed', () {
    final split = CollisionBudget.split([
      reminder(1, 2),
      reminder(2, 1),
      reminder(3, 7),
      reminder(4, 1),
    ], budget: 3);
    expect(split.postponed, [3]);
    expect(split.newCardRoom, 0);
  });

  test('new cards get what is left of the budget', () {
    final split = CollisionBudget.split([reminder(1, 1)], budget: 3);
    expect(split.postponed, isEmpty);
    expect(split.newCardRoom, 2);
  });

  test('equal intervals: the earliest due passes first', () {
    final split = CollisionBudget.split([
      reminder(1, 1, hour: 18),
      reminder(2, 1, hour: 9),
    ], budget: 1);
    expect(split.postponed, [1]);
  });
}
