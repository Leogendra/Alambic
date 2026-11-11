import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/formatting/clock_time_conversions.dart';
import '../../app/formatting/interval_labels.dart';
import '../../app/theme/remanence_colors.dart';
import '../../app/widgets/interval_chip.dart';
import '../../app/widgets/panel_row.dart';
import '../../app/widgets/section_label.dart';
import '../../app/widgets/segment_option.dart';
import '../../app/widgets/segmented_choice.dart';
import '../../app/widgets/surface_panel.dart';
import '../../application/presets/preset_providers.dart';
import '../../domain/presets/failure_behavior.dart';
import '../../domain/presets/grouped_reminder_action.dart';
import '../../domain/presets/notification_mode.dart';
import '../../domain/presets/preset.dart';
import '../../domain/presets/schedule_kind.dart';
import '../../domain/presets/sequence_end_behavior.dart';
import '../../domain/scheduling/clock_time.dart';
import '../../l10n/generated/app_localizations.dart';
import 'step_dialog.dart';

/// Creates or edits a sequence preset. Changes are kept in a draft until saved.
class PresetEditorScreen extends ConsumerStatefulWidget {
  const PresetEditorScreen({required this.initialPreset, super.key});

  /// A preset with id 0 is created on save; any other is updated.
  final Preset initialPreset;

  @override
  ConsumerState<PresetEditorScreen> createState() => _PresetEditorScreenState();
}

class _PresetEditorScreenState extends ConsumerState<PresetEditorScreen> {
  late Preset _draft = widget.initialPreset;
  late final TextEditingController _nameController = TextEditingController(
    text: widget.initialPreset.name,
  );

