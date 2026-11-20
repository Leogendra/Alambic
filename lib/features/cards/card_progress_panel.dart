import 'package:material_ui/material_ui.dart';

import '../../app/formatting/date_labels.dart';
import '../../app/formatting/interval_labels.dart';
import '../../app/theme/alambic_colors.dart';
import '../../domain/cards/card_state.dart';
import '../../domain/cards/flashcard.dart';
import '../../domain/groups/after_last_step.dart';
import '../../domain/groups/sequence_end.dart';
import '../../domain/presets/preset.dart';
import '../../domain/scheduling/card_progress.dart';
import '../../l10n/generated/app_localizations.dart';

/// Where a card stands: its position in the sequence of its preset, the
/// remanence of its group as a last step, and its next review; or why it is
/// not scheduled.
class CardProgressPanel extends StatelessWidget {
  const CardProgressPanel({
    required this.card,
    required this.preset,
    required this.end,
    required this.isDue,
    super.key,
  });

  final Flashcard card;
  final Preset preset;
  final SequenceEnd end;
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
        _sequence(strings, colors, preset.lastStep),
        _message(strings.cardSheetAcquired, colors),
      ],
      CardState.active || CardState.remanent => [
        _sequence(strings, colors, switch (CardProgress.of(card, preset, end)) {
          NewProgress() => null,
          SequenceProgress(:final step) => step,
          RemanenceProgress(:final sequenceLength) => sequenceLength,
        }),
        _nextReview(context, colors, card.dueAt!),
      ],
    };
  }

  /// The steps of the preset, then the remanence when the group has one,
  /// each over its interval; filled up to [position], bold at it.
  Widget _sequence(
    AppLocalizations strings,
    AlambicColors colors,
    int? position,
  ) {
    final intervals = [
      ...preset.intervals,
      if (end.afterLastStep == AfterLastStep.remanence)
        end.remanenceAfter(preset),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 6,
      children: [
        Row(
          spacing: 4,
          children: [
            for (var index = 0; index < intervals.length; index++)
              Expanded(
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: position != null && index <= position
                        ? colors.accent
                        : colors.well,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
          ],
        ),
        Row(
          spacing: 4,
          children: [
            for (var index = 0; index < intervals.length; index++)
              Expanded(
                child: Text(
                  strings.intervalLabel(intervals[index]),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: index == position ? FontWeight.w700 : null,
                    color: index == position
                        ? colors.accentText
                        : colors.textSecondary,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
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
}
