import 'package:shared_preferences/shared_preferences.dart';

import 'interface_settings.dart';
import 'interface_settings_store.dart';

/// Keeps the interface preferences in shared_preferences.
class SharedPreferencesInterfaceSettingsStore
    implements InterfaceSettingsStore {
  SharedPreferencesInterfaceSettingsStore([SharedPreferencesAsync? preferences])
    : _preferences = preferences ?? SharedPreferencesAsync();

  static const String _onboardingDoneKey = 'onboardingDone';

  final SharedPreferencesAsync _preferences;

  @override
  Future<InterfaceSettings> load() async => InterfaceSettings(
    onboardingDone: await _preferences.getBool(_onboardingDoneKey) ?? false,
  );

  @override
  Future<void> save(InterfaceSettings settings) =>
      _preferences.setBool(_onboardingDoneKey, settings.onboardingDone);
}
