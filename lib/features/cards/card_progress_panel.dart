import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app/formatting/date_labels.dart';
import '../../app/formatting/interval_labels.dart';
import '../../app/formatting/preset_labels.dart';
import '../../app/formatting/reminder_labels.dart';
import '../../app/theme/alambic_colors.dart';
import '../../domain/cards/card_state.dart';
import '../../domain/cards/flashcard.dart';
import '../../domain/presets/preset.dart';
import '../../domain/presets/scheduling_engine_kind.dart';
import '../../domain/scheduling/card_progress.dart';
import '../../domain/scheduling/fsrs/fsrs_memory.dart';
import '../../l10n/generated/app_localizations.dart';

/// Where a card stands: the reminder label of its step in the preset
/// sequence, or its FSRS memory, and its next review; or why it is not
/// scheduled.
class CardProgressPanel extends StatelessWidget {
  const CardProgressPanel({
    required this.card,
    required this.preset,
    required this.isDue,
    super.key,
  });

  final Flashcard card;
  final Preset preset;
  final bool isDue;

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
    return switch (card.state) {
      CardState.pending => [_message(strings.cardSheetPending, colors)],
      CardState.acquired => [
        if (preset.engine == SchedulingEngineKind.sequence)
          ..._sequence(context, colors, preset.sequenceLength - 1),
        _message(strings.cardSheetAcquired, colors),
      ],
      CardState.active => [
        ..._progress(context, colors, CardProgress.of(card, preset)),
        _nextReview(context, colors, card.dueAt!),
      ],
    };
  }

  List<Widget> _progress(
    BuildContext context,
    AlambicColors colors,
    CardProgress progress,
  ) {
    final strings = AppLocalizations.of(context);
    return switch (progress) {
      NewProgress() when preset.engine == SchedulingEngineKind.adaptive => [
        _title(strings, colors, _capitalized(strings.cardStatusNew)),
      ],
      NewProgress() => _sequence(context, colors, null),
      SequenceProgress(:final step) => _sequence(context, colors, step),
      AdaptiveProgress(:final memory) => [
        _title(strings, colors, null),
        _memory(strings, colors, memory),
      ],
    };
  }

  /// [title] on the left, the preset on the right; the preset alone for a
  /// card followed by FSRS, which has no reminder label.
  Widget _title(
    AppLocalizations strings,
    AlambicColors colors,
    String? title,
  ) => Row(
    crossAxisAlignment: CrossAxisAlignment.baseline,
    textBaseline: TextBaseline.alphabetic,
    children: [
      Expanded(
        child: Text(
          title ?? '',
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
            : strings.reminderLabel(preset.intervals[step]),
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
