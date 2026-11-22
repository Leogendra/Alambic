import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/formatting/interval_labels.dart';
import '../../app/layout/scroll_padding.dart';
import '../../app/widgets/section_label.dart';
import '../../app/formatting/preset_labels.dart';
import '../../application/presets/preset_providers.dart';
import '../../domain/presets/preset.dart';
import '../../l10n/generated/app_localizations.dart';
import 'failure_choice.dart';
import 'step_dialog.dart';
import 'step_timeline.dart';

/// Creates or edits a preset. Changes are kept in a draft until saved, then
/// the screen closes with the id of the preset.
class PresetEditorScreen extends ConsumerStatefulWidget {
  const PresetEditorScreen({required this.initialPreset, super.key});

  /// A preset with id 0 is created on save; any other is updated.
  final Preset initialPreset;

  @override
  ConsumerState<PresetEditorScreen> createState() => _PresetEditorScreenState();
}

class _PresetEditorScreenState extends ConsumerState<PresetEditorScreen> {
  late Preset _draft = widget.initialPreset;
  final TextEditingController _nameController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // A shipped preset shows its name in the language of the interface. The
    // draft keeps the stored name until the field is edited.
    if (_nameController.text.isEmpty) {
      _nameController.text = AppLocalizations.of(context)
          .presetName(widget.initialPreset);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _update(Preset Function(Preset draft) change) =>
      setState(() => _draft = change(_draft));

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(strings.presetName(_draft)),
        actions: [
          TextButton(onPressed: _save, child: Text(strings.commonSave)),
        ],
      ),
      body: ListView(
        padding: scrollPadding(
          context,
          const EdgeInsets.fromLTRB(20, 8, 20, 32),
        ),
        children: [
          _nameField(strings),
          const SizedBox(height: 24),
          _stepsSection(strings),
          const SizedBox(height: 24),
          _failureSection(strings),
        ],
      ),
    );
  }

  Widget _nameField(AppLocalizations strings) => TextField(
    controller: _nameController,
    decoration: InputDecoration(labelText: strings.presetEditorName),
    textCapitalization: TextCapitalization.sentences,
    onChanged: (name) => _update((draft) => draft.copyWith(name: name)),
  );

  Widget _stepsSection(AppLocalizations strings) {
    final intervals = _draft.intervals;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(strings.presetEditorSteps),
        const SizedBox(height: 4),
        StepTimeline(
          labels: [for (final step in intervals) strings.intervalLabel(step)],
          removeTooltip: strings.presetEditorRemoveStep,
          onRemove: intervals.length > 1 ? _removeStep : null,
        ),
        const SizedBox(height: 8),
        ActionChip(
          avatar: const Icon(Icons.add, size: 18),
          label: Text(strings.presetEditorAddStep),
          onPressed: _addStep,
        ),
      ],
    );
  }

  Widget _failureSection(AppLocalizations strings) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      SectionLabel(strings.presetEditorOnFailure),
      FailureChoice(
        selected: _draft.failureBehavior,
        onSelected: (value) =>
            _update((draft) => draft.copyWith(failureBehavior: value)),
      ),
    ],
  );

  Future<void> _addStep() async {
    final step = await showStepDialog(context);
    if (step != null) {
      _update((draft) => draft.withStep(step.normalized));
    }
  }

  void _removeStep(int index) => _update((draft) => draft.withoutStep(index));

  Future<void> _save() async {
    final strings = AppLocalizations.of(context);
    if (_draft.name.trim().isEmpty) {
      _showMessage(strings.presetEditorNameRequired);
      return;
    }
    final presetId = await ref
        .read(presetServiceProvider)
        .save(_draft.copyWith(name: _draft.name.trim()));
    if (mounted) {
      Navigator.of(context).pop(presetId);
    }
  }

  void _showMessage(String message) =>
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
}
