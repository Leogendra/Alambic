import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/alambic_colors.dart';
import '../../application/reviews/review_providers.dart';
import '../../domain/cards/direction_state.dart';
import '../../domain/reviews/review_outcome.dart';
import '../../domain/scheduling/direction_schedule.dart';
import '../../l10n/generated/app_localizations.dart';
import '../cards/card_status_formatter.dart';
import '../cards/card_status_formatter_provider.dart';

/// "Again" and "Correct", each with when the card would come back.
class AnswerButtons extends ConsumerWidget {
  const AnswerButtons({
    required this.directionId,
    required this.isBonus,
    required this.enabled,
    required this.onAnswer,
    super.key,
  });

  final int directionId;
  final bool isBonus;
  final bool enabled;
  final ValueChanged<ReviewOutcome> onAnswer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final colors = AlambicColors.of(context);
    final preview = ref
        .watch(
          answerPreviewProvider((directionId: directionId, asBonus: isBonus)),
        )
        .value;
    final formatter = watchCardStatusFormatter(context, ref);
    String? hint(DirectionSchedule? schedule) => preview == null
        ? null
        : _hint(strings, formatter, preview.isBonus, schedule);
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
          foreground: Colors.white,
          onPressed: () => onAnswer(ReviewOutcome.correct),
        ),
      ],
    );
  }

  String? _hint(
    AppLocalizations strings,
    CardStatusFormatter? formatter,
    bool previewIsBonus,
    DirectionSchedule? schedule,
  ) {
    if (previewIsBonus) {
      return strings.answerNoEffect;
    } else if (schedule?.state == DirectionState.acquired) {
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
      height: 64,
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
