import 'package:flutter/rendering.dart' show OverflowBoxFit;
import 'package:material_ui/material_ui.dart';

import '../../app/formatting/interval_labels.dart';
import '../../app/theme/alambic_colors.dart';
import '../../domain/groups/after_last_step.dart';
import '../../domain/groups/sequence_end.dart';
import '../../domain/presets/preset.dart';
import '../../domain/scheduling/step_target.dart';
import '../../l10n/generated/app_localizations.dart';

/// The sequence of a preset as a track: one segment per step with its
/// interval under it, then the remanence of the group as a dot. The steps
/// passed are filled, the current one is outlined with its interval in bold,
/// the next ones are left empty. The dot fills once the card reaches the
/// remanence.
class StepTrack extends StatelessWidget {
  const StepTrack({
    required this.preset,
    required this.end,
    required this.current,
    super.key,
  });

  /// Beyond this many steps, only the intervals of the first, the current
  /// and the last step are written, each free to spread over the empty
  /// columns beside it, so that none is cut.
  static const int _maxLabels = 8;

  /// Beyond this many steps, the intervals are written smaller to fit.
  static const int _largeLabels = 6;

  static const double _barHeight = 8;
  static const double _dotSize = 12;

  final Preset preset;
  final SequenceEnd end;

  /// Where the card stands; `null` for a card that waits no step yet.
  final StepTarget? current;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final colors = AlambicColors.of(context);
    final count = preset.sequenceLength;
    final currentStep = switch (current) {
      StepIndexTarget(:final step) => step,
      _ => null,
    };
    final passed = switch (current) {
      StepIndexTarget(:final step) => step,
      SequenceEndTarget() => count,
      _ => 0,
    };
    final sparse = count > _maxLabels;
    final hasRemanence = end.afterLastStep == AfterLastStep.remanence;
    final remanenceReached = current is SequenceEndTarget;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        for (var step = 0; step < count; step++)
          Expanded(
            child: _column(
              _bar(
                colors,
                passed: step < passed,
                isCurrent: step == currentStep,
              ),
              !sparse || step == 0 || step == count - 1 || step == currentStep
                  ? strings.intervalLabel(preset.intervals[step])
                  : '',
              colors,
              isCurrent: step == currentStep,
              fontSize: count > _largeLabels ? 9 : 11,
              spreads: sparse,
            ),
          ),
        if (hasRemanence)
          SizedBox(
            width: 40,
            child: _column(
              Container(
                width: _dotSize,
                height: _dotSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: remanenceReached ? colors.accent : colors.well,
                ),
              ),
              strings.intervalLabel(end.remanenceAfter(preset)),
              colors,
              isCurrent: remanenceReached,
              fontSize: count > _largeLabels ? 9 : 11,
            ),
          ),
      ],
    );
  }

  Widget _column(
    Widget mark,
    String label,
    AlambicColors colors, {
    required bool isCurrent,
    required double fontSize,
    bool spreads = false,
  }) {
    final text = Text(
      label,
      textAlign: TextAlign.center,
      maxLines: 1,
      softWrap: !spreads,
      overflow: spreads ? TextOverflow.visible : TextOverflow.clip,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: isCurrent ? FontWeight.w700 : null,
        color: isCurrent ? colors.accentText : colors.textSecondary,
      ),
    );
    return Column(
      spacing: 6,
      children: [
        SizedBox(
          height: _dotSize,
          child: Center(child: mark),
        ),
        if (spreads)
          OverflowBox(
            maxWidth: double.infinity,
            fit: OverflowBoxFit.deferToChild,
            child: text,
          )
        else
          text,
      ],
    );
  }

  Widget _bar(
    AlambicColors colors, {
    required bool passed,
    required bool isCurrent,
  }) => Container(
    height: _barHeight,
    decoration: BoxDecoration(
      color: passed
          ? colors.accent
          : isCurrent
          ? colors.accentTint
          : colors.well,
      border: isCurrent ? Border.all(color: colors.accent, width: 1.5) : null,
      borderRadius: BorderRadius.circular(_barHeight / 2),
    ),
  );
}
