import 'bulk_card_draft.dart';
import 'bulk_line_error.dart';
import 'bulk_line_error_kind.dart';
import 'bulk_parse_result.dart';

/// Reads `front;back` lines (with any separator). Blank lines are skipped silently; the
/// front stops at the first separator, so the back may contain it again.
abstract final class BulkCardParser {
  static const String defaultSeparator = ';';

  static BulkParseResult parse(String text, String separator) {
    final drafts = <BulkCardDraft>[];
    final errors = <BulkLineError>[];
    final lines = text.split(RegExp(r'\r?\n'));
    for (var index = 0; index < lines.length; index++) {
      final line = lines[index];
      if (line.trim().isEmpty) {
        continue;
      }
      final lineNumber = index + 1;
      final separatorIndex = separator.isEmpty ? -1 : line.indexOf(separator);
      if (separatorIndex < 0) {
        errors.add(
          BulkLineError(
            lineNumber: lineNumber,
            kind: BulkLineErrorKind.missingSeparator,
          ),
        );
        continue;
      }
      final front = line.substring(0, separatorIndex).trim();
      final back = line.substring(separatorIndex + separator.length).trim();
      if (front.isEmpty || back.isEmpty) {
        errors.add(
          BulkLineError(
            lineNumber: lineNumber,
            kind: BulkLineErrorKind.emptyFace,
          ),
        );
      } else {
        drafts.add(
          BulkCardDraft(lineNumber: lineNumber, front: front, back: back),
        );
      }
    }
    return BulkParseResult(drafts: drafts, errors: errors);
  }
}
