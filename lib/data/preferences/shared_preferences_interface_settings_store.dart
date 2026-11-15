import 'package:shared_preferences/shared_preferences.dart';

import 'interface_settings.dart';
import 'interface_settings_store.dart';
import 'language_choice.dart';
import 'theme_choice.dart';

/// Keeps the interface preferences in shared_preferences. Choices are stored
/// by name; an unknown name (from a later version) falls back to the default.
class SharedPreferencesInterfaceSettingsStore
    implements InterfaceSettingsStore {
  SharedPreferencesInterfaceSettingsStore([SharedPreferencesAsync? preferences])
    : _preferences = preferences ?? SharedPreferencesAsync();

  static const String _onboardingDoneKey = 'onboardingDone';
  static const String _languageKey = 'language';
  static const String _themeKey = 'theme';

  final SharedPreferencesAsync _preferences;

  @override
  Future<InterfaceSettings> load() async => InterfaceSettings(
    onboardingDone: await _preferences.getBool(_onboardingDoneKey) ?? false,
    language: _byName(
      LanguageChoice.values,
      await _preferences.getString(_languageKey),
      LanguageChoice.system,
    ),
    theme: _byName(
      ThemeChoice.values,
      await _preferences.getString(_themeKey),
      ThemeChoice.system,
    ),
  );

  @override
  Future<void> save(InterfaceSettings settings) async {
    await _preferences.setBool(_onboardingDoneKey, settings.onboardingDone);
    await _preferences.setString(_languageKey, settings.language.name);
    await _preferences.setString(_themeKey, settings.theme.name);
  }

  static T _byName<T extends Enum>(List<T> values, String? name, T fallback) {
    for (final value in values) {
      if (value.name == name) {
        return value;
      }
    }
    return fallback;
  }
}
