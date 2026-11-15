import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app/formatting/date_labels.dart';
import '../../app/formatting/interval_labels.dart';
import '../../app/formatting/preset_labels.dart';
import '../../app/theme/alambic_colors.dart';
import '../../domain/cards/card_direction.dart';
import '../../domain/cards/direction_state.dart';
import '../../domain/presets/preset.dart';
import '../../domain/presets/scheduling_engine_kind.dart';
import '../../domain/scheduling/direction_progress.dart';
import '../../domain/scheduling/fsrs/fsrs_memory.dart';
import '../../l10n/generated/app_localizations.dart';

/// Where one direction stands: its step in the preset sequence or its FSRS
/// interval, and its next review; or why it is not scheduled.
class DirectionProgressPanel extends StatelessWidget {
  const DirectionProgressPanel({
    required this.direction,
    required this.preset,
    required this.isDue,
    required this.onStart,
    super.key,
  });

  final CardDirection? direction;
  final Preset preset;
  final bool isDue;

  /// Starts an unstarted direction.
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final colors = AlambicColors.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: _content(context, colors),
      ),
    );
  }

  List<Widget> _content(BuildContext context, AlambicColors colors) {
    final strings = AppLocalizations.of(context);
    final direction = this.direction;
    final state = direction?.state ?? DirectionState.inactive;
    return switch (state) {
      DirectionState.inactive => [_message(strings.cardSheetInactive, colors)],
      DirectionState.pending when direction!.isStartable => [
        _message(strings.cardSheetPendingStopped, colors),
        FilledButton.tonal(
          onPressed: onStart,
          child: Text(strings.cardSheetStart),
        ),
      ],
      DirectionState.pending => [_message(strings.cardSheetPending, colors)],
      DirectionState.unstarted => [
        _message(strings.cardSheetUnstarted, colors),
        FilledButton.tonal(
          onPressed: onStart,
          child: Text(strings.cardSheetStart),
        ),
      ],
      DirectionState.acquired => [
        if (preset.engine == SchedulingEngineKind.sequence)
          ..._sequence(context, colors, preset.sequenceLength - 1),
        _message(strings.cardSheetAcquired, colors),
      ],
      DirectionState.active => [
        ..._progress(context, colors, DirectionProgress.of(direction!, preset)),
        _nextReview(context, colors, direction.dueAt!),
      ],
    };
  }

  List<Widget> _progress(
    BuildContext context,
    AlambicColors colors,
    DirectionProgress progress,
  ) {
    final strings = AppLocalizations.of(context);
    return switch (progress) {
      NewProgress() when preset.engine == SchedulingEngineKind.adaptive => [
        _title(strings, colors, _capitalized(strings.cardStatusNew)),
      ],
      NewProgress() => _sequence(context, colors, null),
      SequenceProgress(:final step) => _sequence(context, colors, step),
      AdaptiveProgress(:final memory, :final intervalDays) => [
        _title(
          strings,
          colors,
          strings.cardSheetInterval(strings.intervalDays(intervalDays)),
        ),
        _memory(strings, colors, memory),
      ],
    };
  }

  Widget _title(AppLocalizations strings, AlambicColors colors, String title) =>
      Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            strings.presetName(preset),
            style: TextStyle(fontSize: 13, color: colors.textSecondary),
          ),
        ],
      );

  /// "Stabilité 10,8 j · difficulté 5,3 sur 10".
  Widget _memory(
    AppLocalizations strings,
    AlambicColors colors,
    FsrsMemory memory,
  ) {
    final format = NumberFormat('0.#', strings.localeName);
    return Text(
      strings.cardSheetMemory(
        format.format(memory.stability),
        format.format(memory.difficulty),
      ),
      style: TextStyle(fontSize: 13, color: colors.textSecondary),
    );
  }

  List<Widget> _sequence(
    BuildContext context,
    AlambicColors colors,
    int? step,
  ) {
    final strings = AppLocalizations.of(context);
    final length = preset.sequenceLength;
    return [
      _title(
        strings,
        colors,
        step == null
            ? _capitalized(strings.cardStatusNew)
            : strings.cardSheetStepOf(step + 1, length),
      ),
      Row(
        spacing: 4,
        children: [
          for (var index = 0; index < length; index++)
            Expanded(
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: step != null && index <= step
                      ? colors.accent
                      : colors.segmentBackground,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
        ],
      ),
      Row(
        spacing: 4,
        children: [
          for (var index = 0; index < length; index++)
            Expanded(
              child: Text(
                strings.intervalLabel(preset.intervals[index]),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.clip,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: index == step ? FontWeight.w700 : null,
                  color: index == step
                      ? colors.accentText
                      : colors.textSecondary,
                ),
              ),
            ),
        ],
      ),
    ];
  }

  Widget _nextReview(
    BuildContext context,
    AlambicColors colors,
    DateTime dueAt,
  ) {
    final strings = AppLocalizations.of(context);
    return Row(
      spacing: 10,
      children: [
        Icon(
          Icons.calendar_today_outlined,
          size: 18,
          color: colors.textSecondary,
        ),
        Expanded(
          child: isDue
              ? Text(
                  strings.cardSheetDueNow,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: colors.accentText,
                  ),
                )
              : Text.rich(
                  TextSpan(
                    style: const TextStyle(fontSize: 15),
                    children: [
                      TextSpan(text: '${strings.cardSheetNextReview} '),
                      TextSpan(
                        text: strings.dayDateTime(dueAt),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  Widget _message(String text, AlambicColors colors) => Text(
    text,
    style: TextStyle(fontSize: 15, height: 1.4, color: colors.textSecondary),
  );

  static String _capitalized(String text) =>
      text.isEmpty ? text : text[0].toUpperCase() + text.substring(1);
}
