import 'dart:math';

/// Order in which a bulk-added batch joins the end of the queue: the top of
/// the list first, or shuffled. A shuffle is a draw kept as its seed, so the
/// batch keeps the order shown to the user until they draw again.
class BulkOrder {
  const BulkOrder.listed() : _seed = null;

  const BulkOrder.shuffled(int seed) : _seed = seed;

  final int? _seed;

  bool get isShuffled => _seed != null;

  /// [batch] in this order; the shuffle only mixes the batch itself.
  List<T> apply<T>(List<T> batch) => switch (_seed) {
    null => batch,
    final seed => [...batch]..shuffle(Random(seed)),
  };
}
