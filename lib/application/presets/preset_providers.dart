import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/data_providers.dart';
import '../../domain/presets/preset.dart';
import '../../domain/presets/preset_catalog.dart';
import '../scheduling/scheduling_providers.dart';
import 'preset_service.dart';

final presetsProvider = StreamProvider<List<Preset>>(
  (ref) => ref.watch(presetRepositoryProvider).watchAll(),
);

final presetCatalogProvider = StreamProvider<PresetCatalog>(
  (ref) => ref.watch(presetRepositoryProvider).watchCatalog(),
);

final presetServiceProvider = Provider(
  (ref) => PresetService(
    ref.watch(presetRepositoryProvider),
    ref.watch(scheduleChangeListenerProvider),
  ),
);
