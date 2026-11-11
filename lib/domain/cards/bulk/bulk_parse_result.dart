import 'bulk_card_draft.dart';
import 'bulk_line_error.dart';

class BulkParseResult {
  const BulkParseResult({required this.drafts, required this.errors});

  final List<BulkCardDraft> drafts;
  final List<BulkLineError> errors;
}
