import 'package:alambic/data/preferences/interface_settings.dart';
import 'package:alambic/data/preferences/interface_settings_store.dart';

/// Interface preferences kept in memory.
class FakeInterfaceSettingsStore implements InterfaceSettingsStore {
  InterfaceSettings saved = const InterfaceSettings();

  @override
  Future<InterfaceSettings> load() async => saved;

  @override
  Future<void> save(InterfaceSettings settings) async => saved = settings;
}
