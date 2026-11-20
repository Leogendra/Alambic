import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/domain/cards/bulk/bulk_card_parser.dart';
import 'package:alambic/domain/cards/bulk/bulk_line_error_kind.dart';

void main() {
  test('reads one card per line and trims both faces', () {
    final result = BulkCardParser.parse(
      'Capital of Chile ; Santiago\nCapital of Kenya;Nairobi',
      ';',
    );
    expect(result.drafts.map((draft) => draft.front), [
      'Capital of Chile',
      'Capital of Kenya',
    ]);
    expect(result.drafts.map((draft) => draft.back), ['Santiago', 'Nairobi']);
    expect(result.errors, isEmpty);
  });

  test('reports and ignores a line without separator', () {
    final result = BulkCardParser.parse('a ; b\nCapital of Morocco Rabat', ';');
    expect(result.drafts, hasLength(1));
    expect(result.errors.single.lineNumber, 2);
    expect(result.errors.single.kind, BulkLineErrorKind.missingSeparator);
  });

  test('reports a line with an empty face', () {
    final result = BulkCardParser.parse(' ; Santiago', ';');
    expect(result.errors.single.kind, BulkLineErrorKind.emptyFace);
  });

  test('skips blank lines and keeps their numbering', () {
    final result = BulkCardParser.parse('a ; b\n\n   \nc', ';');
    expect(result.drafts, hasLength(1));
    expect(result.errors.single.lineNumber, 4);
  });

  test('accepts a custom multi-character separator', () {
    final result = BulkCardParser.parse('ls -la => list ; detailed', '=>');
    expect(result.drafts.single.front, 'ls -la');
    expect(result.drafts.single.back, 'list ; detailed');
  });
}
