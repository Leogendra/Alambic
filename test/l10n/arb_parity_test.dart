import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

Map<String, Object?> _read(String path) =>
    jsonDecode(File(path).readAsStringSync()) as Map<String, Object?>;

Set<String> _messageKeys(Map<String, Object?> arb) =>
    arb.keys.where((key) => !key.startsWith('@')).toSet();

void main() {
  final french = _read('lib/l10n/app_fr.arb');
  final english = _read('lib/l10n/app_en.arb');

  test('every French text has an English translation, and no more', () {
    expect(_messageKeys(english), _messageKeys(french));
  });

  test('the English texts use every placeholder of the French ones', () {
    // The French file is the template: it declares the placeholders.
    for (final key in _messageKeys(french)) {
      final metadata = french['@$key'] as Map<String, Object?>?;
      final placeholders =
          (metadata?['placeholders'] as Map<String, Object?>?)?.keys ??
          const <String>[];
      for (final placeholder in placeholders) {
        expect(
          '${english[key]}',
          matches(RegExp(r'\{' + placeholder + r'[,}]')),
          reason: '$key uses {$placeholder}',
        );
      }
    }
  });
}
