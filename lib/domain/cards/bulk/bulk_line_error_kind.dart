enum BulkLineErrorKind {
  /// The line does not contain the separator.
  missingSeparator,

  /// The front or the back is empty around the separator.
  emptyFace,
}
