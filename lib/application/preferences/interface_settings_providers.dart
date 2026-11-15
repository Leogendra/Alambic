import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/preferences/interface_settings.dart';
import '../../data/preferences/interface_settings_store.dart';
import 'interface_settings_controller.dart';

/// Always overridden: by the app entry point with shared_preferences, by
/// tests with a store in memory.
final interfaceSettingsStoreProvider = Provider<InterfaceSettingsStore>(
  (ref) => throw UnimplementedError(
    'interfaceSettingsStoreProvider must be overridden',
  ),
);

/// The preferences read before the app is shown. Overridden by the app entry
/// point; tests start from the defaults, onboarding included.
final initialInterfaceSettingsProvider = Provider<InterfaceSettings>(
  (ref) => const InterfaceSettings(),
);

final interfaceSettingsProvider =
    NotifierProvider<InterfaceSettingsController, InterfaceSettings>(
      InterfaceSettingsController.new,
    );
