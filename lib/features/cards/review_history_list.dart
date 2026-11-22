import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/formatting/date_labels.dart';
import '../../app/formatting/interval_labels.dart';
import '../../app/theme/alambic_colors.dart';
import '../../app/widgets/surface_panel.dart';
import '../../application/reviews/review_providers.dart';
import '../../domain/cards/card_state.dart';
import '../../domain/groups/sequence_end.dart';
import '../../domain/presets/preset.dart';
import '../../domain/reviews/review_outcome.dart';
import '../../domain/reviews/review_record.dart';
import '../../l10n/generated/app_localizations.dart';

/// Answers given to one card, most recent first, with their effect:
/// "→ 1 mo", "back to 2 d", "learned", or "no effect" for a bonus.
class ReviewHistoryList extends ConsumerWidget {
  const ReviewHistoryList({
    required this.cardId,
    required this.preset,
    required this.end,
    super.key,
  });

  final int cardId;
  final Preset preset;
  final SequenceEnd end;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final colors = AlambicColors.of(context);
    final history = ref.watch(cardHistoryProvider(cardId)).value ?? const [];
    if (history.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Text(
          strings.cardSheetHistoryEmpty,
          style: TextStyle(fontSize: 14, color: colors.textSecondary),
        ),
      );
    }
    return SurfacePanel(
      children: [for (final record in history) _row(strings, colors, record)],
    );
  }

  Widget _row(
    AppLocalizations strings,
    AlambicColors colors,
    ReviewRecord record,
  ) {
    final isFailure = record.outcome == ReviewOutcome.again && !record.isBonus;
    return SizedBox(
      height: 52,
      child: Row(
        spacing: 12,
        children: [
          SizedBox(
            width: 56,
            child: Text(
              strings.shortDate(record.reviewedAt),
              style: TextStyle(fontSize: 13, color: colors.textSecondary),
            ),
          ),
          Expanded(
            child: Row(
              spacing: 6,
              children: [
                Flexible(
                  child: Text(
                    switch (record.outcome) {
                      ReviewOutcome.correct => strings.reviewCorrect,
                      ReviewOutcome.again => strings.reviewAgain,
                    },
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
                if (record.isBonus) _bonusTag(strings, colors),
              ],
            ),
          ),
          Text(
            _effect(strings, record),
            style: TextStyle(
              fontSize: 13,
              fontWeight: record.isBonus ? null : FontWeight.w600,
              color: record.isBonus
                  ? colors.textSecondary
                  : isFailure
                  ? colors.againForeground
                  : colors.accentText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _bonusTag(AppLocalizations strings, AlambicColors colors) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: colors.surfaceRaised,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      strings.cardSheetHistoryBonus,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: colors.textSecondary,
      ),
    ),
  );

  /// The step reached is read against the current sequence and end, which
  /// may differ from the ones in force at the time of the answer.
  String _effect(AppLocalizations strings, ReviewRecord record) {
    final reached = switch (record.stateAfter) {
      CardState.completed when record.dueAtAfter == null => null,
      CardState.completed => end.remanenceAfter(preset),
      _ => switch (preset.clampStep(record.stepAfter)) {
        final step? => preset.intervals[step],
        null => null,
      },
    };
    if (record.isBonus) {
      return strings.reviewNoEffect;
    } else if (reached == null) {
      return strings.reviewAcquired;
    } else {
      final interval = strings.intervalLabel(reached);
      return record.outcome == ReviewOutcome.correct
          ? strings.cardSheetHistoryTo(interval)
          : strings.cardSheetHistoryBackTo(interval);
    }
  }
}
