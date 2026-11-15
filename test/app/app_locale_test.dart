import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/app/app_locale.dart';
import 'package:alambic/data/preferences/language_choice.dart';

void main() {
  test('the phone language is followed when the app has it', () {
    expect(
      AppLocale.resolve(LanguageChoice.system, const Locale('fr', 'BE')),
      const Locale('fr'),
    );
    expect(
      AppLocale.resolve(LanguageChoice.system, const Locale('en', 'GB')),
      const Locale('en'),
    );
  });

  test('any other phone language falls back to English', () {
    expect(
      AppLocale.resolve(LanguageChoice.system, const Locale('de')),
      const Locale('en'),
    );
    expect(AppLocale.resolve(LanguageChoice.system, null), const Locale('en'));
  });

  test('a language chosen in Settings wins over the phone', () {
    expect(
      AppLocale.resolve(LanguageChoice.english, const Locale('fr')),
      const Locale('en'),
    );
    expect(
      AppLocale.resolve(LanguageChoice.french, const Locale('de')),
      const Locale('fr'),
    );
  });
}
