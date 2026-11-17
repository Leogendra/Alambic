import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/alambic_colors.dart';
import '../../application/reviews/review_providers.dart';
import '../../domain/cards/card_state.dart';
import '../../domain/reviews/review_outcome.dart';
import '../../domain/scheduling/card_schedule.dart';
import '../../l10n/generated/app_localizations.dart';
import '../cards/card_status_formatter.dart';
import '../cards/card_status_formatter_provider.dart';

/// "Again" and "Correct", each with when the card would come back; a bonus
/// review shows the labels alone.
class AnswerButtons extends ConsumerWidget {
  const AnswerButtons({
    required this.cardId,
    required this.isBonus,
    required this.enabled,
    required this.onAnswer,
    super.key,
  });

  final int cardId;
  final bool isBonus;
  final bool enabled;
  final ValueChanged<ReviewOutcome> onAnswer;

  /// Height of the buttons, and of the space they share with "Show answer".
  static const height = 64.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final colors = AlambicColors.of(context);
    final preview = ref
        .watch(answerPreviewProvider((cardId: cardId, asBonus: isBonus)))
        .value;
    final formatter = watchCardStatusFormatter(context, ref);
    String? hint(CardSchedule? schedule) => preview == null || preview.isBonus
        ? null
        : _hint(strings, formatter, schedule);
    return Row(
      spacing: 10,
      children: [
        _button(
          label: strings.reviewAgain,
          hint: hint(preview?.again),
          background: colors.againBackground,
          foreground: colors.againForeground,
          onPressed: () => onAnswer(ReviewOutcome.again),
        ),
        _button(
          label: strings.reviewCorrect,
          hint: hint(preview?.correct),
          background: colors.accent,
          foreground: colors.onAccent,
          onPressed: () => onAnswer(ReviewOutcome.correct),
        ),
      ],
    );
  }

  String? _hint(
    AppLocalizations strings,
    CardStatusFormatter? formatter,
    CardSchedule? schedule,
  ) {
    if (schedule?.state == CardState.acquired) {
      return strings.answerAcquired;
    } else if (schedule?.dueAt == null || formatter == null) {
      return null;
    } else {
      return formatter.dueDateLabel(schedule!.dueAt!);
    }
  }

  Widget _button({
    required String label,
    required String? hint,
    required Color background,
    required Color foreground,
    required VoidCallback onPressed,
  }) => Expanded(
    child: SizedBox(
      height: height,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: enabled ? onPressed : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            if (hint != null)
              Text(
                hint,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
      ),
    ),
  );
}
