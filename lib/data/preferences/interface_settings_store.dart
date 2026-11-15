import 'interface_settings.dart';

/// Where the interface preferences are kept between launches.
abstract interface class InterfaceSettingsStore {
  Future<InterfaceSettings> load();

  Future<void> save(InterfaceSettings settings);
}
