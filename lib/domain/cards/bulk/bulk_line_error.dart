import 'bulk_line_error_kind.dart';

/// A pasted line that is reported and ignored.
class BulkLineError {
  const BulkLineError({required this.lineNumber, required this.kind});

  /// 1-based, as shown next to the text field.
  final int lineNumber;
  final BulkLineErrorKind kind;
}