  bool get _isStored => _draft.id != 0;

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
        title: Text(_draft.name),
        actions: [
          if (_isStored)
            IconButton(
              tooltip: strings.presetDuplicate,
              onPressed: _duplicate,
              icon: const Icon(Icons.copy_outlined),
            ),
          TextButton(onPressed: _save, child: Text(strings.commonSave)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          _nameField(strings),
          const SizedBox(height: 24),
          _stepsSection(strings),
          const SizedBox(height: 24),
          _failureSection(strings),
          const SizedBox(height: 24),
          _endSection(strings),
          const SizedBox(height: 24),
          _typedAnswerSection(strings),
          const SizedBox(height: 24),
          _scheduleSection(strings),
          const SizedBox(height: 24),
          _notificationSection(strings),
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
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            for (var index = 0; index < intervals.length; index++)
              IntervalChip(
                label: strings.intervalLabel(intervals[index]),
                deleteTooltip: strings.presetEditorRemoveStep,
                onDeleted: intervals.length > 1
                    ? () => _removeStep(index)
                    : null,
              ),
            ActionChip(
              avatar: const Icon(Icons.add, size: 18),
              label: Text(strings.presetEditorAddStep),
              onPressed: _addStep,
            ),
          ],
        ),
      ],
    );
  }

  Widget _failureSection(AppLocalizations strings) => _choiceSection(
    strings.presetEditorOnFailure,
    SegmentedChoice<FailureBehavior>(
      options: [
        SegmentOption(FailureBehavior.stepBack, strings.presetFailureStepBack),
        SegmentOption(FailureBehavior.restart, strings.presetFailureRestart),
        SegmentOption(FailureBehavior.stay, strings.presetFailureStay),
      ],
      selected: _draft.failureBehavior,
      onSelected: (value) =>
          _update((draft) => draft.copyWith(failureBehavior: value)),
    ),
  );

  Widget _endSection(AppLocalizations strings) => _choiceSection(
    strings.presetEditorAfterLastStep,
    SegmentedChoice<SequenceEndBehavior>(
      options: [
        SegmentOption(
          SequenceEndBehavior.repeatLast,
          strings.presetEndRepeatLast,
        ),
        SegmentOption(
          SequenceEndBehavior.markAcquired,
          strings.presetEndAcquired,
        ),
        SegmentOption(SequenceEndBehavior.loop, strings.presetEndLoop),
      ],
      selected: _draft.endBehavior,
      onSelected: (value) =>
          _update((draft) => draft.copyWith(endBehavior: value)),
    ),
  );

  Widget _typedAnswerSection(AppLocalizations strings) => SurfacePanel(
    children: [
      PanelRow(
        title: strings.presetEditorTypedAnswer,
        subtitle: strings.presetEditorTypedAnswerHint,
        trailing: Switch(
          value: _draft.typedAnswer,
          onChanged: (value) =>
              _update((draft) => draft.copyWith(typedAnswer: value)),
        ),
      ),
    ],
  );

  Widget _scheduleSection(AppLocalizations strings) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      SectionLabel(strings.presetEditorSchedule),
      SegmentedChoice<ScheduleKind>(
        options: [
          SegmentOption(ScheduleKind.fixedTime, strings.presetScheduleFixed),
          SegmentOption(ScheduleKind.timeRange, strings.presetScheduleRange),
        ],
        selected: _draft.scheduleKind,
        onSelected: (value) =>
            _update((draft) => draft.copyWith(scheduleKind: value)),
      ),
      const SizedBox(height: 12),
      SurfacePanel(children: _scheduleRows(strings)),
    ],
  );

  List<Widget> _scheduleRows(AppLocalizations strings) =>
      switch (_draft.scheduleKind) {
        ScheduleKind.fixedTime => [
          _timeRow(
            strings.presetEditorFixedTime,
            _draft.fixedTime,
            (time) => _draft.copyWith(fixedTime: time),
          ),
        ],
        ScheduleKind.timeRange => [
          _timeRow(
            strings.presetEditorRangeStart,
            _draft.rangeStart,
            (time) => _draft.copyWith(rangeStart: time),
          ),
          _timeRow(
            strings.presetEditorRangeEnd,
            _draft.rangeEnd,
            (time) => _draft.copyWith(rangeEnd: time),
          ),
        ],
      };

  Widget _timeRow(
    String title,
    ClockTime time,
    Preset Function(ClockTime time) withTime,
  ) => PanelRow(
    title: title,
    trailing: Text(
      time.toString(),
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: RemanenceColors.of(context).accentText,
      ),
    ),
    onTap: () async {
      final picked = await showTimePicker(
        context: context,
        initialTime: time.toTimeOfDay(),
      );
      if (picked != null) {
        _update((_) => withTime(picked.toClockTime()));
      }
    },
  );

  Widget _notificationSection(AppLocalizations strings) {
    final isGrouped = _draft.notificationMode == NotificationMode.grouped;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionLabel(strings.presetEditorNotifications),
        SegmentedChoice<NotificationMode>(
          options: [
            SegmentOption(
              NotificationMode.perCard,
              strings.presetNotifyPerCard,
            ),
            SegmentOption(
              NotificationMode.grouped,
              strings.presetNotifyGrouped,
            ),
          ],
          selected: _draft.notificationMode,
          onSelected: (value) =>
              _update((draft) => draft.copyWith(notificationMode: value)),
        ),
        _hint(
          isGrouped ? strings.presetGroupedHint : strings.presetPerCardHint,
        ),
        if (isGrouped) ...[
          const SizedBox(height: 12),
          _choiceSection(
            strings.presetEditorGroupedTap,
            SegmentedChoice<GroupedReminderAction>(
              options: [
                SegmentOption(
                  GroupedReminderAction.openApp,
                  strings.presetGroupedOpenApp,
                ),
                SegmentOption(
                  GroupedReminderAction.chainInNotification,
                  strings.presetGroupedChain,
                ),
              ],
              selected: _draft.groupedAction,
              onSelected: (value) =>
                  _update((draft) => draft.copyWith(groupedAction: value)),
            ),
          ),
        ],
      ],
    );
  }

  Widget _choiceSection(String title, Widget choice) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [SectionLabel(title), choice],
  );

  Widget _hint(String text) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 13,
        color: RemanenceColors.of(context).textSecondary,
      ),
    ),
  );

  Future<void> _addStep() async {
    final step = await showStepDialog(context);
    if (step != null) {
      _update((draft) => draft.copyWith(intervals: [...draft.intervals, step]));
    }
  }

  void _removeStep(int index) => _update(
    (draft) => draft.copyWith(intervals: [...draft.intervals]..removeAt(index)),
  );

  Future<void> _save() async {
    final strings = AppLocalizations.of(context);
    if (_draft.name.trim().isEmpty) {
      _showMessage(strings.presetEditorNameRequired);
      return;
    }
    await ref
        .read(presetServiceProvider)
        .save(_draft.copyWith(name: _draft.name.trim()));
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _duplicate() async {
    final strings = AppLocalizations.of(context);
    final copyName = strings.presetCopyName(_draft.name);
    final service = ref.read(presetServiceProvider);
    final copyId = await service.duplicate(_draft, copyName);
    if (!mounted) {
      return;
    }
    _showMessage(strings.presetDuplicated(copyName));
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (context) => PresetEditorScreen(
          initialPreset: _draft.copyWith(
            id: copyId,
            name: copyName,
            builtInKey: () => null,
          ),
        ),
      ),
    );
  }

  void _showMessage(String message) =>
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
}
