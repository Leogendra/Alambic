import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

Map<String, Object?> _read(String path) =>
    jsonDecode(File(path).readAsStringSync()) as Map<String, Object?>;

Set<String> _messageKeys(Map<String, Object?> arb) =>
    arb.keys.where((key) => !key.startsWith('@')).toSet();

void main() {
  final english = _read('lib/l10n/app_en.arb');
  final french = _read('lib/l10n/app_fr.arb');

  test('every English text has a French translation, and no more', () {
    expect(_messageKeys(french), _messageKeys(english));
  });

  test('the French texts use every placeholder of the English ones', () {
    // The English file is the template: it declares the placeholders.
    for (final key in _messageKeys(english)) {
      final metadata = english['@$key'] as Map<String, Object?>?;
      final placeholders =
          (metadata?['placeholders'] as Map<String, Object?>?)?.keys ??
          const <String>[];
      for (final placeholder in placeholders) {
        expect(
          '${french[key]}',
          matches(RegExp(r'\{' + placeholder + r'[,}]')),
          reason: '$key uses {$placeholder}',
        );
      }
    }
  });
}
