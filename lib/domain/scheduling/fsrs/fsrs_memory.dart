/// What FSRS knows of the memory of a direction.
class FsrsMemory {
  const FsrsMemory({required this.stability, required this.difficulty});

  /// Days after which the probability of recalling the card falls to 90 %.
  final double stability;

  /// From 1 (easy) to 10 (hard).
  final double difficulty;

  @override
  bool operator ==(Object other) =>
      other is FsrsMemory &&
      other.stability == stability &&
      other.difficulty == difficulty;

  @override
  int get hashCode => Object.hash(stability, difficulty);

  @override
  String toString() => 'FsrsMemory(S: $stability, D: $difficulty)';
}
