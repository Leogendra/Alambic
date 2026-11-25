import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/formatting/due_labels.dart';
import '../../app/theme/alambic_colors.dart';
import '../../app/widgets/big_figure.dart';
import '../../application/reviews/review_providers.dart';
import '../../domain/reviews/review_outcome.dart';
import '../../domain/reviews/review_record.dart';
import 'card_status_formatter.dart';

/// When a card was last answered "Again" and last "Correct", bonus reviews
/// included, side by side in large figures: "3 d", "today" or "never".
class LastAnswers extends ConsumerWidget {
  const LastAnswers({required this.cardId, required this.formatter, super.key});

  final int cardId;
  final CardStatusFormatter formatter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = formatter.strings;
    final colors = AlambicColors.of(context);
    final history = ref.watch(cardHistoryProvider(cardId)).value ?? const [];
    // Straight on the page, without a panel, so that it does not read as a
    // setting.
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsetsDirectional.only(end: 16),
                child: BigFigure(
                  value: _last(history, ReviewOutcome.again),
                  caption: strings.cardSheetLastAgain,
                  color: colors.textPrimary,
                  size: 20,
                ),
              ),
            ),
            VerticalDivider(width: 1, color: colors.border),
            Expanded(
              child: Padding(
                padding: const EdgeInsetsDirectional.only(start: 20),
                child: BigFigure(
                  value: _last(history, ReviewOutcome.correct),
                  caption: strings.cardSheetLastCorrect,
                  color: colors.textPrimary,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// The most recent answer of [outcome]; [history] is most recent first.
  String _last(List<ReviewRecord> history, ReviewOutcome outcome) {
    final last = history
        .where((record) => record.outcome == outcome)
        .firstOrNull;
    return last == null
        ? formatter.strings.cardSheetNever
        : formatter.strings.elapsedLabelOf(
            last.reviewedAt,
            now: formatter.now,
            calendar: formatter.calendar,
          );
  }
}
