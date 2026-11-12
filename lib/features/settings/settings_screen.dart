import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/remanence_colors.dart';
import '../../app/widgets/panel_row.dart';
import '../../app/widgets/section_label.dart';
import '../../app/widgets/surface_panel.dart';
import '../../application/distillation/distillation_providers.dart';
import '../../application/presets/preset_providers.dart';
import '../../data/data_providers.dart';
import '../../l10n/generated/app_localizations.dart';
import '../distillation/global_distillation_screen.dart';
import '../presets/preset_picker.dart';
import '../presets/presets_screen.dart';
import 'exact_alarms_panel.dart';

/// Settings tab.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 20),
          child: Text(
            strings.settingsTitle,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
          ),
        ),
        SectionLabel(strings.settingsRepetitionSection),
        _RepetitionPanel(),
        const SizedBox(height: 24),
        SectionLabel(strings.settingsNotificationsSection),
        const ExactAlarmsPanel(),
      ],
    );
  }
}

class _RepetitionPanel extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final presets = ref.watch(presetsProvider).value ?? const [];
    final catalog = ref.watch(presetCatalogProvider).value;
    final global = ref.watch(globalDistillationProvider);
    final valueStyle = TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      color: RemanenceColors.of(context).accentText,
    );
    return SurfacePanel(
      children: [
        PanelRow(
          title: strings.settingsPresets,
          trailing: Text('${presets.length}', style: valueStyle),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (context) => const PresetsScreen(),
            ),
          ),
        ),
        PanelRow(
          title: strings.settingsGlobalPreset,
          subtitle: strings.settingsGlobalPresetHint,
          trailing: Text(catalog?.globalPreset.name ?? '', style: valueStyle),
          onTap: catalog == null
              ? null
              : () async {
                  final choice = await showPresetPicker(
                    context,
                    presets: presets,
                    selectedPresetId: catalog.globalPresetId,
                  );
                  final presetId = choice?.presetId;
                  if (presetId != null) {
                    await ref
                        .read(presetRepositoryProvider)
                        .setGlobalPresetId(presetId);
                  }
                },
        ),
        PanelRow(
          title: strings.settingsGlobalDistillation,
          subtitle: switch (global) {
            null => strings.settingsGlobalDistillationIdle,
            final global when global.distillation.isRunning =>
              strings.settingsGlobalDistillationRunning(
                global.introduced,
                global.total,
              ),
            final global => strings.settingsGlobalDistillationPaused(
              global.introduced,
              global.total,
            ),
          },
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (context) => const GlobalDistillationScreen(),
            ),
          ),
        ),
      ],
    );
  }
}
