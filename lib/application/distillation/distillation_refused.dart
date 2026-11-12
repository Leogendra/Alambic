/// Why a distillation cannot be launched.
enum DistillationRefusal {
  /// The global distillation is in progress: no group distillation can
  /// start until it is stopped.
  globalInProgress,

  /// The group already has a distillation of this direction.
  senseTaken,

  /// No direction is waiting to be introduced.
  nothingToDistill,
}

class DistillationRefused implements Exception {
  const DistillationRefused(this.reason);

  final DistillationRefusal reason;

  @override
  String toString() => 'DistillationRefused(${reason.name})';
}
