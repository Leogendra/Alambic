import 'language_choice.dart';
import 'theme_choice.dart';

/// Preferences of the interface on this phone. They are not part of the
/// review data: they stay out of the export.
class InterfaceSettings {
  const InterfaceSettings({
    this.onboardingDone = false,
    this.language = LanguageChoice.system,
    this.theme = ThemeChoice.system,
  });

  /// Whether the welcome screens were gone through once.
  final bool onboardingDone;
  final LanguageChoice language;
  final ThemeChoice theme;

  InterfaceSettings copyWith({
    bool? onboardingDone,
    LanguageChoice? language,
    ThemeChoice? theme,
  }) => InterfaceSettings(
    onboardingDone: onboardingDone ?? this.onboardingDone,
    language: language ?? this.language,
    theme: theme ?? this.theme,
  );
}
