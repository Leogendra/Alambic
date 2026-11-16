import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/formatting/interval_labels.dart';
import '../../app/formatting/preset_labels.dart';
import '../../app/layout/scroll_padding.dart';
import '../../app/theme/alambic_colors.dart';
import '../../app/widgets/interval_chip.dart';
import '../../application/presets/preset_providers.dart';
import '../../domain/presets/preset.dart';
import '../../domain/presets/scheduling_engine_kind.dart';
import '../../l10n/generated/app_localizations.dart';
import 'preset_editor_screen.dart';

/// List of presets, reached from Settings.
class PresetsScreen extends ConsumerWidget {
  const PresetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final catalog = ref.watch(presetCatalogProvider).value;
    final presets = ref.watch(presetsProvider).value ?? const <Preset>[];
    return Scaffold(
      appBar: AppBar(
        title: Text(strings.presetsTitle),
        actions: [
          TextButton.icon(
            onPressed: () => _openEditor(
              context,
              ref.read(presetServiceProvider).newDraft(strings.presetNewName),
            ),
            icon: const Icon(Icons.add),
            label: Text(strings.commonNew),
          ),
        ],
      ),
      body: ListView.separated(
        padding: scrollPadding(
          context,
          const EdgeInsets.fromLTRB(20, 8, 20, 24),
        ),
        itemCount: presets.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) => _PresetTile(
          preset: presets[index],
          isGlobal: catalog?.globalPresetId == presets[index].id,
          onTap: () => _openEditor(context, presets[index]),
        ),
      ),
    );
  }

  void _openEditor(BuildContext context, Preset preset) =>
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => PresetEditorScreen(initialPreset: preset),
        ),
      );
}

class _PresetTile extends StatelessWidget {
  const _PresetTile({
    required this.preset,
    required this.isGlobal,
    required this.onTap,
  });

  final Preset preset;
  final bool isGlobal;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final colors = AlambicColors.of(context);
    return Material(
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: colors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      strings.presetName(preset),
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (isGlobal) _Badge(strings.presetGlobalBadge),
                ],
              ),
              switch (preset.engine) {
                SchedulingEngineKind.sequence => Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final interval in preset.intervals)
                      IntervalChip(label: strings.intervalLabel(interval)),
                  ],
                ),
                SchedulingEngineKind.adaptive => Text(
                  strings.presetAdaptiveDescription(
                    (preset.targetRetention * 100).round(),
                  ),
                  style: TextStyle(fontSize: 14, color: colors.textPrimary),
                ),
              },
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = AlambicColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colors.accentTint,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: colors.accentText,
        ),
      ),
    );
  }
}
