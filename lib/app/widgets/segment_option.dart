/// One option of a [SegmentedChoice].
class SegmentOption<T> {
  const SegmentOption(this.value, this.label, {this.enabled = true});

  final T value;
  final String label;

  /// A disabled option is greyed out and cannot be selected.
  final bool enabled;
}
