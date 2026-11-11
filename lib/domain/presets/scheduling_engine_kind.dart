/// How the next interval of a direction is computed.
enum SchedulingEngineKind {
  /// Fixed list of intervals walked step by step.
  sequence,

  /// FSRS: intervals computed from the answers history.
  adaptive,
}
