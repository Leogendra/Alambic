import 'package:flutter/widgets.dart';

import '../data/preferences/language_choice.dart';
import '../l10n/generated/app_localizations.dart';

/// Which language the app speaks, from the choice in Settings and the
/// language of the phone. The screens and the notifications both follow
/// these rules, so that they never disagree.
abstract final class AppLocale {
  /// Language of a phone set to a language the app does not have.
  static const Locale fallback = Locale('en');

  /// The language chosen in Settings, or `null` to follow the phone.
  static Locale? chosen(LanguageChoice choice) => switch (choice) {
    LanguageChoice.system => null,
    LanguageChoice.french => const Locale('fr'),
    LanguageChoice.english => const Locale('en'),
  };

  /// The language of the phone when the app has it, English otherwise.
  static Locale ofPhone(Locale? phone) {
    for (final locale in AppLocalizations.supportedLocales) {
      if (locale.languageCode == phone?.languageCode) {
        return locale;
      }
    }
    return fallback;
  }

  static Locale resolve(LanguageChoice choice, Locale? phone) =>
      chosen(choice) ?? ofPhone(phone);
}
