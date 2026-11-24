import 'package:material_ui/material_ui.dart';

import '../../app/formatting/date_labels.dart';
import '../../app/formatting/interval_labels.dart';
import '../../app/widgets/choice_tile.dart';
import '../../domain/groups/after_last_step.dart';
import '../../domain/groups/sequence_end.dart';
import '../../domain/presets/preset.dart';
import '../../domain/scheduling/step_target.dart';
import '../../l10n/generated/app_localizations.dart';

/// Bottom sheet offering every target of [preset] and [end], the queue
/// first unless [offersQueue] is off, [current] selected. Each step shows
/// the date it would give, from [dueAtOf]. Returns the target tapped, or
/// `null` when dismissed.
Future<StepTarget?> showStepSheet(
  BuildContext context, {
  required Preset preset,
  required SequenceEnd end,
  required StepTarget? current,
  required bool offersQueue,
  required DateTime? Function(StepTarget target) dueAtOf,
}) => showModalBottomSheet<StepTarget>(
  context: context,
  showDragHandle: true,
  isScrollControlled: true,
  builder: (context) {
    final strings = AppLocalizations.of(context);
    return SafeArea(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
            child: Text(
              strings.stepSheetTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          for (final target in StepTarget.allOf(preset))
            if (offersQueue || target is! PendingTarget)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ChoiceTile(
                  label: _label(strings, target, preset, end),
                  detail: _detail(strings, target, dueAtOf(target)),
                  isSelected: target == current,
                  onTap: () => Navigator.of(context).pop(target),
                ),
              ),
        ],
      ),
    );
  },
);

String _label(
  AppLocalizations strings,
  StepTarget target,
  Preset preset,
  SequenceEnd end,
) => switch (target) {
  PendingTarget() => strings.stepSheetPending,
  StepIndexTarget(:final step) => strings.intervalLabel(preset.intervals[step]),
  SequenceEndTarget() => switch (end.afterLastStep) {
    AfterLastStep.remanence => strings.stepSheetRemanence(
      strings.intervalLabel(end.remanenceAfter(preset)),
    ),
    AfterLastStep.acquired => strings.cardSheetLearned,
  },
};

/// The date a step gives, or why there is none.
String? _detail(AppLocalizations strings, StepTarget target, DateTime? dueAt) =>
    switch ((target, dueAt)) {
      (PendingTarget(), _) => null,
      (_, final dueAt?) => strings.dayDateTime(dueAt),
      (_, null) => strings.cardSheetLearnedDetail,
    };
