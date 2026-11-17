import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/app/formatting/preset_labels.dart';
import 'package:alambic/domain/presets/built_in_presets.dart';
import 'package:alambic/l10n/generated/app_localizations.dart';

void main() {
  final english = lookupAppLocalizations(const Locale('en'));
  final french = lookupAppLocalizations(const Locale('fr'));

  test('a shipped preset reads in the language of the interface', () {
    expect(english.presetName(BuiltInPresets.intensive), 'Intensive');
    expect(french.presetName(BuiltInPresets.intensive), 'Intensif');
  });

  test('a renamed shipped preset keeps the name it was given', () {
    final renamed = BuiltInPresets.intensive.copyWith(name: 'Examen');
    expect(english.presetName(renamed), 'Examen');
  });

  test('a preset made by the user keeps its name', () {
    final own = BuiltInPresets.standard.copyWith(
      name: 'Révision du soir',
      builtInKey: () => null,
    );
    expect(english.presetName(own), 'Révision du soir');
  });
}
