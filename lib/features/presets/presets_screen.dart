import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/formatting/preset_labels.dart';
import '../../app/layout/scroll_padding.dart';
import '../../app/theme/alambic_colors.dart';
import '../../app/widgets/badge_label.dart';
import '../../app/widgets/compact_button.dart';
import '../../application/presets/preset_providers.dart';
import '../../domain/presets/preset.dart';
import '../../l10n/generated/app_localizations.dart';
import 'preset_editor_screen.dart';

/// Every preset as a tile, reached from Settings, with "New preset" at the
/// end of the list.
class PresetsScreen extends ConsumerWidget {
  const PresetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final catalog = ref.watch(presetCatalogProvider).value;
    final presets = ref.watch(presetsProvider).value ?? const <Preset>[];
    return Scaffold(
      appBar: AppBar(title: Text(strings.presetsTitle)),
      body: ListView(
        padding: scrollPadding(
          context,
          const EdgeInsets.fromLTRB(20, 8, 20, 24),
        ),
        children: [
          for (final preset in presets) ...[
            _PresetTile(
              preset: preset,
              isGlobal: catalog?.globalPresetId == preset.id,
            ),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 4),
          OutlinedButton.icon(
            onPressed: () => openPresetEditor(
              context,
              ref.read(presetServiceProvider).newDraft(strings.presetNewName),
            ),
            icon: const Icon(Icons.add),
            label: Text(strings.presetsNew),
          ),
        ],
      ),
    );
  }
}

/// Opens the editor of [preset]; returns its id once saved, `null` when left
/// without saving.
Future<int?> openPresetEditor(BuildContext context, Preset preset) =>
    Navigator.of(context).push(
      MaterialPageRoute<int>(
        builder: (context) => PresetEditorScreen(initialPreset: preset),
      ),
    );

/// Name, steps and failure behaviour of a preset, with "Edit" and "Make
/// default" and a menu of the less frequent actions. The global preset shows
/// the "Default" badge instead of the "Make default" button, and cannot be
/// deleted.
class _PresetTile extends ConsumerWidget {
  const _PresetTile({required this.preset, required this.isGlobal});

  final Preset preset;
  final bool isGlobal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final colors = AlambicColors.of(context);
    final detailStyle = TextStyle(fontSize: 14, color: colors.textSecondary);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            spacing: 8,
            children: [
              Expanded(
                child: Text(
                  strings.presetName(preset),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (isGlobal) BadgeLabel(strings.presetGlobalBadge),
              _menu(context, ref, strings),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4,
              children: [
                Text(strings.presetStepsSummary(preset), style: detailStyle),
                Text(
                  strings.presetFailureSummary(
                    strings.failureSummary(preset.failureBehavior),
                  ),
                  style: detailStyle,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            spacing: 8,
            children: [
              CompactButton(
                label: strings.presetEdit,
                onPressed: () => openPresetEditor(context, preset),
              ),
              if (!isGlobal)
                CompactButton(
                  label: strings.presetMakeDefault,
                  onPressed: () => ref
                      .read(presetServiceProvider)
                      .setGlobalPreset(preset.id),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _menu(BuildContext context, WidgetRef ref, AppLocalizations strings) =>
      PopupMenuButton<void>(
        tooltip: strings.presetActions(strings.presetName(preset)),
        itemBuilder: (context) => [
          PopupMenuItem(
            onTap: () => _duplicate(context, ref),
            child: Row(
              spacing: 10,
              children: [
                const Icon(Icons.copy_outlined, size: 20),
                Text(strings.presetDuplicate),
              ],
            ),
          ),
          if (!isGlobal)
            PopupMenuItem(
              onTap: () => _confirmDelete(context, ref, preset),
              child: Row(
                spacing: 10,
                children: [
                  const Icon(Icons.delete_outline, size: 20),
                  Text(strings.commonDelete),
                ],
              ),
            ),
        ],
      );

  Future<void> _duplicate(BuildContext context, WidgetRef ref) async {
    final strings = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final copyName = strings.presetCopyName(strings.presetName(preset));
    await ref.read(presetServiceProvider).duplicate(preset, copyName);
    messenger.showSnackBar(
      SnackBar(content: Text(strings.presetDuplicated(copyName))),
    );
  }
}

/// Tells how many groups chose the preset and move to the default one, then
/// deletes it once confirmed.
Future<void> _confirmDelete(
  BuildContext context,
  WidgetRef ref,
  Preset preset,
) async {
  final strings = AppLocalizations.of(context);
  final catalog = await ref.read(presetCatalogProvider.future);
  if (!context.mounted) {
    return;
  }
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(strings.presetDeleteConfirmTitle(strings.presetName(preset))),
      content: Text(
        strings.presetDeleteConfirmBody(
          catalog.groupCountChoosing(preset.id),
          strings.presetName(catalog.globalPreset),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(strings.commonCancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(strings.commonDelete),
        ),
      ],
    ),
  );
  if (confirmed == true) {
    await ref.read(presetServiceProvider).delete(preset.id);
  }
}
