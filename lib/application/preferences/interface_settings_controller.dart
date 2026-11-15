import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/preferences/interface_settings.dart';
import 'interface_settings_providers.dart';

/// The interface preferences in force, saved as soon as they change. They
/// start from the values loaded before the app is shown, so that the first
/// frame already has the right screen.
class InterfaceSettingsController extends Notifier<InterfaceSettings> {
  @override
  InterfaceSettings build() => ref.read(initialInterfaceSettingsProvider);

  Future<void> completeOnboarding() =>
      _update(state.copyWith(onboardingDone: true));

  Future<void> _update(InterfaceSettings settings) async {
    state = settings;
    await ref.read(interfaceSettingsStoreProvider).save(settings);
  }
}
