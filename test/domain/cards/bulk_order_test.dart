import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/domain/cards/bulk/bulk_order.dart';

void main() {
  final batch = [for (var line = 1; line <= 20; line++) line];

  test('the listed order keeps the top of the list first', () {
    expect(const BulkOrder.listed().apply(batch), batch);
  });

  test('a shuffle mixes the batch only, without changing it', () {
    final shuffled = const BulkOrder.shuffled(7).apply(batch);
    expect(shuffled, unorderedEquals(batch));
    expect(shuffled, isNot(batch));
    expect(batch.first, 1, reason: 'the pasted lines stay as they are');
  });

  test('a draw keeps its order until the next one', () {
    expect(
      const BulkOrder.shuffled(7).apply(batch),
      const BulkOrder.shuffled(7).apply(batch),
    );
    expect(
      const BulkOrder.shuffled(8).apply(batch),
      isNot(const BulkOrder.shuffled(7).apply(batch)),
    );
  });

  test('an edited line keeps its place, and every other line its own', () {
    final edited = [...batch]..[4] = 50;
    final before = const BulkOrder.shuffled(7).apply(batch);
    expect(const BulkOrder.shuffled(7).apply(edited), [
      for (final line in before) line == 5 ? 50 : line,
    ]);
  });
}
