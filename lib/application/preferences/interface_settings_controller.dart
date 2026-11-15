import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/preferences/interface_settings.dart';
import '../../data/preferences/language_choice.dart';
import '../../data/preferences/theme_choice.dart';
import 'interface_settings_providers.dart';

/// The interface preferences in force, saved as soon as they change. They
/// start from the values loaded before the app is shown, so that the first
/// frame already has the right screen, language and theme.
class InterfaceSettingsController extends Notifier<InterfaceSettings> {
  @override
  InterfaceSettings build() => ref.read(initialInterfaceSettingsProvider);

  Future<void> completeOnboarding() =>
      _update(state.copyWith(onboardingDone: true));

  Future<void> setLanguage(LanguageChoice language) =>
      _update(state.copyWith(language: language));

  Future<void> setTheme(ThemeChoice theme) =>
      _update(state.copyWith(theme: theme));

  Future<void> _update(InterfaceSettings settings) async {
    state = settings;
    await ref.read(interfaceSettingsStoreProvider).save(settings);
  }
}
